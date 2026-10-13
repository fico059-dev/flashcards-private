import {logger} from "firebase-functions";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {getAuth} from "firebase-admin/auth";
import {getDownloadURL, getStorage} from "firebase-admin/storage";
import {randomUUID} from "crypto";

/**
 * Removes the user's earlier profile photos.
 * @param {string} uid The user.
 * @param {string} keep File name to keep, if any.
 * @return {Promise<void>} Done when deleted.
 */
async function deleteOldPhotos(uid: string, keep?: string): Promise<void> {
  const [files] = await getStorage().bucket()
    .getFiles({prefix: `users/${uid}/avatar-`});
  await Promise.all(files
    .filter((file) => file.name !== keep)
    .map((file) => file.delete({ignoreNotFound: true})));
}

/**
 * Sets (or with no image, removes) the signed-in user's profile photo. The
 * app sends a small JPEG; its address is saved as the account's photo.
 * @param {CallableRequest} request Has imageBase64, or nothing to remove.
 * @return {Promise<object>} The photo url, or null when removed.
 */
export async function setProfilePhotoHandler(request: CallableRequest) {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Please sign in first.");
  }
  try {
    const imageBase64 = request.data?.imageBase64;
    if (imageBase64 == null || imageBase64 === "") {
      await getAuth().updateUser(uid, {photoURL: null});
      await deleteOldPhotos(uid);
      return {url: null};
    }
    if (typeof imageBase64 !== "string") {
      throw new HttpsError("invalid-argument", "Missing image.");
    }
    const bytes = Buffer.from(imageBase64, "base64");
    if (bytes.length === 0 || bytes.length > 1024 * 1024) {
      throw new HttpsError("invalid-argument", "The photo must be under 1 MB.");
    }
    // A new name each time, so the new photo isn't hidden by a cached one.
    const name = `users/${uid}/avatar-${randomUUID()}.jpg`;
    const file = getStorage().bucket().file(name);
    await file.save(bytes, {
      contentType: "image/jpeg",
      metadata: {cacheControl: "public, max-age=31536000"},
    });
    const url = await getDownloadURL(file);
    await getAuth().updateUser(uid, {photoURL: url});
    await deleteOldPhotos(uid, name);
    return {url};
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;
    logger.error("setProfilePhoto failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }
}
