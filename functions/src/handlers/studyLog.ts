import {logger} from "firebase-functions";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {FieldValue, getFirestore, Timestamp} from "firebase-admin/firestore";
import {checkAuthAndThrow} from "../utils/utils";

/** Largest study history accepted from one device (characters). */
const maxLogLength = 300000;
/** Devices kept per user; the ones not used for longest are dropped. */
const maxDevices = 8;

type DeviceEntry = {log: string; updatedAt: Timestamp};

/**
 * The caller's study history document.
 * @param {string} uid The user's id.
 * @return {FirebaseFirestore.DocumentReference} The document.
 */
function studyLogDoc(uid: string) {
  return getFirestore()
    .collection("users").doc(uid)
    .collection("progress").doc("study_log");
}

/**
 * Checks a device id sent by the app.
 * @param {unknown} value The id.
 * @return {string} The id.
 */
function parseDeviceId(value: unknown): string {
  if (typeof value !== "string" || !/^[A-Za-z0-9_-]{6,64}$/.test(value)) {
    throw new HttpsError("invalid-argument", "Invalid device id.");
  }
  return value;
}

/**
 * Saves the study history recorded on one device, and optionally the goal.
 * Each device keeps its own entry so nothing is counted twice.
 * @param {CallableRequest} request Has deviceId, log and optional goal.
 * @return {Promise<{saved: boolean}>} Done.
 */
export async function saveStudyLogHandler(request: CallableRequest) {
  try {
    checkAuthAndThrow(request.auth);
    const deviceId = parseDeviceId(request.data?.deviceId);
    const log = request.data?.log;
    if (typeof log !== "string" || log.length > maxLogLength) {
      throw new HttpsError("invalid-argument", "Invalid study history.");
    }
    const goal = request.data?.goal;
    if (goal !== undefined && (typeof goal !== "string" || goal.length > 2000)) {
      throw new HttpsError("invalid-argument", "Invalid goal.");
    }

    const ref = studyLogDoc(request.auth!.uid);
    await getFirestore().runTransaction(async (tx) => {
      const snapshot = await tx.get(ref);
      const devices = (snapshot.data()?.devices ?? {}) as
        Record<string, DeviceEntry>;
      const update: Record<string, FirebaseFirestore.FieldValue | object> = {
        [`devices.${deviceId}`]: {log, updatedAt: Timestamp.now()},
      };
      const others = Object.entries(devices)
        .filter(([id]) => id !== deviceId)
        .sort((a, b) =>
          (b[1].updatedAt?.toMillis() ?? 0) - (a[1].updatedAt?.toMillis() ?? 0));
      for (const [id] of others.slice(maxDevices - 1)) {
        update[`devices.${id}`] = FieldValue.delete();
      }
      if (typeof goal === "string") {
        update.goal = {value: goal, updatedAt: Timestamp.now()};
      }
      if (snapshot.exists) {
        tx.update(ref, update);
      } else {
        tx.set(ref, {
          devices: {[deviceId]: {log, updatedAt: Timestamp.now()}},
          ...(typeof goal === "string" ?
            {goal: {value: goal, updatedAt: Timestamp.now()}} : {}),
        });
      }
    });
    return {saved: true};
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;
    logger.error("saveStudyLog failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }
}

/**
 * Returns the study history of all the caller's devices and the goal.
 * @param {CallableRequest} request No data needed.
 * @return {Promise<object>} The devices map and the goal (or null).
 */
export async function getStudyLogHandler(request: CallableRequest) {
  try {
    checkAuthAndThrow(request.auth);
    const snapshot = await studyLogDoc(request.auth!.uid).get();
    const data = snapshot.data() ?? {};
    const devices: Record<string, string> = {};
    for (const [id, entry] of Object.entries(
      (data.devices ?? {}) as Record<string, DeviceEntry>)) {
      if (typeof entry?.log === "string") devices[id] = entry.log;
    }
    const goal = typeof data.goal?.value === "string" ? data.goal.value : null;
    return {devices, goal};
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;
    logger.error("getStudyLog failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }
}
