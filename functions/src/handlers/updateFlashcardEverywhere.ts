import {logger} from "firebase-functions";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  batchLimit,
  checkIfAdminAndThrow,
  getMissingParams,
  logBatchMessage,
  updatePackTagCounts,
} from "../utils/utils";
import {
  DocumentReference,
  DocumentSnapshot,
  getFirestore,
  QuerySnapshot,
} from "firebase-admin/firestore";
import {getFlashcard, getPack} from "./deleteFlashcardEverywhere";
import {CloudStorageService} from "../services/cloudStorageService";
import {getDownloadURL} from "firebase-admin/storage";

type UpdateFlashcardDto = {
  question: string | undefined;
  answer: string | undefined;
  tags: string[] | undefined;
};

export const updateFlashcardEverywhereHandler = async (
  request: CallableRequest,
) => {
  try {
    checkIfAdminAndThrow(request.auth);

    const flashcardId: string | undefined = request.data.flashcardId;
    const updateDto: UpdateFlashcardDto | undefined =
      request.data.updateFlashcardDto;
    const shouldDeleteAnswer: boolean | undefined =
      request.data.shouldDeleteAnswer;
    const shouldDeleteQuestion: boolean | undefined =
      request.data.shouldDeleteQuestion;
    const answerImageBase64: string | undefined =
      request.data.answerImageBase64;
    const questionImageBase64: string | undefined =
      request.data.questionImageBase64;
    if (
      !flashcardId ||
      !updateDto ||
      shouldDeleteAnswer === undefined ||
      shouldDeleteQuestion === undefined
    ) {
      const mess = getMissingParams({
        flashcardId,
        updateDto,
        shouldDeleteAnswer,
        shouldDeleteQuestion,
      });
      logger.error(`Missing required argument: ${mess}`);
      throw new HttpsError(
        "invalid-argument",
        `Missing required argument: ${mess}`,
      );
    }

    if (
      !updateDto.answer &&
      !updateDto.question &&
      !updateDto.tags &&
      !shouldDeleteAnswer &&
      !shouldDeleteQuestion &&
      !answerImageBase64 &&
      !questionImageBase64
    ) {
      logger.error("Empty update flashcard dto object sent, nothing to update");
      throw new HttpsError("invalid-argument", "Nothing to update");
    }

    const flashcardSnapshot = await doesFlashcardExists(flashcardId);

    await deleteFlashcardImages(
      flashcardId,
      shouldDeleteQuestion,
      shouldDeleteAnswer,
    );
    const {answerImageUrl, questionImageUrl} =
      await uploadImagesAndGetDownloadUrls(
        flashcardId,
        answerImageBase64,
        questionImageBase64,
        shouldDeleteAnswer,
        shouldDeleteQuestion,
      );

    await updateFlashcardSnapshots(
      flashcardId,
      updateDto,
      answerImageUrl,
      questionImageUrl,
    );
    await updateFlashcardSnapshotReport(
      flashcardId,
      updateDto,
      answerImageUrl,
      questionImageUrl,
    );

    if (updateDto.tags) {
      await updateFlashcardAndPack(
        flashcardId,
        updateDto,
        answerImageUrl,
        questionImageUrl,
      );
    } else {
      // If no tags are updated, just update the flashcard itself
      await updateFlashcard(
        flashcardSnapshot!.ref,
        updateDto,
        answerImageUrl,
        questionImageUrl,
      );
    }
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;

    logger.error("UpdateFlashcardEverywhere failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }
};

async function uploadImagesAndGetDownloadUrls(
  flashcardId: string,
  answerImageBase64: string | undefined,
  questionImageBase64: string | undefined,
  shouldDeleteAnswer: boolean,
  shouldDeleteQuestion: boolean,
): Promise<{
  answerImageUrl: string | undefined | null;
  questionImageUrl: string | undefined | null;
}> {
  let answerImageUrl: string | undefined | null;
  let questionImageUrl: string | undefined | null;
  if (!answerImageBase64) answerImageUrl = undefined;
  if (!questionImageBase64) questionImageUrl = undefined;
  if (shouldDeleteAnswer) answerImageUrl = null;
  if (shouldDeleteQuestion) questionImageUrl = null;

  const storage = CloudStorageService.instance;
  if (answerImageBase64) {
    const answerRef = storage.getFlashcardAnswerImageRef(flashcardId);
    const answerBuffer = Buffer.from(answerImageBase64, "base64");
    await answerRef.save(answerBuffer, {
      contentType: "application/octet-stream",
    });
    answerImageUrl = await getDownloadURL(answerRef);
  }

  if (questionImageBase64) {
    const questionRef = storage.getFlashcardQuestionImageRef(flashcardId);
    const questionBuffer = Buffer.from(questionImageBase64, "base64");
    await questionRef.save(questionBuffer, {
      contentType: "application/octet-stream",
    });
    questionImageUrl = await getDownloadURL(questionRef);
  }

  return {answerImageUrl, questionImageUrl};
}

async function deleteFlashcardImages(
  flashcardId: string,
  shouldDeleteQuestion: boolean,
  shouldDeleteAnswer: boolean,
) {
  const storage = CloudStorageService.instance;

  if (shouldDeleteAnswer) {
    const answerRef = storage.getFlashcardAnswerImageRef(flashcardId);
    const [answerExists] = await answerRef.exists();
    if (answerExists) {
      await answerRef.delete();
      logger.info("Deleted flashcard answer image", {flashcardId});
    }
  }

  if (shouldDeleteQuestion) {
    const questionRef = storage.getFlashcardQuestionImageRef(flashcardId);
    const [questionExists] = await questionRef.exists();
    if (questionExists) {
      await questionRef.delete();
      logger.info("Deleted flashcard question image", {flashcardId});
    }
  }
}

export async function doesFlashcardExists(
  flashcardId: string,
): Promise<DocumentSnapshot | undefined> {
  const query = getFirestore().collection("flashcards").doc(flashcardId);

  const snapshot = await query.get();
  if (!snapshot.exists) {
    logger.error("Flashcard doesn't exists", {flashcardId});
    throw new HttpsError("not-found", "Flashcard doesn't exists");
  }

  return snapshot;
}

async function updateFlashcardSnapshots(
  flashcardId: string,
  updateDto: UpdateFlashcardDto,
  answerImageUrl: string | undefined | null,
  questionImageUrl: string | undefined | null,
) {
  let query = getFirestore()
    .collection("fcp_data")
    .where("flashcardId", "==", flashcardId)
    .orderBy("__name__")
    .limit(batchLimit);
  let snapshot: QuerySnapshot;
  let lastDoc = null;
  let updateCount = 0;
  do {
    if (lastDoc) {
      query = query.startAfter(lastDoc);
    }

    snapshot = await query.get();
    if (snapshot.empty) {
      logger.info("No more documents to update from fcp_data", {flashcardId});
      break;
    }

    logBatchMessage("Updating", snapshot.size, "fcp_data", updateCount, {
      flashcardId,
    });

    const batch = getFirestore().batch();
    snapshot.docs.forEach((doc) => {
      const updateData: Record<string, any> = {};
      if (updateDto.question !== undefined) {
        updateData["flashcardSnapshot.question"] = updateDto.question;
      }
      if (updateDto.answer !== undefined) {
        updateData["flashcardSnapshot.answer"] = updateDto.answer;
      }
      if (updateDto.tags !== undefined) {
        updateData["flashcardSnapshot.tags"] = updateDto.tags;
      }
      if (answerImageUrl !== undefined) {
        updateData["flashcardSnapshot.answerImageUrl"] = answerImageUrl;
      }
      if (questionImageUrl !== undefined) {
        updateData["flashcardSnapshot.questionImageUrl"] = questionImageUrl;
      }

      batch.update(doc.ref, updateData);
      updateCount++;
    });
    await batch.commit();

    lastDoc = snapshot.docs[snapshot.docs.length - 1];
  } while (!snapshot.empty);
  logger.info("Successfully update all queried documents from fcp_data", {
    docsUpdateCount: updateCount,
  });
}

async function updateFlashcard(
  flashcardRef: DocumentReference,
  updateDto: UpdateFlashcardDto,
  answerImageUrl: string | undefined | null = undefined,
  questionImageUrl: string | undefined | null = undefined,
) {
  const dtoToUpdate: any = {...updateDto};

  if (questionImageUrl !== undefined) {
    dtoToUpdate.questionImageUrl = questionImageUrl;
  }

  if (answerImageUrl !== undefined) {
    dtoToUpdate.answerImageUrl = answerImageUrl;
  }

  await flashcardRef.update(dtoToUpdate);
  logger.info("Successfully updated flashcard", {docPath: flashcardRef.path});
}

async function updateFlashcardAndPack(
  flashcardId: string,
  updateDto: UpdateFlashcardDto,
  questionImageUrl: string | undefined | null,
  answerImageUrl: string | undefined | null,
) {
  const db = getFirestore();
  // mora transakcija
  await db.runTransaction(async (transaction) => {
    const flashcardRef = db.collection("flashcards").doc(flashcardId);

    const flashcard = await getFlashcard(flashcardRef, transaction);
    const packId = flashcard.packId;

    const packRef = db.collection("packs").doc(packId);
    const pack = await getPack(packRef, transaction, flashcardId);

    const tagCounts: Record<string, number> = pack.tagCounts;
    const newTagCounts = updatePackTagCounts(
      tagCounts,
      flashcard.tags,
      updateDto.tags!,
    );
    const tags = Object.keys(newTagCounts);

    transaction.update(packRef, {tagCounts: newTagCounts, tags});

    const dtoToUpdate: any = {...updateDto};

    if (questionImageUrl !== undefined) {
      dtoToUpdate.questionImageUrl = questionImageUrl;
    }

    if (answerImageUrl !== undefined) {
      dtoToUpdate.answerImageUrl = answerImageUrl;
    }
    // update flashcard
    transaction.update(flashcardRef, dtoToUpdate);
  });
  logger.info("Successfully updated flaschard and updated pack tag counts", {
    flashcardId,
  });
}

async function updateFlashcardSnapshotReport(
  flashcardId: string,
  updateDto: UpdateFlashcardDto,
  answerImageUrl: string | undefined | null,
  questionImageUrl: string | undefined | null,
) {
  logger.info("Updating flashcard report document", {flashcardId});
  const query = getFirestore().collection("flashcard_reports").doc(flashcardId);

  const snapshot = await query.get();

  if (!snapshot.exists) {
    logger.info("No flashcard report document to update", {flashcardId});
    return;
  }

  const updateData: Record<string, any> = {};
  if (updateDto.question !== undefined) {
    updateData["flashcardSnapshot.question"] = updateDto.question;
  }
  if (updateDto.answer !== undefined) {
    updateData["flashcardSnapshot.answer"] = updateDto.answer;
  }
  if (updateDto.tags !== undefined) {
    updateData["flashcardSnapshot.tags"] = updateDto.tags;
  }
  if (answerImageUrl !== undefined) {
    updateData["flashcardSnapshot.answerImageUrl"] = answerImageUrl;
  }
  if (questionImageUrl !== undefined) {
    updateData["flashcardSnapshot.questionImageUrl"] = questionImageUrl;
  }

  query.update(updateData);

  logger.info("Successfully updated flashcard report document", {
    docPath: query.path,
  });
}
