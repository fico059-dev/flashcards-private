// اختبارات تكامل تعمل على Firebase Emulators.
//
//   firebase emulators:exec --only auth,firestore,functions,storage \
//     --project demo-taqdir "cd functions && npm test"
//
// (أو شغّل المحاكيات في طرفية وشغّل npm test في أخرى.)

process.env.FIRESTORE_EMULATOR_HOST ||= "127.0.0.1:8080";
process.env.FIREBASE_AUTH_EMULATOR_HOST ||= "127.0.0.1:9099";
process.env.FIREBASE_STORAGE_EMULATOR_HOST ||= "127.0.0.1:9199";

const { test, before } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");

const PROJECT = "demo-taqdir";
initializeApp({ projectId: PROJECT, storageBucket: `${PROJECT}.appspot.com` });
const db = getFirestore();
const FN = (name) => `http://127.0.0.1:5001/${PROJECT}/us-central1/${name}`;

async function signUp(email, claims) {
  const base = "http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts";
  const r = await fetch(`${base}:signUp?key=x`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ email, password: "Passw0rd!", returnSecureToken: true }),
  });
  const { localId } = await r.json();
  if (claims) await getAuth().setCustomUserClaims(localId, claims);
  const s = await fetch(`${base}:signInWithPassword?key=x`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ email, password: "Passw0rd!", returnSecureToken: true }),
  });
  const { idToken } = await s.json();
  return { uid: localId, idToken };
}

async function call(name, user, data) {
  const res = await fetch(FN(name), {
    method: "POST",
    headers: {
      "content-type": "application/json",
      ...(user ? { authorization: `Bearer ${user.idToken}` } : {}),
    },
    body: JSON.stringify({ data }),
  });
  return res.json();
}

let admin, alice, bob;

before(async () => {
  // تصفير ثم تعبئة بيانات تجريبية
  await fetch(`http://127.0.0.1:8080/emulator/v1/projects/${PROJECT}/databases/(default)/documents`, { method: "DELETE" });
  await fetch(`http://127.0.0.1:9099/emulator/v1/projects/${PROJECT}/accounts`, { method: "DELETE" });
  const { execFileSync } = require("node:child_process");
  execFileSync("node", [path.join(__dirname, "../../scripts/seed.js"), "--project", PROJECT], {
    stdio: "inherit",
    env: process.env,
  });
  const stamp = Date.now();
  admin = await signUp(`admin${stamp}@t.com`, { roles: ["admin"] });
  alice = await signUp(`alice${stamp}@t.com`);
  bob = await signUp(`bob${stamp}@t.com`);
});

test("البيانات التجريبية تحتوي قسمي لفظي وكمي", async () => {
  const verbal = await db.collection("packs").where("section", "==", "verbal").get();
  const quant = await db.collection("packs").where("section", "==", "quant").get();
  assert.equal(verbal.size, 5);
  assert.equal(quant.size, 6);
});

test("الدوال الإدارية ترفض غير المشرف", async () => {
  const r = await call("renamePackEverywhere", alice, { packId: "verbal-analogy", packName: "x" });
  assert.equal(r.error?.status, "PERMISSION_DENIED");
  const anon = await call("listAdmins", null, {});
  assert.equal(anon.error?.status, "UNAUTHENTICATED");
});

test("addAdminRole / listAdmins / removeAdminRole", async () => {
  const r = await call("addAdminRole", admin, { email: (await getAuth().getUser(bob.uid)).email });
  assert.equal(r.result?.ok, true);
  const list = await call("listAdmins", admin, {});
  assert.ok(list.result.admins.some((a) => a.uid === bob.uid));
  const rm = await call("removeAdminRole", admin, { uid: bob.uid });
  assert.equal(rm.result.removed, true);
  const self = await call("removeAdminRole", admin, { uid: admin.uid });
  assert.equal(self.error?.status, "FAILED_PRECONDITION");
});

