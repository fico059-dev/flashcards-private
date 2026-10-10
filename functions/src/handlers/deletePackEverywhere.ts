import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  batchLimit,
  checkIfAdminAndThrow,
  logBatchMessage,
} from "../utils/utils";
import {logger} from "firebase-functions";
import {
  DocumentReference,
  DocumentSnapshot,
  getFirestore,
  QuerySnapshot,
} from "firebase-admin/firestore";
import {doesPackExist} from "./renamePackEverywhere";
import {
  getPackFlashcardIds,
  getPackFlashcardIdsRef,
} from "./deleteFlashcardEverywhere";

export async function deletePackEverywhereHandler(request: CallableRequest) {
  try {
    checkIfAdminAndThrow(request.auth);

    const packId: string | undefined = request.data.packId;
    if (!packId) {
      logger.error("Missing required parameter: packId");
      throw new HttpsError(
        "invalid-argument",
        "Missing required parameter: packId",
      );
    }

    // create pack reference
    // and check if pack exists and if it's empty
    const packSnapshot = await doesPackExistAndIsEmpty(packId);

    // delete all pp data for that pack
    await deleteAllPpDataForPack(packId);

    // delete the pack
    await deletePack(packSnapshot!.ref);
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;

    logger.error("DeletePackEverywhereHandler failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }
}

async function doesPackExistAndIsEmpty(
  packId: string,
): Promise<DocumentSnapshot | undefined> {
  const packSnapshot = await doesPackExist(packId);
  const flashcardIds = await getPackFlashcardIds(packId);

  if (flashcardIds.length != 0) {
    logger.error(
      "Provided pack is not empty, pack can only be deleted if it's empty",
    );
    throw new HttpsError("invalid-argument", "Only empty packs can be deleted");
  }

  return packSnapshot!;
}

async function deleteAllPpDataForPack(packId: string) {
  const query = getFirestore()
    .collection("pp_data")
    .where("packId", "==", packId)
    .limit(batchLimit);

  let deleteCount = 0;
  let snapshot: QuerySnapshot;
  do {
    snapshot = await query.get();
    if (snapshot.empty) {
      logger.info("No more documents to delete from pp_data", {packId});
      break;
    }

    logBatchMessage("Deleting", snapshot.size, "pp_data", deleteCount, {
      packId,
    });

    const batch = getFirestore().batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
      deleteCount++;
    });

    await batch.commit();
  } while (!snapshot.empty);

  logger.info("Successfully deleted all queried documents from pp_data", {
    docsDelteCount: deleteCount,
  });
}

async function deletePack(packRef: DocumentReference) {
  const batch = getFirestore().batch();
  const flashcardIdsRef = getPackFlashcardIdsRef(packRef.id);

  batch.delete(packRef);
  batch.delete(flashcardIdsRef);

  await batch.commit();
  logger.info("Successfully deleted pack and its flashcard IDs reference", {
    packId: packRef.id,
  });
}
