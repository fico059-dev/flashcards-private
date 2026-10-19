import fetch from "node-fetch";
import {HttpsError} from "firebase-functions/v2/https";
import {Entitlement, mapSubscriptionToEntitlement} from "./mapping";
import {setUserEntitlements} from "./claims";
import * as admin from "firebase-admin";

const APP_BUNDLE_ID = process.env.APP_BUNDLE_ID || "com.stz.flashcards";

type AppleVerifyResp = {
  status: number;
  environment?: "Sandbox" | "Production";
  receipt?: { bundle_id?: string };
  latest_receipt_info?: Array<{
    product_id: string;
    original_transaction_id: string;
    transaction_id: string;
    expires_date_ms?: string;
    cancellation_date_ms?: string;
    purchase_date_ms?: string;
  }>;
};

async function callVerifyReceipt(
  endpoint: "prod" | "sandbox",
  receiptData: string,
): Promise<AppleVerifyResp> {
  const url =
    endpoint === "prod" ?
      "https://buy.itunes.apple.com/verifyReceipt" :
      "https://sandbox.itunes.apple.com/verifyReceipt";

  const password = process.env.APP_STORE_SHARED_SECRET;
  if (!password) {
    throw new HttpsError(
      "failed-precondition",
      "Missing APP_STORE_SHARED_SECRET",
    );
  }

  const res = await fetch(url, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({
      "receipt-data": receiptData,
      "password": password,
      "exclude-old-transactions": true,
    }),
  });

  if (!res.ok) {
    throw new HttpsError("internal", `Apple verifyReceipt HTTP ${res.status}`);
  }
  return (await res.json()) as AppleVerifyResp;
}

function pickLatest(
  entries: AppleVerifyResp["latest_receipt_info"] | undefined,
  productId: string,
) {
  if (!entries || entries.length === 0) return null;
  const filtered = entries.filter((e) => e.product_id === productId);
  if (filtered.length === 0) return null;
  filtered.sort((a, b) => {
    const ae = Number(a.expires_date_ms || a.purchase_date_ms || 0);
    const be = Number(b.expires_date_ms || b.purchase_date_ms || 0);
    return be - ae;
  });
  return filtered[0];
}

export async function verifyIos(
  receiptData: string,
  productId: string,
  uid: string,
) {
  let resp = await callVerifyReceipt("prod", receiptData);

  if (resp.status === 21007) {
    resp = await callVerifyReceipt("sandbox", receiptData);
  }

  if (resp.status !== 0) {
    throw new HttpsError(
      "invalid-argument",
      `verifyReceipt failed, status=${resp.status}`,
    );
  }

  const bundle = resp.receipt?.bundle_id;
  if (bundle && bundle !== APP_BUNDLE_ID) {
    throw new HttpsError(
      "permission-denied",
      `Bundle mismatch: ${bundle} != ${APP_BUNDLE_ID}`,
    );
  }

  const latest = pickLatest(resp.latest_receipt_info, productId);
  if (!latest) {
    throw new HttpsError(
      "not-found",
      "No matching purchase for given productId",
    );
  }

  const entitlement = mapSubscriptionToEntitlement({
    subscriptionId: latest.product_id,
    basePlanId: null,
  });

  const now = Date.now();
  const expMs = latest.expires_date_ms ?
    Number(latest.expires_date_ms) :
    undefined;
  const cancelled = latest.cancellation_date_ms ?
    Number(latest.cancellation_date_ms) :
    undefined;

  let status: "active" | "expired" | "canceled" | "pending" | "unknown" =
    "unknown";
  if (cancelled) status = "canceled";
  else if (expMs && expMs > now) status = "active";
  else if (expMs) status = "expired";
  else status = "active";

  await upsertPurchaseDocIOS({
    uid,
    transactionId: latest.original_transaction_id || latest.transaction_id,
    productId: latest.product_id,
    entitlement,
    expiryTimeMillis: expMs ?? null,
    status,
  });

  if (entitlement && status === "active") {
    await setUserEntitlements({
      uid,
      entitlement,
      expiresAtMillis: expMs ?? 0,
    });
  }

  return {success: true, status, entitlement, exp: expMs ?? null};
}

export async function upsertPurchaseDocIOS(opts: {
  uid: string;
  transactionId: string;
  productId: string;
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
    .doc(`ios_${rest.transactionId}`);

  await ref.set(
    {
      ...rest,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      platform: "ios",
    },
    {merge: true},
  );
}
