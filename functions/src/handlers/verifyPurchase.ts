import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {
  checkAuthAndThrow,
  setEntitlementsAndClaims,
  mapProductToScope,
} from "../utils/utils";

export async function verifyPurchaseHandler(req: CallableRequest) {
  try {
    const {auth, data} = req;
    checkAuthAndThrow(auth);
    const uid = auth.uid;

    const platform: "ios" | "android" | undefined = data?.platform;
    const productId: string | undefined = data?.productId;
    const token: string | undefined = data?.token;
    const transactionId: string | undefined = data?.transactionId;

    if (!platform || !productId) {
      throw new HttpsError(
        "invalid-argument",
        "platform and productId are required",
      );
    }

    const scope = mapProductToScope(productId);
    const isAnnual = /annual|year/i.test(productId);
    const durationMs = isAnnual ?
      365 * 24 * 60 * 60 * 1000 :
      30 * 24 * 60 * 60 * 1000;
    const expiryMs = Date.now() + durationMs;

    let cardsExp = 0;
    let osceExp = 0;
    let allExp = 0;
    if (scope === "both") allExp = expiryMs;
    else if (scope === "osce") osceExp = expiryMs;
    else cardsExp = expiryMs;

    const out = await setEntitlementsAndClaims(uid, cardsExp, osceExp, allExp);

    logger.info("verifyPurchase (DEV STUB) updated entitlements", {
      uid,
      platform,
      productId,
      tokenPresent: !!token,
      txPresent: !!transactionId,
      out,
    });

    return {success: true, scope, ...out};
  } catch (e: any) {
    if (e instanceof HttpsError) throw e;
    logger.error("verifyPurchase failed", {error: e});
    throw new HttpsError("internal", e?.message || "Internal error");
  }
}
