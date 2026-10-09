import {logger} from "firebase-functions";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {getDownloadURL, getStorage} from "firebase-admin/storage";
import {randomUUID} from "crypto";
import {checkIfAdminAndThrow} from "../utils/utils";

/**
 * Stores an image placed inside a card's text (cards can show several) and
 * returns its address. Images are JPEG, compressed by the app. Admins only.
 * @param {CallableRequest} request Has imageBase64.
 * @return {Promise<object>} The image url.
 */
export async function uploadCardImageHandler(request: CallableRequest) {
  try {
    checkIfAdminAndThrow(request.auth);
    const imageBase64 = request.data?.imageBase64;
    if (typeof imageBase64 !== "string" || !imageBase64) {
      throw new HttpsError("invalid-argument", "Missing image.");
    }
    const bytes = Buffer.from(imageBase64, "base64");
    if (bytes.length === 0 || bytes.length > 4 * 1024 * 1024) {
      throw new HttpsError("invalid-argument", "The image must be under 4 MB.");
    }
    const file = getStorage().bucket()
      .file(`flashcards/inline/${randomUUID()}.jpg`);
    await file.save(bytes, {
      contentType: "image/jpeg",
      metadata: {cacheControl: "public, max-age=31536000"},
    });
    return {url: await getDownloadURL(file)};
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;
    logger.error("uploadCardImage failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }
}
