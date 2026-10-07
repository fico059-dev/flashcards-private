import {logger} from "firebase-functions";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {checkIfAdminAndThrow} from "../utils/utils";

/** Most emails one pack can be limited to. */
const maxEmails = 2000;
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/**
 * Cleans the email list sent by the admin: trimmed, lower case, no
 * duplicates.
 * @param {unknown} value The emails.
 * @return {string[]} The cleaned list.
 */
export function cleanEmails(value: unknown): string[] {
  if (!Array.isArray(value)) {
    throw new HttpsError("invalid-argument", "emails must be a list.");
  }
  const emails = new Set<string>();
  for (const item of value) {
    if (typeof item !== "string") continue;
    const email = item.trim().toLowerCase();
    if (!email) continue;
    if (!emailPattern.test(email)) {
      throw new HttpsError("invalid-argument", `"${item}" is not an email.`);
    }
    emails.add(email);
  }
  if (emails.size > maxEmails) {
    throw new HttpsError(
      "invalid-argument", `A pack can be limited to at most ${maxEmails} emails.`);
  }
  return [...emails].sort();
}

/**
 * Whether the caller may use a pack: packs without a list are for everyone,
 * admins see every pack.
 * @param {FirebaseFirestore.DocumentData | undefined} pack The pack data.
 * @param {object} token The caller's auth token.
 * @return {boolean} True when allowed.
 */
export function canUsePack(
  pack: FirebaseFirestore.DocumentData | undefined,
  token: {email?: string; roles?: unknown},
): boolean {
  const allowed = pack?.allowedEmails;
  if (!Array.isArray(allowed) || allowed.length === 0) return true;
  const roles = Array.isArray(token.roles) ? token.roles : [];
  if (roles.includes("admin")) return true;
  const email = (token.email ?? "").toLowerCase();
  return email !== "" && allowed.includes(email);
}

/**
 * Limits a pack to the given emails, or opens it to everyone when the list
 * is empty. Admins only.
 * @param {CallableRequest} request Has packId and emails.
 * @return {Promise<{allowedEmails: string[]}>} The saved list.
 */
export async function setPackAccessHandler(request: CallableRequest) {
  try {
    checkIfAdminAndThrow(request.auth);
    const packId = request.data?.packId;
    if (typeof packId !== "string" || !packId) {
      throw new HttpsError("invalid-argument", "Missing packId.");
    }
    const emails = cleanEmails(request.data?.emails);
    const ref = getFirestore().collection("packs").doc(packId);
    if (!(await ref.get()).exists) {
      throw new HttpsError("not-found", "This pack no longer exists.");
    }
    await ref.update({
      allowedEmails: emails.length ? emails : FieldValue.delete(),
    });
    logger.info("Pack access changed", {packId, count: emails.length});
    return {allowedEmails: emails};
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;
    logger.error("setPackAccess failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }
}
