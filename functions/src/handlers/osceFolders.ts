import {logger} from "firebase-functions";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {FieldValue, getFirestore, Timestamp} from "firebase-admin/firestore";
import {getDownloadURL, getStorage} from "firebase-admin/storage";
import {checkAuthAndThrow, checkIfAdminAndThrow} from "../utils/utils";

/** Speciality folders for OSCE stations; folders can be nested. */
const FOLDERS = "osce_folders";

type Folder = {id: string; name: string; parentId: string | null};

/**
 * Wraps a handler so unexpected errors reach the app with a message.
 * @param {string} name Function name for the logs.
 * @param {Function} handler The work to do.
 * @return {Function} The callable handler.
 */
function callable<T>(
  name: string,
  handler: (request: CallableRequest) => Promise<T>,
) {
  return async (request: CallableRequest): Promise<T> => {
    try {
      return await handler(request);
    } catch (error: any) {
      if (error instanceof HttpsError) throw error;
      logger.error(`${name} failed`, {error});
      throw new HttpsError("internal", error.message || "Internal error");
    }
  };
}

/**
 * Reads a required string field from the request.
 * @param {unknown} data Request data.
 * @param {string} key Field name.
 * @return {string} The trimmed value.
 */
function requireString(data: unknown, key: string): string {
  const value = (data as Record<string, unknown> | undefined)?.[key];
  if (typeof value !== "string" || !value.trim()) {
    throw new HttpsError("invalid-argument", `Missing ${key}.`);
  }
  return value.trim();
}

/**
 * Reads every folder.
 * @return {Promise<Folder[]>} All folders.
 */
async function allFolders(): Promise<Folder[]> {
  const snapshot = await getFirestore().collection(FOLDERS).get();
  return snapshot.docs.map((doc) => ({
    id: doc.id,
    name: doc.get("name") ?? "",
    parentId: doc.get("parentId") ?? null,
  }));
}

/**
 * True when [folderId] is [ancestorId] or inside it.
 * @param {Folder[]} folders All folders.
 * @param {string | null} folderId Folder to check.
 * @param {string} ancestorId Possible ancestor.
 * @return {boolean} Whether it is inside.
 */
export function isInside(
  folders: Folder[],
  folderId: string | null,
  ancestorId: string,
): boolean {
  const byId = new Map(folders.map((f) => [f.id, f]));
  let current = folderId;
  for (let depth = 0; current && depth < 100; depth++) {
    if (current === ancestorId) return true;
    current = byId.get(current)?.parentId ?? null;
  }
  return false;
}

/** Lists all folders; any signed in user. */
export const listOsceFoldersHandler = callable("listOsceFolders", async (r) => {
  checkAuthAndThrow(r.auth);
  return {folders: await allFolders()};
});

/** Creates a folder, or renames / moves one when an id is given. */
export const saveOsceFolderHandler = callable("saveOsceFolder", async (r) => {
  checkIfAdminAndThrow(r.auth);
  const name = requireString(r.data, "name").slice(0, 80);
  const id = typeof r.data?.id === "string" && r.data.id ? r.data.id : null;
  const parentId =
    typeof r.data?.parentId === "string" && r.data.parentId ?
      r.data.parentId : null;

  const db = getFirestore();
  const folders = await allFolders();
  if (parentId && !folders.some((f) => f.id === parentId)) {
    throw new HttpsError("not-found", "The parent folder no longer exists.");
  }
  if (id) {
    if (!folders.some((f) => f.id === id)) {
      throw new HttpsError("not-found", "This folder no longer exists.");
    }
    if (parentId && isInside(folders, parentId, id)) {
      throw new HttpsError(
        "invalid-argument",
        "A folder can't be moved inside itself.",
      );
    }
    await db.collection(FOLDERS).doc(id).update({name, parentId});
    return {id};
  }
  const ref = await db.collection(FOLDERS).add({
    name,
    parentId,
    createdAt: Timestamp.now(),
  });
  return {id: ref.id};
});

/**
 * Deletes a folder. Its sub-folders and stations move up to its parent,
 * so nothing is lost.
 */
