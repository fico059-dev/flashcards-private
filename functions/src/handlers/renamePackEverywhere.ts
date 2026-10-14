import {logger} from "firebase-functions";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  batchLimit,
  checkIfAdminAndThrow,
  getMissingParams,
  logBatchMessage,
} from "../utils/utils";
import {
  DocumentReference,
  DocumentSnapshot,
  getFirestore,
} from "firebase-admin/firestore";

export async function renamePackEverywhereHandler(request: CallableRequest) {
  try {
    checkIfAdminAndThrow(request.auth);

    const packId: string | undefined = request.data.packId;
    const packName: string | undefined = request.data.packName;
    if (!packId || !packName) {
      const missingParameters = getMissingParams({packId, packName});
      logger.error(`Missing required parameter: ${missingParameters}`);
      throw new HttpsError(
        "invalid-argument",
        `Missing required parameter: ${missingParameters}`,
      );
    }

    const packSnapshot = await doesPackExist(packId);
    await changePackNameFromPpData(packId, packName);
    await changePackNameFromReport(packId, packName);
    await renamePack(packSnapshot!.ref, packName);
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;

    logger.error("RenamePackEverywhere failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }
}

export async function doesPackExist(
  packId: string,
): Promise<DocumentSnapshot | undefined> {
  const ref = getFirestore().collection("packs").doc(packId);

  const doc = await ref.get();
  if (!doc.exists) {
    logger.error("Pack document doesn't exists", {packId, docPath: ref.path});
    throw new HttpsError("not-found", "Pack document does not exist.");
  }

  return doc;
}

async function renamePack(packRef: DocumentReference, packName: string) {
  await packRef.update({name: packName});
  logger.info("Successfully renamed pack document", {docPath: packRef.path});
}

async function changePackNameFromPpData(packId: string, packName: string) {
  let lastDoc;
  const batchSize = batchLimit;
  let updateCount = 0;
  let snapshot;
  do {
    let query = getFirestore()
      .collection("pp_data")
      .where("packId", "==", packId)
      .orderBy("__name__")
      .limit(batchSize);

    if (lastDoc) {
      // logger.info("Found more than 500 docs to update", {lastDoc});
      query = query.startAfter(lastDoc);
    }

    snapshot = await query.get();
    if (snapshot.empty) {
      logger.info("No more documents to update from pp_data", {packId});
      break;
    }

    logBatchMessage("Updating", snapshot.size, "pp_data", updateCount, {
      packId,
    });

    const batch = getFirestore().batch();
    snapshot.docs.forEach((doc) => {
      batch.update(doc.ref, {packName: packName});
      updateCount++;
    });
    await batch.commit();

    lastDoc = snapshot.docs[snapshot.docs.length - 1];
  } while (!snapshot.empty);
  logger.info("Successfully updated all queried documents from pp_data", {
    docsUpdatedCount: updateCount,
  });
}

async function changePackNameFromReport(packId: string, packName: string) {
  let lastDoc = null;
  const batchSize = batchLimit;
  let updateCount = 0;
  let snapshot;
  do {
    logger.info("Starting new batch to update flashcard_reports", {lastDoc});
    let query = getFirestore()
      .collection("flashcard_reports")
      .where("flashcardSnapshot.packId", "==", packId)
      .orderBy("__name__")
      .limit(batchSize);

    if (lastDoc) {
      logger.info("Found more than 500 docs to update", {lastDoc});
      query = query.startAfter(lastDoc);
    }

    snapshot = await query.get();
    if (snapshot.empty) {
      logger.info("No more documents to update from flashcard_reports", {
        packId,
      });
      break;
    }

    logBatchMessage(
      "Updating",
      snapshot.size,
      "flashcard_reports",
      updateCount,
      {packId},
    );

    const batch = getFirestore().batch();
    snapshot.docs.forEach((doc) => {
      batch.update(doc.ref, {packName: packName});
      updateCount++;
    });
    await batch.commit();

    lastDoc = snapshot.docs[snapshot.docs.length - 1];
  } while (!snapshot.empty);
  logger.info(
    "Successfully updated all queried documents from flashcard_reports",
    {docsUpdatedCount: updateCount},
  );
}
