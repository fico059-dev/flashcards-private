import {onCall} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {verifyAndroid} from "./android";
import {verifyIos} from "./ios";

export const verifyPurchase = onCall({region: "us-central1"}, async (req) => {
  const ctx = req.auth;
  if (!ctx || !ctx.token?.email_verified) {
    throw new Error("permission-denied: auth required & email verified");
  }

  const uid = ctx.uid;
  const {source, productId, verificationData} = req.data as {
    source: "google_play" | "app_store";
    productId: string;
    verificationData: string;
  };

  if (!source || !verificationData) {
    throw new Error("invalid-argument: Missing source or verificationData.");
  }

  try {
    if (source === "google_play") {
      return await verifyAndroid(verificationData, uid);
    }
    if (source === "app_store") {
      return await verifyIos(verificationData, productId, uid);
    }
    throw new Error("invalid-argument: Unsupported source.");
  } catch (e) {
    logger.error("verifyPurchase error", e);
    throw new Error("internal: Verification failed");
  }
});
