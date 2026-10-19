import {HttpsError} from "firebase-functions/v2/https";
import {google} from "googleapis";
import type {androidpublisher_v3 as AndroidPublisherV3} from "googleapis";
import {mapSubscriptionToEntitlement} from "./mapping";
import {setUserEntitlements, upsertPurchaseDoc} from "./claims";

export const ANDROID_PACKAGE =
  process.env.ANDROID_PACKAGE || "com.stz.flashcards";

export function parseExpiryMs(expiry?: string | null): number | null {
  if (!expiry) return null;
  const n = Number(expiry);
  if (!Number.isNaN(n) && n > 0) return n;
  const t = Date.parse(expiry);
  return Number.isNaN(t) ? null : t;
}

export async function verifyAndroid(purchaseToken: string, uid: string) {
  const auth = await google.auth.getClient({
    scopes: ["https://www.googleapis.com/auth/androidpublisher"],
  });
  const androidpublisher = google.androidpublisher({version: "v3", auth});

  let sub: any;
  try {
    const res = await androidpublisher.purchases.subscriptionsv2.get({
      packageName: ANDROID_PACKAGE,
      token: purchaseToken,
    });
    sub = res.data;
  } catch (e) {
    console.error("AndroidPublisher API error", e);
    throw new HttpsError("internal", "Google API error");
  }

  const line = sub?.lineItems?.[0] as
    | AndroidPublisherV3.Schema$SubscriptionPurchaseLineItem
    | undefined;

  const expiryMs = parseExpiryMs(line?.expiryTime);
  const subscriptionId = line?.productId || "unknown";
  const basePlanId = (line as any)?.offerDetails?.basePlanId ?? null;

  const entitlement = mapSubscriptionToEntitlement({
    subscriptionId,
    basePlanId,
  });

  type Status = "active" | "expired" | "canceled" | "pending" | "unknown";
  const state: number | undefined = (line as any)?.subscriptionState;

  function statusFromState(s?: number): Status | null {
    switch (s) {
    case 1:
      return "active";
    case 2:
    case 3:
    case 4:
      return "pending";
    case 5:
      return "canceled";
    case 6:
      return "expired";
    default:
      return null;
    }
  }

  const status: Status =
    statusFromState(state) ??
    (typeof expiryMs === "number" ?
      expiryMs > Date.now() ?
        "active" :
        "expired" :
      "unknown");

  await upsertPurchaseDoc({
    uid,
    platform: "android",
    purchaseToken,
    subscriptionId,
    basePlanId,
    entitlement,
    expiryTimeMillis: expiryMs ?? null,
    status,
  });

  if (entitlement && status === "active" && typeof expiryMs === "number") {
    await setUserEntitlements({
      uid,
      entitlement,
      expiresAtMillis: expiryMs,
    });
  }

  return {success: true, status, entitlement, exp: expiryMs ?? null};
}
