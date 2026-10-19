const { HttpsError } = require("firebase-functions/v2/https");
const { getFirestore } = require("firebase-admin/firestore");

const ADMIN_ROLE = "admin";
const BATCH_LIMIT = 400;

function hasAdminRole(claims) {
  return Array.isArray(claims?.roles) && claims.roles.includes(ADMIN_ROLE);
}

function requireAuth(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "سجّل الدخول أولاً.");
  }
  return request.auth.uid;
}

function requireAdmin(request) {
  const uid = requireAuth(request);
  if (!hasAdminRole(request.auth.token)) {
    throw new HttpsError("permission-denied", "هذه العملية للمشرفين فقط.");
  }
  return uid;
}

function requireString(value, name) {
  if (typeof value !== "string" || value.length === 0) {
    throw new HttpsError("invalid-argument", `الحقل ${name} مطلوب.`);
  }
  return value;
}

/** هل لدى المستخدم اشتراك مميّز فعّال (من الـ custom claims)؟ */
function hasPremium(claims) {
  if (Array.isArray(claims?.entitlements) && claims.entitlements.includes("premium")) {
    return true;
  }
  let exp = Number(claims?.premiumExp ?? 0);
  if (!exp) return false;
  if (exp < 1e12) exp *= 1000; // ثوانٍ -> مللي ثانية
  return exp > Date.now();
}

function chunk(array, size) {
  const out = [];
  for (let i = 0; i < array.length; i += size) out.push(array.slice(i, i + size));
  return out;
}

function shuffle(array) {
  const a = [...array];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

/** يحذف كل المستندات التي يرجعها الاستعلام على دفعات. يرجع عدد المحذوف. */
async function deleteByQuery(query) {
  const db = getFirestore();
  let total = 0;
  for (;;) {
    const snap = await query.limit(BATCH_LIMIT).get();
    if (snap.empty) break;
    const batch = db.batch();
    snap.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    total += snap.size;
    if (snap.size < BATCH_LIMIT) break;
  }
  return total;
}

/** يحدّث كل مستندات الاستعلام بنفس البيانات (dot-paths مسموحة) على دفعات. */
async function updateByQuery(query, data) {
  const db = getFirestore();
  let total = 0;
  let last = null;
  for (;;) {
    let q = query.orderBy("__name__").limit(BATCH_LIMIT);
    if (last) q = q.startAfter(last);
    const snap = await q.get();
    if (snap.empty) break;
    const batch = db.batch();
    snap.docs.forEach((doc) => batch.update(doc.ref, data));
    await batch.commit();
    total += snap.size;
    last = snap.docs[snap.docs.length - 1];
    if (snap.size < BATCH_LIMIT) break;
  }
  return total;
}

module.exports = {
  ADMIN_ROLE,
  hasAdminRole,
  requireAuth,
  requireAdmin,
  requireString,
  hasPremium,
  chunk,
  shuffle,
  deleteByQuery,
  updateByQuery,
};