test("createCustomSession: مجاني فقط لغير المشترك، وكل البطاقات للمشترك", async () => {
  const free = await call("createCustomSession", alice, {
    profileId: alice.uid, filter: "all", tags: [], packIds: ["verbal-reading", "verbal-analogy"], sessionSize: 50,
  });
  assert.equal(free.result.cardCount, 5, JSON.stringify(free)); // التناظر فقط (الاستيعاب مدفوع)
  const sess = await db.collection("custom_sessions").doc(free.result.id).get();
  assert.equal(sess.get("profileId"), alice.uid);
  assert.equal(sess.get("isPaid"), false);
  const ids = await sess.ref.collection("flashcard_ids").doc("all_ids").get();
  assert.equal(ids.get("flashcardIds").length, 5);

  // منح اشتراك مؤقت (devGrant) ثم إعادة تسجيل الدخول لتحديث التوكن
  const g = await call("devGrant", admin, { targetUid: alice.uid, scope: "premium", minutes: 60 });
  assert.equal(g.result?.ok, true, JSON.stringify(g));
  const signIn = await fetch("http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=x", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ email: (await getAuth().getUser(alice.uid)).email, password: "Passw0rd!", returnSecureToken: true }),
  });
  alice.idToken = (await signIn.json()).idToken;
  const paid = await call("createCustomSession", alice, {
    profileId: alice.uid, filter: "all", tags: [], packIds: ["verbal-reading", "verbal-analogy"], sessionSize: 3,
  });
  assert.equal(paid.result.cardCount, 3, JSON.stringify(paid));

  const badUser = await call("createCustomSession", alice, {
    profileId: bob.uid, filter: "all", tags: [], packIds: ["verbal-analogy"], sessionSize: 3,
  });
  assert.equal(badUser.error?.status, "PERMISSION_DENIED");
});

test("createCustomSession بفلتر المحفوظة", async () => {
  await db.collection("fcp_data").doc(`${bob.uid}_quant-algebra-01`).set({
    profileId: bob.uid, flashcardId: "quant-algebra-01", isPaid: false, hasBookmark: true, ignored: false,
    flashcardSnapshot: { packId: "quant-algebra", question: "q", answer: "a", tags: ["جبر"] },
    fsrs_card: { due: Timestamp.now() },
  });
  const r = await call("createCustomSession", bob, {
    profileId: bob.uid, filter: "bookmarked", tags: ["جبر"], packIds: ["quant-algebra"], sessionSize: 10,
  });
  assert.equal(r.result?.cardCount, 1, JSON.stringify(r));
  const none = await call("createCustomSession", bob, {
    profileId: bob.uid, filter: "ignored", tags: [], packIds: ["quant-algebra"], sessionSize: 10,
  });
  assert.equal(none.error?.status, "FAILED_PRECONDITION");
});

test("renamePackEverywhere يحدّث الحزمة وpp_data", async () => {
  await db.collection("pp_data").doc(`${alice.uid}_quant-geometry`).set({
    profileId: alice.uid, packId: "quant-geometry", packName: "الهندسة",
    firstOpenedAt: Timestamp.now(), lastOpenedAt: Timestamp.now(),
  });
  const r = await call("renamePackEverywhere", admin, { packId: "quant-geometry", packName: "الهندسة المستوية" });
  assert.equal(r.result?.ok, true, JSON.stringify(r));
  assert.equal((await db.collection("packs").doc("quant-geometry").get()).get("name"), "الهندسة المستوية");
  assert.equal((await db.collection("pp_data").doc(`${alice.uid}_quant-geometry`).get()).get("packName"), "الهندسة المستوية");
});

