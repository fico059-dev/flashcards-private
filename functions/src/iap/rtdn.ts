import {onMessagePublished} from "firebase-functions/v2/pubsub";
import * as admin from "firebase-admin";
import {google} from "googleapis";
import type {androidpublisher_v3 as AndroidPublisherV3} from "googleapis";
import {ANDROID_PACKAGE, parseExpiryMs} from "./android";
import {
  setUserEntitlements,
  upsertPurchaseDoc,
  clearEntitlement,
} from "./claims";
import {mapSubscriptionToEntitlement} from "./mapping";

type Status = "active" | "expired" | "canceled" | "pending" | "unknown";

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

export const playRtdn = onMessagePublished(
  {topic: "play-subs", region: "us-central1"},
  async (event) => {
    try {
      const data = event.data?.message?.json as any;

      const sn = data?.subscriptionNotification;
      const purchaseToken =
        sn?.purchaseToken || data?.oneTimeProductNotification?.purchaseToken;

      if (!purchaseToken) {
        console.log("No purchaseToken in RTDN");
        return;
      }

      const tokenDoc = await admin
        .firestore()
        .collection("android_purchase_tokens")
        .doc(purchaseToken)
        .get();
      const uid = tokenDoc.exists ? (tokenDoc.data() as any).uid : null;
      if (!uid) {
        console.log("No uid for token", purchaseToken);
        return;
      }

      const auth = await google.auth.getClient({
        scopes: ["https://www.googleapis.com/auth/androidpublisher"],
      });
      const androidpublisher = google.androidpublisher({version: "v3", auth});

      const res = await androidpublisher.purchases.subscriptionsv2.get({
        packageName: ANDROID_PACKAGE,
        token: purchaseToken,
      });

      const sub = res.data;
      const line = sub?.lineItems?.[0] as
        | AndroidPublisherV3.Schema$SubscriptionPurchaseLineItem
        | undefined;

      const expiryMs = parseExpiryMs(line?.expiryTime);
      const subscriptionId = line?.productId || "unknown";
      const basePlanId = (line as any)?.offerDetails?.basePlanId || null;

      const state: number | undefined = (line as any)?.subscriptionState;

      let status: Status = statusFromState(state) ?? "unknown";
      if (status === "unknown" && typeof expiryMs === "number") {
        status = expiryMs > Date.now() ? "active" : "expired";
      }

      const entitlement = mapSubscriptionToEntitlement({
        subscriptionId,
        basePlanId,
      });

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

      if (!entitlement) {
        console.log("Unknown entitlement for subId:", subscriptionId);
        return;
      }

      if (status === "active" && typeof expiryMs === "number") {
        await setUserEntitlements({
          uid,
          entitlement,
          expiresAtMillis: expiryMs,
        });
        return;
      }

      if (status === "expired" || status === "canceled") {
        await clearEntitlement({uid, entitlement});
        return;
      }

      console.log("RTDN no-op status:", status, "subId:", subscriptionId);
    } catch (e) {
      console.error("RTDN handler error", e);
    }
  },
);
