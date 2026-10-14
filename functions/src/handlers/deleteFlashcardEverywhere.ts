import {logger} from "firebase-functions";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  batchLimit,
  checkIfAdminAndThrow,
  logBatchMessage,
  updatePackTagCounts,
} from "../utils/utils";
import {
  DocumentData,
  DocumentReference,
  getFirestore,
  QuerySnapshot,
  Transaction,
} from "firebase-admin/firestore";
import {doesFlashcardExists} from "./updateFlashcardEverywhere";
import {CloudStorageService} from "../services/cloudStorageService";

type Flashcard = {
  id: string;
  packId: string;
  question: string;
  answer: string;
  tags: string[];
  answerDownloadUrl?: string;
  questionDownloadUrl?: string;
};

export async function deleteFlashcardEverywhereHandler(
  request: CallableRequest,
) {
  try {
    checkIfAdminAndThrow(request.auth);

    const flashcard: Flashcard = request.data.flashcard;
    if (!flashcard) {
      logger.error("Missing required parameter: flashcard");
      throw new HttpsError(
        "invalid-argument",
        "Missing required parameter: flashcard",
      );
    }

    await doesFlashcardExists(flashcard.id);
    await deleteAllFcpDataForFlashcard(flashcard.id);
    await deleteFlashcardReports(flashcard.id);
    await deleteFlashcardImages(flashcard.id);
    await deleteFlashcardAndRemoveFromPack(flashcard);
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;

    logger.error("DeleteFlashcardEverywhere failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }
}

async function deleteFlashcardImages(flashcardId: string) {
  const storage = CloudStorageService.instance;

  const answerRef = storage.getFlashcardAnswerImageRef(flashcardId);
  const questionRef = storage.getFlashcardQuestionImageRef(flashcardId);

  // jebo mater onom kome je palo na pamet da vrati [bool] umesto samo bool
  const [answerExists] = await answerRef.exists();
  const [questionExists] = await questionRef.exists();

  if (answerExists) {
    await answerRef.delete();
    logger.info("Deleted flashcard answer image", {flashcardId});
  }

  if (questionExists) {
    await questionRef.delete();
    logger.info("Deleted flashcard question image", {flashcardId});
  }
}

// It deletes all user reports inside flashcard report, and also flashcard report
async function deleteFlashcardReports(flashcardId: string) {
  // prvo proverimo da li postoji uopste report za ovu karticu
  logger.info("Checking if flashcard report exists", {flashcardId});
  const reportRef = getFirestore()
    .collection("flashcard_reports")
    .doc(flashcardId);

  const fcReportSnapshot = await reportRef.get();
  if (!fcReportSnapshot.exists) {
    logger.info(
      "No flashcard report found for this flashcard, nothing to delete",
      {flashcardId},
    );
    return;
  }

  // brisemo sve user reports iz subkolekcije
  const usersQuery = reportRef.collection("user_reports").limit(batchLimit);
  let deleteCount = 0;
  let snapshot: QuerySnapshot;

  do {
    snapshot = await usersQuery.get();
    if (snapshot.empty) {
      logger.info("No more documents to delete from user_reports", {
        flashcardId,
      });
      break;
    }

    logBatchMessage("Deleting", snapshot.size, "user_reports", deleteCount, {
      flashcardId,
    });

    const batch = getFirestore().batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
      deleteCount++;
    });

    await batch.commit();
  } while (!snapshot.empty);

  logger.info("Successfully deleted all queried documents from user_reports", {
    docsDeleteCount: deleteAllFcpDataForFlashcard,
  });

  // na kraju obrisemo i sam report dokument
  await reportRef.delete();
  logger.info("Deleted flashcard report document", {flashcardId});
}

async function deleteAllFcpDataForFlashcard(flashcardId: string) {
  const query = getFirestore()
    .collection("fcp_data")
    .where("flashcardId", "==", flashcardId)
    .limit(batchLimit);

  let deleteCount = 0;
  let snapshot;
  do {
    snapshot = await query.get();
    if (snapshot.empty) {
      logger.info("No more documents to delete from fcp_data", {flashcardId});
      break;
    }

    logBatchMessage("Deleting", snapshot.size, "fcp_data", deleteCount, {
      flashcardId,
    });

    const batch = getFirestore().batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
      deleteCount++;
    });
    await batch.commit();
  } while (!snapshot.empty);
  logger.info("Successfully deleted all queried documents from fcp_data", {
    docsDeletedCount: deleteCount,
  });
}