test("updateFlashcardEverywhere يحدّث البطاقة ولقطات المستخدمين وعدّادات الوسوم", async () => {
  await db.collection("fcp_data").doc(`${alice.uid}_quant-ratio-01`).set({
    profileId: alice.uid, flashcardId: "quant-ratio-01", isPaid: false, hasBookmark: false, ignored: false,
    flashcardSnapshot: { packId: "quant-ratio", question: "old", answer: "old", tags: ["نسبة__وتناسب"] },
    fsrs_card: { due: Timestamp.now() },
  });
  const r = await call("updateFlashcardEverywhere", admin, {
    flashcardId: "quant-ratio-01",
    updateFlashcardDto: { question: "سؤال جديد", tags: ["نسبة__وتناسب", "نسبة مئوية"] },
    shouldDeleteAnswer: false, shouldDeleteQuestion: false,
  });
  assert.equal(r.result?.ok, true, JSON.stringify(r));
  assert.equal((await db.collection("flashcards").doc("quant-ratio-01").get()).get("question"), "سؤال جديد");
  const snap = await db.collection("fcp_data").doc(`${alice.uid}_quant-ratio-01`).get();
  assert.equal(snap.get("flashcardSnapshot.question"), "سؤال جديد");
  assert.equal(snap.get("flashcardSnapshot.answer"), "old"); // لم يتغير
  const pack = await db.collection("packs").doc("quant-ratio").get();
  assert.equal(pack.get("tagCounts")["نسبة مئوية"], 1);
  assert.equal(pack.get("tagCounts")["نسبة__وتناسب"], 5);
});

test("deleteFlashcardEverywhere يحذف البطاقة ويحدّث الحزمة وبيانات المستخدمين", async () => {
  const r = await call("deleteFlashcardEverywhere", admin, { flashcard: { id: "quant-ratio-01" } });
  assert.equal(r.result?.ok, true, JSON.stringify(r));
  assert.equal((await db.collection("flashcards").doc("quant-ratio-01").get()).exists, false);
  assert.equal((await db.collection("fcp_data").doc(`${alice.uid}_quant-ratio-01`).get()).exists, false);
  const pack = await db.collection("packs").doc("quant-ratio").get();
  assert.equal(pack.get("flashcardsCount"), 4);
  const ids = await pack.ref.collection("flashcard_ids").doc("all_ids").get();
  assert.ok(!ids.get("flashcardIds").includes("quant-ratio-01"));
  assert.equal(ids.get("flashcardIds").length, 4);
  assert.equal(pack.get("tagCounts")["نسبة مئوية"], undefined);
  assert.equal(pack.get("tagCounts")["نسبة__وتناسب"], 4);
});

test("deletePackProgress يمسح تقدم المستخدم فقط", async () => {
  await db.collection("fcp_data").doc(`${bob.uid}_quant-algebra-02`).set({
    profileId: bob.uid, flashcardId: "quant-algebra-02", isPaid: false, hasBookmark: false, ignored: false,
    flashcardSnapshot: { packId: "quant-algebra", question: "q", answer: "a", tags: [] },
    fsrs_card: { due: Timestamp.now() },
  });
  const r = await call("deletePackProgress", bob, { packId: "quant-algebra" });
  assert.equal(r.result?.ok, true, JSON.stringify(r));
  const left = await db.collection("fcp_data").where("profileId", "==", bob.uid).get();
  assert.equal(left.size, 0);
});

test("deletePackEverywhereIfEmpty يرفض الحزمة غير الفارغة", async () => {
  const r = await call("deletePackEverywhereIfEmpty", admin, { packId: "quant-algebra" });
  assert.equal(r.error?.status, "FAILED_PRECONDITION");
  await db.collection("packs").doc("empty-pack").set({ name: "فارغة", section: "verbal", flashcardsCount: 0, isPaid: false, tags: [], tagCounts: {} });
  const ok = await call("deletePackEverywhereIfEmpty", admin, { packId: "empty-pack" });
  assert.equal(ok.result?.ok, true);
  assert.equal((await db.collection("packs").doc("empty-pack").get()).exists, false);
});

test("deleteUserAndUserData يحذف بيانات المستخدم وحسابه", async () => {
  const r = await call("deleteUserAndUserData", alice, {});
  assert.equal(r.result?.ok, true, JSON.stringify(r));
  assert.equal((await db.collection("fcp_data").where("profileId", "==", alice.uid).get()).size, 0);
  assert.equal((await db.collection("custom_sessions").where("profileId", "==", alice.uid).get()).size, 0);
  await assert.rejects(getAuth().getUser(alice.uid));
});

