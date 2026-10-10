import {logger} from "firebase-functions/v2";
import {batchLimit, checkAuthAndThrow} from "../utils/utils";
import {getFirestore, QuerySnapshot} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";

export async function deleteUserAndUserDataHandler(request: CallableRequest) {
  try {
    const {auth} = request;
    checkAuthAndThrow(auth);

    // delete user custom sessions (profileId field)
    await deleteUserCusttomSessions(auth.uid);

    // delete fcp_data documents
    await deleteFcpDataDocuments(auth.uid);

    // delete pp_data documents
    await deletePpDataDocuments(auth.uid);

    // delete user subcollections (osce performances and osce attempts for each performance)
    await deleteOscePerformancesAndAttempts(auth.uid);

    // do something with subscriptions?

    // delete profile document and auth user record
    await deleteProfileAndUserRecord(auth.uid);

    getAuth().revokeRefreshTokens(auth.uid);

    logger.info("Successfully deleted user and all associated data", {
      uid: auth.uid,
    });

    return {success: true};
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;
    logger.error("deleteUserandUserData failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }
}

async function deleteUserCusttomSessions(uid: string) {
  // limit is 250 since we delete the subcollection document as well
  const query = getFirestore()
    .collection("custom_sessions")
    .where("profileId", "==", uid)
    .limit(batchLimit / 2);
  let deleteCount = 0;
  let snapshot: QuerySnapshot;
  do {
    snapshot = await query.get();
    if (snapshot.empty) {
      logger.info("No more documents to delete from custom_sessions", {uid});
      break;
    }

    const batch = getFirestore().batch();
    snapshot.docs.forEach((doc) => {
      // custom session has subcollection with one document that has all flashcardIds
      const subcollectionRef = doc.ref
        .collection("flashcard_ids")
        .doc("all_ids");
      batch.delete(subcollectionRef);

      batch.delete(doc.ref);
      deleteCount++;
    });

    await batch.commit();
  } while (!snapshot.empty);

  logger.info(`Deleted ${deleteCount} documents from custom_sessions`, {uid});
}

async function deleteFcpDataDocuments(uid: string) {
  const query = getFirestore()
    .collection("fcp_data")
    .where("profileId", "==", uid)
    .limit(batchLimit);
  let deleteCount = 0;
  let snapshot: QuerySnapshot;

  do {
    snapshot = await query.get();
    if (snapshot.empty) {
      logger.info("No more documents to delete from fcp_data", {uid});
      break;
    }

    const batch = getFirestore().batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
      deleteCount++;
    });

    await batch.commit();
  } while (!snapshot.empty);
  logger.info(`Deleted ${deleteCount} documents from fcp_data`, {uid});
}

async function deletePpDataDocuments(uid: string) {
  const query = getFirestore()
    .collection("pp_data")
    .where("profileId", "==", uid)
    .limit(batchLimit);
  let deleteCount = 0;
  let snapshot: QuerySnapshot;

  do {
    snapshot = await query.get();
    if (snapshot.empty) {
      logger.info("No more documents to delete from pp_data", {uid});
      break;
    }

    const batch = getFirestore().batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
      deleteCount++;
    });

    await batch.commit();
  } while (!snapshot.empty);
  logger.info(`Deleted ${deleteCount} documents from pp_data`, {uid});
}

async function deleteOscePerformancesAndAttempts(uid: string) {
  // so, the limit for the batch is 500, each osce performance can have up to 50 attempts, so 51 documents max per performance to delete at once
  // so we limit the query to 9 performances at once
  // 9 * 51 = 459, so we are well within the limit
  const query = getFirestore()
    .collection("users")
    .doc(uid)
    .collection("osce_performance")
    .limit(9);
  let performanceDeleteCount = 0;
  let attemptDeleteCount = 0;
  let snapshot: QuerySnapshot;
  do {
    snapshot = await query.get();
    if (snapshot.empty) {
      logger.info("No more documents to delete from osce_performances", {
        uid,
      });
      break;
    }

    const batch = getFirestore().batch();
    for (const doc of snapshot.docs) {
      const attemptsSnapshot = await doc.ref.collection("osce_attempts").get();
      attemptsSnapshot.docs.forEach((attemptDoc) => {
        batch.delete(attemptDoc.ref);
        attemptDeleteCount++;
      });
      batch.delete(doc.ref);
      performanceDeleteCount++;
    }

    await batch.commit();
  } while (!snapshot.empty);

  logger.info(
    `Deleted ${performanceDeleteCount} documents from osce_performances and ${attemptDeleteCount} documents from osce_attempts`,
    {uid},
  );
}

async function deleteProfileAndUserRecord(uid: string) {
  // delete profile document
  await getFirestore().collection("users").doc(uid).delete();

  // delete user auth record
  await getAuth().deleteUser(uid);
}