async function deleteFlashcardAndRemoveFromPack(flashcard: Flashcard) {
  const db = getFirestore();
  const flashcardId = flashcard.id;

  // mora transakcija
  await db.runTransaction(async (transaction) => {
    const flashcardRef = db.collection("flashcards").doc(flashcardId);

    const flashcard = await getFlashcard(flashcardRef, transaction);
    const packId = flashcard.packId;

    const packRef = db.collection("packs").doc(packId);
    const pack = await getPack(packRef, transaction, flashcardId);
    const flashcardIdsRef = getPackFlashcardIdsRef(packId);
    const flashcardIds = await getPackFlashcardIdsTransaction(
      packId,
      transaction,
    );

    // updatujemo tagCounts
    const tagCounts: Record<string, number> = pack.tagCounts;
    const newTagCounts: Record<string, number> = updatePackTagCounts(
      tagCounts,
      flashcard.tags,
      [],
    );

    // takodje updatujemo tags list (koristi se za indexiranje u algolia)
    const tags: string[] = Object.keys(newTagCounts);

    // izbacim id fleskartice iz peka, sacuvam prethodni redosled kartica
    logger.info("About to remove flashcardId from an array", flashcardIds);
    const fcIndex = flashcardIds.indexOf(flashcardId);
    if (fcIndex > -1) {
      flashcardIds.splice(fcIndex, 1);
      logger.info("Removed flashcardId from array", flashcardIds, flashcardId);
    }

    const flashcardsCount = pack.flashcardsCount - 1;
    // updatujem pek sa novim tagovima i smanjenim fcCounts
    transaction.update(packRef, {
      tagCounts: newTagCounts,
      tags,
      flashcardsCount,
    });

    // updatujem flashcardIds subkolekciju
    transaction.update(flashcardIdsRef, {flashcardIds});

    // obrisem karticu iz kolekcije
    transaction.delete(flashcardRef);
  });
  logger.info("Successfully deleted flaschard and removed it from a pack");
}

export async function getFlashcard(
  flashcardRef: DocumentReference,
  transaction: Transaction,
): Promise<DocumentData> {
  const fcSnapshot = await transaction.get(flashcardRef);
  if (!fcSnapshot.exists) {
    logger.error("Flashcard not found for deletion", {
      flashcardId: flashcardRef.id,
    });
    throw new HttpsError("not-found", "Flashcard not found for deletion");
  }

  return fcSnapshot.data()!;
}

export async function getPack(
  packRef: DocumentReference,
  transaction: Transaction,
  flashcardId: string,
): Promise<DocumentData> {
  const packSnapshot = await transaction.get(packRef);
  if (!packSnapshot.exists) {
    logger.error("Pack not found for removing flashcard from it", {
      flashcardId,
      packReference: packRef.id,
    });
    throw new HttpsError(
      "not-found",
      "Pack not found for removing flashcard from it",
    );
  }

  return packSnapshot.data()!;
}

export async function getPackFlashcardIdsTransaction(
  packId: string,
  transaction: Transaction,
): Promise<string[]> {
  const packIdsRef = getPackFlashcardIdsRef(packId);
  const snapshot = await transaction.get(packIdsRef);
  if (!snapshot.exists) {
    logger.error("Pack flashcard IDs not found", {packId});
    throw new HttpsError("not-found", "Pack flashcard IDs not found");
  }

  return snapshot.data()!.flashcardIds;
}

export async function getPackFlashcardIds(packId: string): Promise<string[]> {
  const packIdsRef = getPackFlashcardIdsRef(packId);
  const snapshot = await packIdsRef.get();
  if (!snapshot.exists) {
    logger.error("Pack flashcard IDs not found", {packId});
    throw new HttpsError("not-found", "Pack flashcard IDs not found");
  }

  return snapshot.data()!.flashcardIds;
}

export function getPackFlashcardIdsRef(packId: string): DocumentReference {
  return getFirestore()
    .collection("packs")
    .doc(packId)
    .collection("flashcard_ids")
    .doc("all_ids");
}
