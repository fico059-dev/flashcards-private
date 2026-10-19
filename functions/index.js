// Cloud Functions لتطبيق «تقدر».
//
// يعتمد التطبيق على Firestore مباشرة للقراءة والكتابة العادية، ولا يمرّ هنا
// إلا ما يحتاج صلاحيات خادم: إدارة المشرفين، الحذف/التعديل المتسلسل، الجلسات
// المخصّصة، التحقق من المشتريات، ومزامنة Algolia (اختيارية).

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { getFirestore, FieldValue, Timestamp } = require("firebase-admin/firestore");
const { getStorage } = require("firebase-admin/storage");
const crypto = require("node:crypto");

const {
  hasAdminRole,
  requireAuth,
  requireAdmin,
  requireString,
  hasPremium,
  chunk,
  shuffle,
  deleteByQuery,
  updateByQuery,
  ADMIN_ROLE,
} = require("./helpers");
const { grantPremium, verifyGooglePlay, verifyAppStore } = require("./purchases");
const algolia = require("./algolia");

initializeApp();
setGlobalOptions({ region: "us-central1", maxInstances: 10 });

const db = () => getFirestore();
const ALL_IDS = "all_ids";

// ───────────────────────── المشرفون ─────────────────────────

exports.addAdminRole = onCall(async (request) => {
  requireAdmin(request);
  const email = requireString(request.data?.email, "email").trim().toLowerCase();
  let user;
  try {
    user = await getAuth().getUserByEmail(email);
  } catch (e) {
    if (e.code === "auth/user-not-found") {
      throw new HttpsError("not-found", "ما فيه مستخدم بهذا البريد. لازم يسجّل أولاً.");
    }
    throw e;
  }
  const claims = user.customClaims ?? {};
  const roles = Array.isArray(claims.roles) ? claims.roles : [];
  if (!roles.includes(ADMIN_ROLE)) roles.push(ADMIN_ROLE);
  await getAuth().setCustomUserClaims(user.uid, { ...claims, roles });
  return { ok: true };
});

exports.listAdmins = onCall(async (request) => {
  requireAdmin(request);
  const admins = [];
  let pageToken;
  do {
    const page = await getAuth().listUsers(1000, pageToken);
    for (const user of page.users) {
      if (!hasAdminRole(user.customClaims)) continue;
      admins.push({
        uid: user.uid,
        email: user.email ?? null,
        displayName: user.displayName ?? null,
        lastSignInTime: user.metadata.lastSignInTime ?? null,
      });
    }
    pageToken = page.pageToken;
  } while (pageToken);
  admins.sort((a, b) => (a.email ?? "").localeCompare(b.email ?? ""));
  return { admins };
});

exports.removeAdminRole = onCall(async (request) => {
  requireAdmin(request);
  const uid = requireString(request.data?.uid, "uid");
  if (uid === request.auth.uid) {
    throw new HttpsError("failed-precondition", "ما تقدر تزيل صلاحية الإدارة عن نفسك.");
  }
  let user;
  try {
    user = await getAuth().getUser(uid);
  } catch (e) {
    if (e.code === "auth/user-not-found") throw new HttpsError("not-found", "المستخدم غير موجود.");
    throw e;
  }
  const claims = user.customClaims ?? {};
  if (!hasAdminRole(claims)) return { removed: false };
  await getAuth().setCustomUserClaims(uid, {
    ...claims,
    roles: claims.roles.filter((r) => r !== ADMIN_ROLE),
  });
  return { removed: true };
});

// ───────────────────────── الجلسات المخصّصة ─────────────────────────

/**
 * ينشئ جلسة مخصّصة من حزم محددة:
 *  - filter: all | seen | bookmarked | ignored
 *  - tags: إن وُجدت فيكفي أن تحمل البطاقة أحدها
 *  - sessionSize: أقصى عدد بطاقات (عشوائية)
 */
