import * as admin from "firebase-admin";
export type Entitlement = "packs" | "osce" | "both";

function toMs(n: any): number {
  const v = Number(n || 0);
  if (!isFinite(v) || v <= 0) return 0;
  return v < 1e12 ? Math.round(v * 1000) : Math.round(v);
}

export async function setUserEntitlements(opts: {
  uid: string;
  entitlement: Entitlement;
  expiresAtMillis: number;
}) {
  const {uid, entitlement} = opts;
  const expMs = toMs(opts.expiresAtMillis);

  const user = await admin.auth().getUser(uid);
  const existing = (user.customClaims || {}) as any;

  const cur = {
    packsExp: toMs(existing.packsExp),
    osceExp: toMs(existing.osceExp),
    bothExp: toMs(existing.bothExp),
  };

  if (entitlement === "packs") cur.packsExp = Math.max(cur.packsExp, expMs);
  if (entitlement === "osce") cur.osceExp = Math.max(cur.osceExp, expMs);
  if (entitlement === "both") cur.bothExp = Math.max(cur.bothExp, expMs);

  const now = Date.now();

  const ent: Entitlement[] = [];
  if (cur.bothExp > now) ent.push("both");
  if (cur.packsExp > now) ent.push("packs");
  if (cur.osceExp > now) ent.push("osce");

  await admin.auth().setCustomUserClaims(uid, {
    ...existing,
    entitlements: ent,
    packsExp: cur.packsExp,
    osceExp: cur.osceExp,
    bothExp: cur.bothExp,
  });

  await admin.auth().revokeRefreshTokens(uid);
}

export async function clearEntitlement(opts: {
  uid: string;
  entitlement: Entitlement;
}) {
  const {uid, entitlement} = opts;
  const user = await admin.auth().getUser(uid);
  const existing = (user.customClaims || {}) as any;

  const cur = {
    packsExp: toMs(existing.packsExp),
    osceExp: toMs(existing.osceExp),
    bothExp: toMs(existing.bothExp),
  };

  if (entitlement === "packs") cur.packsExp = 0;
  if (entitlement === "osce") cur.osceExp = 0;
  if (entitlement === "both") cur.bothExp = 0;

  const now = Date.now();
  const ent: Entitlement[] = [];
  if (cur.bothExp > now) ent.push("both");
  if (cur.packsExp > now) ent.push("packs");
  if (cur.osceExp > now) ent.push("osce");

  await admin.auth().setCustomUserClaims(uid, {
    ...existing,
    entitlements: ent,
    packsExp: cur.packsExp,
    osceExp: cur.osceExp,
    bothExp: cur.bothExp,
  });

  await admin.auth().revokeRefreshTokens(uid);
}

export async function upsertPurchaseDoc(opts: {
  uid: string;
  platform: "android";
  purchaseToken: string;
  subscriptionId: string;
  basePlanId?: string | null;
  entitlement: Entitlement | null;
  expiryTimeMillis?: number | null;
  status: "active" | "expired" | "canceled" | "pending" | "unknown";
}) {
  const {uid, ...rest} = opts;
  const ref = admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("subscriptions")
    .doc(`android_${rest.purchaseToken}`);

  await ref.set(
    {
      ...rest,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  const tokenRef = admin
    .firestore()
    .collection("android_purchase_tokens")
    .doc(rest.purchaseToken);
  await tokenRef.set(
    {uid, updatedAt: admin.firestore.FieldValue.serverTimestamp()},
    {merge: true},
  );
}
