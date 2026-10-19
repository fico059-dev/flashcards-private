import {logger} from "firebase-functions";
import {HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";

export const batchLimit = 500;

type batchOperation = "Deleting" | "Updating";
export type Scope = "packs" | "osce" | "both";

type MaybeAuth = CallableRequest<any>["auth"];
type AuthData = NonNullable<MaybeAuth>;

export function logBatchMessage(
  operation: batchOperation,
  snapshotSize: number,
  collectionName: string,
  deleteCount: number,
  additionalLogObject: object,
  limit: number = batchLimit,
) {
  logger.info(`${operation} ${snapshotSize} docs from ${collectionName}`, {
    batch: Math.floor(deleteCount / limit) + 1,
    ...additionalLogObject,
  });
}

export function getMissingParams(params: Record<string, any>): string {
  return Object.entries(params)
    .filter(([_, value]) => value == null || value === "")
    .map(([key]) => key)
    .join(", ");
}

export function checkAuthAndThrow(auth: MaybeAuth): asserts auth is AuthData {
  if (!auth) {
    logger.error("Unauthenticated");
    throw new HttpsError("unauthenticated", "Unauthenticated");
  }
}

export function checkIfAdminAndThrow(
  auth: MaybeAuth,
): asserts auth is AuthData {
  checkAuthAndThrow(auth);
  const roles: string[] = (auth.token as any)?.roles || [];
  if (!roles.includes("admin")) {
    logger.error("Unauthorized role escalation attempt", {uid: auth.uid});
    throw new HttpsError("permission-denied", "Permission Denied");
  }
}

export function updatePackTagCounts(
  packTagsMap: Record<string, number>,
  oldTags: string[],
  newTags: string[],
) {
  const oldSet = new Set(oldTags);
  const newSet = new Set(newTags);
  const packTags = {...packTagsMap};

  for (const tag of newSet) {
    if (!oldSet.has(tag)) {
      packTags[tag] = (packTags[tag] || 0) + 1;
    }
  }

  for (const tag of oldSet) {
    if (!newSet.has(tag)) {
      if (!(tag in packTags)) {
        throw new Error(`Tag "${tag}" not found in packTags`);
      }
      if (packTags[tag] === 1) delete packTags[tag];
      else packTags[tag] -= 1;
    }
  }

  return packTags;
}

export function derive(flags: {
  cardsExp: number;
  osceExp: number;
  allExp?: number;
}) {
  const now = Date.now();
  const hasCards = (flags.cardsExp || 0) > now || (flags.allExp || 0) > now;
  const hasOsce = (flags.osceExp || 0) > now || (flags.allExp || 0) > now;
  return {hasCards, hasOsce};
}

type EntitlementsDoc = {
  cards?: { active: boolean; expiresAt: number | null };
  osce?: { active: boolean; expiresAt: number | null };
  all?: { active: boolean; expiresAt: number | null };
  derived?: { hasCards: boolean; hasOsce: boolean };
  updatedAt?: FirebaseFirestore.FieldValue;
};

export async function setEntitlementsAndClaims(
  uid: string,
  newCardsExp: number,
  newOsceExp: number,
  newAllExp?: number,
) {
  const db = getFirestore();
  const auth = getAuth();

  const user = await auth.getUser(uid).catch(() => undefined as any);
  const current = (user?.customClaims as any) || {};
  const cardsExp = Math.max(Number(current.cardsExp || 0), newCardsExp || 0);
  const osceExp = Math.max(Number(current.osceExp || 0), newOsceExp || 0);
  const allExp = Math.max(Number(current.allExp || 0), newAllExp || 0);

  const ent: ("packs" | "osce" | "both")[] = [];
  if (allExp > Date.now()) ent.push("both");
  if (cardsExp > Date.now()) ent.push("packs");
  if (osceExp > Date.now()) ent.push("osce");

  const d = derive({cardsExp, osceExp, allExp});

  const doc: EntitlementsDoc = {
    cards: {active: cardsExp > Date.now(), expiresAt: cardsExp || null},
    osce: {active: osceExp > Date.now(), expiresAt: osceExp || null},
    all: {active: allExp > Date.now(), expiresAt: allExp || null},
    derived: {hasCards: d.hasCards, hasOsce: d.hasOsce},
    updatedAt: FieldValue.serverTimestamp(),
  };

  await db.doc(`entitlements/${uid}`).set(doc, {merge: true});
  await auth.setCustomUserClaims(uid, {
    ...(current || {}),
    packsExp: cardsExp,
    osceExp,
    bothExp: allExp,
    cardsExp,
    allExp,
    entitlements: ent,
  });

  return {cardsExp, osceExp, allExp, derived: d};
}

export function mapProductToScope(
  productId: string,
): "packs" | "osce" | "both" {
  const id = productId.toLowerCase();
  if (id.includes("both")) return "both";
  if (id.includes("osce")) return "osce";
  return "packs";
}
