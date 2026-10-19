const { HttpsError } = require("firebase-functions/v2/https");
const { getAuth } = require("firebase-admin/auth");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const { GoogleAuth } = require("google-auth-library");

/** يثبّت وقت انتهاء الاشتراك في claims المستخدم ويحفظ سجلاً بالعملية. */
async function grantPremium(uid, expiresAtMs, meta) {
  const auth = getAuth();
  const user = await auth.getUser(uid);
  const claims = user.customClaims ?? {};
  const current = Number(claims.premiumExp ?? 0);
  const currentMs = current && current < 1e12 ? current * 1000 : current;
  const premiumExp = Math.max(currentMs, expiresAtMs);
  await auth.setCustomUserClaims(uid, { ...claims, premiumExp });
  await getFirestore()
    .collection("purchases")
    .doc(uid)
    .set(
      { ...meta, uid, premiumExp: Timestamp.fromMillis(premiumExp), updatedAt: Timestamp.now() },
      { merge: true },
    );
  return premiumExp;
}

async function verifyGooglePlay({ productId, purchaseToken }) {
  const packageName = process.env.ANDROID_PACKAGE_NAME || "sa.taqdir.app";
  const auth = new GoogleAuth({ scopes: ["https://www.googleapis.com/auth/androidpublisher"] });
  const client = await auth.getClient();
  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/` +
    `${encodeURIComponent(packageName)}/purchases/subscriptionsv2/tokens/${encodeURIComponent(purchaseToken)}`;
  const res = await client.request({ url });
  const data = res.data;
  const active = ["SUBSCRIPTION_STATE_ACTIVE", "SUBSCRIPTION_STATE_IN_GRACE_PERIOD"].includes(
    data.subscriptionState,
  );
  const item = (data.lineItems ?? []).find((i) => i.productId === productId) ?? data.lineItems?.[0];
  const expiresAtMs = item?.expiryTime ? Date.parse(item.expiryTime) : 0;
  if (!active || !expiresAtMs || expiresAtMs < Date.now()) {
    throw new HttpsError("failed-precondition", "الاشتراك غير فعّال.");
  }
  return { expiresAtMs, store: "google_play", productId };
}

async function callApple(url, receipt) {
  const res = await fetch(url, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      "receipt-data": receipt,
      password: process.env.APPLE_SHARED_SECRET,
      "exclude-old-transactions": true,
    }),
  });
  return res.json();
}

async function verifyAppStore({ productId, receipt }) {
  if (!process.env.APPLE_SHARED_SECRET) {
    throw new HttpsError("failed-precondition", "لم يتم ضبط APPLE_SHARED_SECRET.");
  }
  let data = await callApple("https://buy.itunes.apple.com/verifyReceipt", receipt);
  if (data.status === 21007) {
    data = await callApple("https://sandbox.itunes.apple.com/verifyReceipt", receipt);
  }
  if (data.status !== 0) {
    throw new HttpsError("failed-precondition", `رفض App Store الإيصال (status ${data.status}).`);
  }
  const infos = (data.latest_receipt_info ?? []).filter((i) => i.product_id === productId);
  const expiresAtMs = Math.max(0, ...infos.map((i) => Number(i.expires_date_ms ?? 0)));
  if (!expiresAtMs || expiresAtMs < Date.now()) {
    throw new HttpsError("failed-precondition", "الاشتراك غير فعّال.");
  }
  return { expiresAtMs, store: "app_store", productId };
}

module.exports = { grantPremium, verifyGooglePlay, verifyAppStore };