test("verifyPurchase يرفض مصدراً غير معروف", async () => {
  const r = await call("verifyPurchase", bob, { source: "x", productId: "p", verificationData: "d" });
  assert.equal(r.error?.status, "INVALID_ARGUMENT");
});

// ───── قواعد Firestore ─────
test("قواعد Firestore", async () => {
  const env = await initializeTestEnvironment({
    projectId: PROJECT,
    firestore: { rules: fs.readFileSync(path.join(__dirname, "../../firestore.rules"), "utf8"), host: "127.0.0.1", port: 8080 },
  });
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const d = ctx.firestore();
    await d.doc("packs/p1").set({ name: "p", section: "verbal", isPaid: false });
    await d.doc("flashcards/free1").set({ packId: "p1", isPaid: false, question: "q", answer: "a" });
    await d.doc("flashcards/paid1").set({ packId: "p1", isPaid: true, question: "q", answer: "a" });
    await d.doc("fcp_data/u1_free1").set({ profileId: "u1", flashcardId: "free1" });
    await d.doc("custom_sessions/s1").set({ profileId: "u1", currentIndex: 0 });
    await d.doc("custom_sessions/s1/flashcard_ids/all_ids").set({ flashcardIds: [] });
  });

  const anon = env.unauthenticatedContext().firestore();
  const u1 = env.authenticatedContext("u1", {}).firestore();
  const u2 = env.authenticatedContext("u2", {}).firestore();
  const premium = env.authenticatedContext("u3", { premiumExp: Date.now() + 3600_000 }).firestore();
  const expired = env.authenticatedContext("u4", { premiumExp: Date.now() - 1000 }).firestore();
  const adm = env.authenticatedContext("a1", { roles: ["admin"] }).firestore();

  await assertFails(anon.doc("packs/p1").get());
  await assertSucceeds(u1.doc("packs/p1").get());
  await assertFails(u1.doc("packs/p2").set({ name: "x" }));
  await assertSucceeds(adm.doc("packs/p2").set({ name: "x", section: "quant" }));

  await assertSucceeds(u1.doc("flashcards/free1").get());
  await assertFails(u1.doc("flashcards/paid1").get());
  await assertFails(expired.doc("flashcards/paid1").get());
  await assertSucceeds(premium.doc("flashcards/paid1").get());
  await assertSucceeds(adm.doc("flashcards/paid1").get());
  await assertFails(premium.doc("flashcards/new").set({ isPaid: false }));

  await assertSucceeds(u1.doc("fcp_data/u1_free1").get());
  await assertFails(u2.doc("fcp_data/u1_free1").get());
  await assertSucceeds(u2.doc("fcp_data/u2_free2").set({ profileId: "u2", flashcardId: "free2" }));
  await assertFails(u2.doc("fcp_data/u1_free9").set({ profileId: "u1", flashcardId: "free9" }));
  // update على مستند غير موجود يخص المستخدم => not-found (ليس permission-denied) ليعمل نمط update ثم set
  await assert.rejects(u2.doc("fcp_data/u2_missing").update({ x: 1 }), (e) => e.code === "not-found");
  await assert.rejects(u2.doc("pp_data/u2_pack9").update({ x: 1 }), (e) => e.code === "not-found");
  await assert.rejects(u2.doc("fcp_data/u1_missing").update({ x: 1 }), (e) => e.code === "permission-denied");

  await assertSucceeds(u1.doc("custom_sessions/s1").update({ currentIndex: 1 }));
  await assertFails(u2.doc("custom_sessions/s1").update({ currentIndex: 5 }));
  await assertFails(u1.doc("custom_sessions/s2").set({ profileId: "u1" })); // الإنشاء من الدالة فقط
  await assertSucceeds(u1.doc("custom_sessions/s1/flashcard_ids/all_ids").get());
  await assertFails(u2.doc("custom_sessions/s1/flashcard_ids/all_ids").get());

  await assertSucceeds(u1.doc("users/u1").set({ name: "n" }));
  await assertFails(u2.doc("users/u1").get());
  await assertFails(u1.doc("purchases/u1").set({ x: 1 }));
  await env.cleanup();
});
