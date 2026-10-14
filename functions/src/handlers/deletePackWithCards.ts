import {logger} from "firebase-functions";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {getFirestore, Query} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {checkIfAdminAndThrow} from "../utils/utils";

/**
 * Deletes a pack together with everything that belongs to it: its
 * flashcards, their images and reports, every user's progress on them
 * (fcp_data), pack progress (pp_data) and the pack's flashcard id list.
 * Unlike deletePackEverywhereIfEmpty, the pack doesn't have to be empty.
 * Custom sessions that contained these cards skip them when studied.
 * @param {CallableRequest} request Has the packId.
 * @return {Promise<object>} How many flashcards were deleted.
 */
export async function deletePackWithCardsHandler(request: CallableRequest) {
  try {
    checkIfAdminAndThrow(request.auth);

    const packId: string | undefined = request.data?.packId;
    if (!packId) {
      throw new HttpsError("invalid-argument", "Missing required parameter: packId");
    }

    const db = getFirestore();
    const packRef = db.collection("packs").doc(packId);
    if (!(await packRef.get()).exists) {
      throw new HttpsError("not-found", "This pack no longer exists.");
    }

    const cards = await db.collection("flashcards").where("packId", "==", packId).get();
    const cardIds = cards.docs.map((doc) => doc.id);
    logger.info(`Deleting pack ${packId} with ${cardIds.length} flashcards`);

    // Images live at flashcards/{flashcardId}/question.jpg and answer.jpg.
    // Only cards that have one are touched: checking every card one by one
    // made large packs take longer than the function may run.
    const bucket = getStorage().bucket();
    const imagePaths: string[] = [];
    for (const doc of cards.docs) {
      const data = doc.data();
      if (data.questionImageUrl) imagePaths.push(`flashcards/${doc.id}/question.jpg`);
      if (data.answerImageUrl) imagePaths.push(`flashcards/${doc.id}/answer.jpg`);
    }
    await inChunks(imagePaths, 100, (path) =>
      bucket.file(path).delete({ignoreNotFound: true}).catch((error) =>
        logger.warn("Image not deleted", {path, error: String(error)})),
    );

    // Reports of these cards (with their user_reports), found in one query.
    const reports = await db.collection("flashcard_reports")
      .where("flashcardSnapshot.packId", "==", packId).get();
    await inChunks(reports.docs, 20, (doc) => db.recursiveDelete(doc.ref));

    const progress = await deleteMatching(
      db.collection("fcp_data").where("flashcardSnapshot.packId", "==", packId),
    );
    const packProgress = await deleteMatching(
      db.collection("pp_data").where("packId", "==", packId),
    );

    const writer = db.bulkWriter();
    for (const doc of cards.docs) writer.delete(doc.ref);
    await writer.close();

    // The pack and its flashcard_ids subcollection.
    await db.recursiveDelete(packRef);

    logger.info(`Deleted pack ${packId}`, {
      flashcards: cardIds.length,
      progress,
      packProgress,
    });
    return {flashcards: cardIds.length};
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;

    logger.error("deletePackWithCardsHandler failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }
}

async function deleteMatching(query: Query): Promise<number> {
  const snapshot = await query.get();
  const writer = getFirestore().bulkWriter();
  for (const doc of snapshot.docs) writer.delete(doc.ref);
  await writer.close();
  return snapshot.size;
}

async function inChunks<T>(
  items: T[],
  size: number,
  action: (item: T) => Promise<unknown>,
) {
  for (let i = 0; i < items.length; i += size) {
    await Promise.all(items.slice(i, i + size).map(action));
  }
}
