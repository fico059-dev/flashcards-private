import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {
  checkIfAdminAndThrow,
  setEntitlementsAndClaims,
  Scope,
} from "../utils/utils";

export async function devGrantHandler(req: CallableRequest) {
  try {
    const auth = req.auth;
    checkIfAdminAndThrow(auth); // <-- assertions

    const targetUid: string | undefined = req.data?.targetUid;
    const scope: Scope | undefined = req.data?.scope;
    const minutes = Number(req.data?.minutes ?? 120);

    if (!targetUid || !scope) {
      throw new HttpsError("invalid-argument", "Missing targetUid or scope");
    }

    const expiryMs = Date.now() + minutes * 60_000;
    let cardsExp = 0;
    let osceExp = 0;
    let allExp = 0;

    if (scope === "packs") cardsExp = expiryMs;
    if (scope === "osce") osceExp = expiryMs;
    if (scope === "both") allExp = expiryMs;

    const out = await setEntitlementsAndClaims(
      targetUid,
      cardsExp,
      osceExp,
      allExp,
    );
    logger.info("devGrant applied", {
      by: auth.uid,
      targetUid,
      scope,
      minutes,
      out,
    });
    return {success: true, ...out};
  } catch (e: any) {
    if (e instanceof HttpsError) throw e;
    logger.error("devGrant failed", {error: e});
    throw new HttpsError("internal", e?.message || "Internal error");
  }
}