exports.createCustomSession = onCall(async (request) => {
  const uid = requireAuth(request);
  const { profileId, filter, tags = [], packIds, sessionSize } = request.data ?? {};
  if (profileId !== uid) {
    throw new HttpsError("permission-denied", "profileId لا يطابق المستخدم الحالي.");
  }
  if (!["all", "seen", "bookmarked", "ignored"].includes(filter)) {
    throw new HttpsError("invalid-argument", "filter غير صالح.");
  }
  if (!Array.isArray(packIds) || packIds.length === 0 || packIds.length > 100) {
    throw new HttpsError("invalid-argument", "اختر حزمة واحدة على الأقل.");
  }
  const size = Math.min(Math.max(parseInt(sessionSize, 10) || 0, 1), 1000);
  const tagSet = new Set(Array.isArray(tags) ? tags : []);
  const premium = hasPremium(request.auth.token);

  const candidates = new Map(); // flashcardId -> isPaid
  const matchesTags = (cardTags) =>
    tagSet.size === 0 || (cardTags ?? []).some((t) => tagSet.has(t));

  if (filter === "all") {
    for (const ids of chunk(packIds, 30)) {
      let q = db().collection("flashcards").where("packId", "in", ids);
      if (!premium) q = q.where("isPaid", "==", false);
      const snap = await q.select("tags", "isPaid").get();
      snap.docs.forEach((d) => {
        if (matchesTags(d.get("tags"))) candidates.set(d.id, !!d.get("isPaid"));
      });
    }
  } else {
    for (const ids of chunk(packIds, 30)) {
      let q = db()
        .collection("fcp_data")
        .where("profileId", "==", uid)
        .where("flashcardSnapshot.packId", "in", ids);
      if (filter === "ignored") q = q.where("ignored", "==", true);
      else {
        q = q.where("ignored", "==", false);
        if (filter === "bookmarked") q = q.where("hasBookmark", "==", true);
      }
      if (!premium) q = q.where("isPaid", "==", false);
      const snap = await q.get();
      snap.docs.forEach((d) => {
        if (matchesTags(d.get("flashcardSnapshot.tags"))) {
          candidates.set(d.get("flashcardId"), !!d.get("isPaid"));
        }
      });
    }
  }

  const picked = shuffle([...candidates.keys()]).slice(0, size);
  if (picked.length === 0) {
    throw new HttpsError("failed-precondition", "ما فيه بطاقات تطابق اختياراتك.");
  }

  const sessionRef = db().collection("custom_sessions").doc();
  const batch = db().batch();
  batch.set(sessionRef, {
    profileId: uid,
    currentIndex: 0,
    correctCount: 0,
    cardCount: picked.length,
    isPaid: picked.some((id) => candidates.get(id)),
    createdAt: Timestamp.now(),
  });
  batch.set(sessionRef.collection("flashcard_ids").doc(ALL_IDS), { flashcardIds: picked });
  await batch.commit();
  return { id: sessionRef.id, cardCount: picked.length };
});

// ───────────────────────── البطاقات ─────────────────────────

function downloadUrl(bucketName, path, token) {
  return (
    `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/` +
    `${encodeURIComponent(path)}?alt=media&token=${token}`
  );
}

async function uploadImage(path, base64) {
  const bucket = getStorage().bucket();
  const token = crypto.randomUUID();
  await bucket.file(path).save(Buffer.from(base64, "base64"), {
    contentType: "image/jpeg",
    metadata: { metadata: { firebaseStorageDownloadTokens: token } },
  });
  return downloadUrl(bucket.name, path, token);
}

async function deleteImage(path) {
  await getStorage().bucket().file(path).delete({ ignoreNotFound: true });
}

function applyTagDelta(tagCounts, oldTags, newTags) {
  const counts = { ...(tagCounts ?? {}) };
  const oldSet = new Set(oldTags);
  const newSet = new Set(newTags);
  for (const t of newSet) if (!oldSet.has(t)) counts[t] = (counts[t] ?? 0) + 1;
  for (const t of oldSet) {
    if (newSet.has(t)) continue;
    if ((counts[t] ?? 0) <= 1) delete counts[t];
    else counts[t] -= 1;
  }
  return counts;
}

