import {logger} from "firebase-functions";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {getFirestore} from "firebase-admin/firestore";
import {checkAuthAndThrow} from "../utils/utils";
import {cleanSessionName} from "./createCustomSession";

/**
 * Renames one of the caller's own custom sessions.
 * @param {CallableRequest} request Has sessionId and the new name.
 * @return {Promise<{name: string}>} The saved name.
 */
export async function renameCustomSessionHandler(request: CallableRequest) {
  try {
    checkAuthAndThrow(request.auth);
    const uid = request.auth!.uid;

    const sessionId: unknown = request.data?.sessionId;
    if (typeof sessionId !== "string" || !sessionId) {
      throw new HttpsError("invalid-argument", "Missing required parameter: sessionId");
    }
    const name = cleanSessionName(request.data?.name);
    if (!name) {
      throw new HttpsError("invalid-argument", "Please enter a name.");
    }

    const ref = getFirestore().collection("custom_sessions").doc(sessionId);
    const snapshot = await ref.get();
    if (!snapshot.exists) {
      throw new HttpsError("not-found", "This custom session no longer exists.");
    }
    if (snapshot.get("profileId") !== uid) {
      throw new HttpsError(
        "permission-denied",
        "You can only rename your own custom sessions.",
      );
    }

    await ref.update({name});
    return {name};
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;
    logger.error("renameCustomSession failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }
}
