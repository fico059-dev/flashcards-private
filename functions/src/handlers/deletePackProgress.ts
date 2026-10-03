import {getFirestore} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {batchLimit, checkAuthAndThrow} from "../utils/utils";

const ppDataCollectionName = "pp_data";
const fcpDataCollectionName = "fcp_data";

export async function deletePackProgressHandler(request: CallableRequest) {
  try {
    const {auth, data} = request;
    checkAuthAndThrow(auth); // <-- assertions

    const packId: string = data.packId;
    const uid = auth.uid;

    if (!packId) {
      logger.error("Missing required argument: packId");
      throw new HttpsError(
        "invalid-argument",
        "Missing required argument: packId",
      );
    }

    await deletePpDataDoc(uid, packId);
    await batchDeleteDocsByPack(fcpDataCollectionName, uid, packId);

    logger.info("Succesfully deleted pack progress", {uid, packId});
    return {success: true};
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;
    logger.error("deletePackProgress failed", {error});
    throw new HttpsError("internal", error.message || "Internal server error");
  }
}

async function batchDeleteDocsByPack(
  collection: string,
  profileId: string,
  packId: string,
) {
  const limit = batchLimit;
  const db = getFirestore();
  const query = db
    .collection(collection)
    .where("profileId", "==", profileId)
    .where("flashcardSnapshot.packId", "==", packId)
    .limit(limit);

  let deleteCount = 0;
  let snapshot;
  do {
    snapshot = await query.get();
    if (snapshot.empty) {
      logger.info(`No more documents to delete from ${collection}`, {
        profileId,
        packId,
      });
      break;
    }

    logger.info(`Deleting ${snapshot.size} docs from ${collection}`, {
      batch: Math.floor(deleteCount / limit) + 1,
      profileId,
      packId,
    });

    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      deleteCount++;
      batch.delete(doc.ref);
    });
    await batch.commit();
  } while (!snapshot.empty);

  logger.info(`Successfully deleted all queried documents from ${collection}`, {
    docsDeletedCount: deleteCount,
  });
}

async function deletePpDataDoc(profileId: string, packId: string) {
  const db = getFirestore();
  const id = `${profileId}_${packId}`;
  const ref = db.collection(ppDataCollectionName).doc(id);

  // logger.info("Querying records from collection path", {docPath: ref.path});

  const doc = await ref.get();
  if (!doc.exists) {
    logger.error(`${ppDataCollectionName} document does not exist`, {
      profileId,
      packId,
      docPath: ref.path,
    });
    throw new HttpsError(
      "not-found",
      `${ppDataCollectionName} document does not exist.`,
    );
  }

  // logger.info(`Deleting ${ppDataCollectionName} document`, {docPath: ref.path});
  await ref.delete();
  logger.info("Successfully deleted pp_data document", {docPath: ref.path});
}