exports.updateFlashcardEverywhere = onCall({ memory: "512MiB" }, async (request) => {
  requireAdmin(request);
  const d = request.data ?? {};
  const flashcardId = requireString(d.flashcardId, "flashcardId");
  const patch = d.updateFlashcardDto ?? {};

  const cardRef = db().collection("flashcards").doc(flashcardId);
  const cardSnap = await cardRef.get();
  if (!cardSnap.exists) throw new HttpsError("not-found", "البطاقة غير موجودة.");
  const card = cardSnap.data();

  const update = {};
  if (typeof patch.question === "string") update.question = patch.question;
  if (typeof patch.answer === "string") update.answer = patch.answer;
  if (Array.isArray(patch.tags)) update.tags = patch.tags;

  const qPath = `flashcards/${flashcardId}/question.jpg`;
  const aPath = `flashcards/${flashcardId}/answer.jpg`;
  if (d.questionImageBase64) update.questionImageUrl = await uploadImage(qPath, d.questionImageBase64);
  else if (d.shouldDeleteQuestion) {
    await deleteImage(qPath);
    update.questionImageUrl = null;
  }
  if (d.answerImageBase64) update.answerImageUrl = await uploadImage(aPath, d.answerImageBase64);
  else if (d.shouldDeleteAnswer) {
    await deleteImage(aPath);
    update.answerImageUrl = null;
  }

  if (Object.keys(update).length === 0) return { ok: true };

  await db().runTransaction(async (tx) => {
    // كل القراءات قبل الكتابات (قيد Firestore)
    const packRef = db().collection("packs").doc(card.packId);
    const pack = update.tags ? await tx.get(packRef) : null;

    tx.update(cardRef, update);
    if (pack?.exists) {
      const tagCounts = applyTagDelta(pack.get("tagCounts"), card.tags ?? [], update.tags);
      tx.update(packRef, { tagCounts, tags: Object.keys(tagCounts) });
    }
  });

  // نسخ «اللقطة» المخزّنة عند كل مستخدم وفي البلاغات
  const snapshotUpdate = {};
  for (const [key, value] of Object.entries(update)) {
    snapshotUpdate[`flashcardSnapshot.${key}`] = value;
  }
  await updateByQuery(db().collection("fcp_data").where("flashcardId", "==", flashcardId), snapshotUpdate);
  const reportRef = db().collection("flashcard_reports").doc(flashcardId);
  if ((await reportRef.get()).exists) await reportRef.update(snapshotUpdate);
  return { ok: true };
});

exports.deleteFlashcardEverywhere = onCall(async (request) => {
  requireAdmin(request);
  const flashcardId = requireString(request.data?.flashcard?.id, "flashcard.id");
  const cardRef = db().collection("flashcards").doc(flashcardId);

  await db().runTransaction(async (tx) => {
    const cardSnap = await tx.get(cardRef);
    if (!cardSnap.exists) return;
    const card = cardSnap.data();
    const packRef = db().collection("packs").doc(card.packId);
    const idsRef = packRef.collection("flashcard_ids").doc(ALL_IDS);
    const pack = await tx.get(packRef);

    tx.delete(cardRef);
    if (pack.exists) {
      const tagCounts = applyTagDelta(pack.get("tagCounts"), card.tags ?? [], []);
      tx.update(packRef, {
        flashcardsCount: Math.max(0, (pack.get("flashcardsCount") ?? 1) - 1),
        tagCounts,
        tags: Object.keys(tagCounts),
      });
      tx.set(idsRef, { flashcardIds: FieldValue.arrayRemove(flashcardId) }, { merge: true });
    }
  });

  await deleteByQuery(db().collection("fcp_data").where("flashcardId", "==", flashcardId));
  const reportRef = db().collection("flashcard_reports").doc(flashcardId);
  await db().recursiveDelete(reportRef);
  await Promise.all([
    deleteImage(`flashcards/${flashcardId}/question.jpg`),
    deleteImage(`flashcards/${flashcardId}/answer.jpg`),
  ]);
  return { ok: true };
});

// ───────────────────────── الحزم ─────────────────────────

exports.renamePackEverywhere = onCall(async (request) => {
  requireAdmin(request);
  const packId = requireString(request.data?.packId, "packId");
  const packName = requireString(request.data?.packName, "packName").trim();
  const packRef = db().collection("packs").doc(packId);
  if (!(await packRef.get()).exists) throw new HttpsError("not-found", "الحزمة غير موجودة.");

  await packRef.update({ name: packName });
  await updateByQuery(db().collection("pp_data").where("packId", "==", packId), { packName });
  await updateByQuery(
    db().collection("flashcard_reports").where("flashcardSnapshot.packId", "==", packId),
    { packName },
  );
  return { ok: true };
});