export const deleteOsceFolderHandler = callable("deleteOsceFolder", async (r) => {
  checkIfAdminAndThrow(r.auth);
  const id = requireString(r.data, "id");
  const db = getFirestore();
  const ref = db.collection(FOLDERS).doc(id);
  const folder = await ref.get();
  if (!folder.exists) return {deleted: false};
  const parentId = folder.get("parentId") ?? null;

  const batch = db.batch();
  const children = await db.collection(FOLDERS)
    .where("parentId", "==", id).get();
  children.docs.forEach((doc) => batch.update(doc.ref, {parentId}));
  const stations = await db.collection("osces")
    .where("folderId", "==", id).get();
  stations.docs.forEach((doc) => batch.update(doc.ref, {
    folderId: parentId ?? FieldValue.delete(),
  }));
  batch.delete(ref);
  await batch.commit();
  return {deleted: true};
});

/** Puts a station in a folder (or none with folderId null). */
export const setOsceFolderHandler = callable("setOsceFolder", async (r) => {
  checkIfAdminAndThrow(r.auth);
  const osceId = requireString(r.data, "osceId");
  const folderId =
    typeof r.data?.folderId === "string" && r.data.folderId ?
      r.data.folderId : null;
  const db = getFirestore();
  if (folderId && !(await db.collection(FOLDERS).doc(folderId).get()).exists) {
    throw new HttpsError("not-found", "This folder no longer exists.");
  }
  await db.collection("osces").doc(osceId).update({
    folderId: folderId ?? FieldValue.delete(),
  });
  return {folderId};
});

/** Makes a station premium or free, also in students' saved results. */
export const setOscePremiumHandler = callable("setOscePremium", async (r) => {
  checkIfAdminAndThrow(r.auth);
  const osceId = requireString(r.data, "osceId");
  if (typeof r.data?.isPaid !== "boolean") {
    throw new HttpsError("invalid-argument", "Missing isPaid.");
  }
  const isPaid: boolean = r.data.isPaid;
  const db = getFirestore();
  const ref = db.collection("osces").doc(osceId);
  if (!(await ref.get()).exists) {
    throw new HttpsError("not-found", "This OSCE no longer exists.");
  }
  await ref.update({isPaid});

  const performances = await db.collectionGroup("osce_performance")
    .where("osceId", "==", osceId).get();
  const writer = db.bulkWriter();
  performances.docs.forEach((doc) =>
    writer.update(doc.ref, {"osceSnapshot.isPaid": isPaid}));
  await writer.close();
  return {isPaid, updatedResults: performances.size};
});

/**
 * Sets the image shown with a station's description, or removes it when
 * imageBase64 is null. Images are JPEG, compressed by the app.
 */
export const setOsceScenarioImageHandler = callable(
  "setOsceScenarioImage",
  async (r) => {
    checkIfAdminAndThrow(r.auth);
    const osceId = requireString(r.data, "osceId");
    const ref = getFirestore().collection("osces").doc(osceId);
    if (!(await ref.get()).exists) {
      throw new HttpsError("not-found", "This OSCE no longer exists.");
    }
    const file = getStorage().bucket().file(`osces/${osceId}/scenario.jpg`);

    const imageBase64 = r.data?.imageBase64;
    if (imageBase64 === null || imageBase64 === undefined) {
      await file.delete({ignoreNotFound: true});
      await ref.update({scenarioImageUrl: FieldValue.delete()});
      return {url: null};
    }
    if (typeof imageBase64 !== "string") {
      throw new HttpsError("invalid-argument", "Invalid image.");
    }
    const bytes = Buffer.from(imageBase64, "base64");
    if (bytes.length === 0 || bytes.length > 4 * 1024 * 1024) {
      throw new HttpsError("invalid-argument", "The image must be under 4 MB.");
    }
    await file.save(bytes, {
      contentType: "image/jpeg",
      metadata: {cacheControl: "public, max-age=86400"},
    });
    const url = await getDownloadURL(file);
    await ref.update({scenarioImageUrl: url});
    return {url};
  },
);