exports.deletePackEverywhereIfEmpty = onCall(async (request) => {
  requireAdmin(request);
  const packId = requireString(request.data?.packId, "packId");
  const packRef = db().collection("packs").doc(packId);
  const pack = await packRef.get();
  if (!pack.exists) return { ok: true };

  const cards = await db().collection("flashcards").where("packId", "==", packId).limit(1).get();
  if (!cards.empty || (pack.get("flashcardsCount") ?? 0) > 0) {
    throw new HttpsError("failed-precondition", "ما تقدر تحذف حزمة فيها بطاقات.");
  }
  await deleteByQuery(db().collection("pp_data").where("packId", "==", packId));
  await db().recursiveDelete(packRef);
  return { ok: true };
});

exports.deletePackProgress = onCall(async (request) => {
  const uid = requireAuth(request);
  const packId = requireString(request.data?.packId, "packId");
  await deleteByQuery(
    db()
      .collection("fcp_data")
      .where("profileId", "==", uid)
      .where("flashcardSnapshot.packId", "==", packId),
  );
  await db().collection("pp_data").doc(`${uid}_${packId}`).delete();
  return { ok: true };
});

// ───────────────────────── الحساب ─────────────────────────

exports.deleteUserAndUserData = onCall(async (request) => {
  const uid = requireAuth(request);
  await deleteByQuery(db().collection("fcp_data").where("profileId", "==", uid));
  await deleteByQuery(db().collection("pp_data").where("profileId", "==", uid));
  const sessions = await db().collection("custom_sessions").where("profileId", "==", uid).get();
  for (const doc of sessions.docs) await db().recursiveDelete(doc.ref);
  await db().recursiveDelete(db().collection("users").doc(uid));
  await getAuth().deleteUser(uid);
  return { ok: true };
});

// ───────────────────────── الاشتراكات ─────────────────────────

/** للتجربة فقط: يمنح اشتراكاً مؤقتاً. معطّلة ما لم يكن ALLOW_DEV_GRANT=true. */
exports.devGrant = onCall(async (request) => {
  requireAdmin(request);
  if (process.env.ALLOW_DEV_GRANT !== "true") {
    throw new HttpsError("failed-precondition", "devGrant معطّلة في هذه البيئة.");
  }
  const uid = request.data?.targetUid || request.auth.uid;
  const minutes = Math.min(Math.max(Number(request.data?.minutes) || 120, 1), 60 * 24 * 30);
  const expiresAtMs = Date.now() + minutes * 60 * 1000;
  await grantPremium(uid, expiresAtMs, { store: "dev_grant", productId: "dev" });
  return { ok: true, expiresAtMs };
});

exports.verifyPurchase = onCall(async (request) => {
  const uid = requireAuth(request);
  const { source, productId, verificationData } = request.data ?? {};
  requireString(source, "source");
  requireString(productId, "productId");
  requireString(verificationData, "verificationData");

  let result;
  if (source === "google_play") {
    result = await verifyGooglePlay({ productId, purchaseToken: verificationData });
  } else if (source === "app_store") {
    result = await verifyAppStore({ productId, receipt: verificationData });
  } else {
    throw new HttpsError("invalid-argument", "مصدر الشراء غير معروف.");
  }

  await grantPremium(uid, result.expiresAtMs, { store: result.store, productId });
  return { success: true, expiresAtMs: result.expiresAtMs };
});

// ───────────────────────── مزامنة Algolia (اختيارية) ─────────────────────────

exports.syncFlashcardToAlgolia = onDocumentWritten("flashcards/{id}", async (event) => {
  await algolia.sync("flashcardsIndex", event.params.id, event.data?.after?.data());
});

exports.syncPackToAlgolia = onDocumentWritten("packs/{id}", async (event) => {
  await algolia.sync("packsIndex", event.params.id, event.data?.after?.data());
});
