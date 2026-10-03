import {logger} from "firebase-functions";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {checkAuthAndThrow, getMissingParams} from "../utils/utils";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {hasCards} from "../utils/claimsUtils";

enum PackSelectedFilter {
  all = "all",
  unseen = "unseen",
  seen = "seen",
  bookmarked = "bookmarked",
  ignored = "ignored",
}

type RequstDataDto = {
  profileId: string | undefined;
  filter: PackSelectedFilter | undefined;
  tags: string[] | undefined;
  packIds: string[] | undefined;
  sessionSize: number | undefined;
};

type FlashcardSnapshot = {
  id: string;
  packId: string;
  question: string;
  answer: string;
  tags: string[];
};

export async function createCustomSessionHandler(request: CallableRequest) {
  try {
    const {auth, data} = request;
    checkAuthAndThrow(auth);
    const claims = auth.token as any;

    const {profileId, filter, packIds, tags, sessionSize} =
      data as RequstDataDto;

    if (!profileId || !filter || !packIds || !tags || !sessionSize) {
      const missingParams = getMissingParams({
        profileId,
        filter,
        packIds,
        tags,
        sessionSize,
      });
      logger.error(`Missing required argument: ${missingParams}`);
      throw new HttpsError(
        "invalid-argument",
        `Missing required argument/s: ${missingParams}`,
      );
    }

    if (profileId !== auth!.uid) {
      throw new HttpsError(
        "permission-denied",
        "You can only create sessions for your own profile.",
      );
    }

    if (packIds.length === 0) {
      logger.error("packIds array is empty");
      throw new HttpsError(
        "invalid-argument",
        "packIds array must contain at least one pack ID.",
      );
    }

    if (packIds.length > 30) {
      logger.error("packIds array exceeds limit of 30");
      throw new HttpsError(
        "invalid-argument",
        "packIds array must not contain more than 30 pack IDs.",
      );
    }

    const hasPaidPack = await isPaidPackSelected(packIds);
    const userHasCards = hasCards(claims);

    if (hasPaidPack && !userHasCards) {
      logger.error(
        "User does not have access to paid packs but selected a paid pack",
      );
      throw new HttpsError(
        "permission-denied",
        "You do not have access to the selected paid pack(s). Please purchase access to use paid packs.",
      );
    }

    const flashcardSnapshots = await getFlashcardsByFilter(
      filter,
      packIds,
      profileId,
    );
    const filteredFlashcards = filterByTagsAndSlice(
      flashcardSnapshots,
      tags,
      sessionSize,
    );
    if (filteredFlashcards.length === 0) {
      logger.info("No flashcards found after filtering");
      throw new HttpsError(
        "not-found",
        "No flashcards found for the given criteria, please adjust your filters or tags.",
      );
    }

    await writeToCustomSession(profileId, filteredFlashcards, hasPaidPack);

    // return filteredFlashcards;
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;

    logger.error("createCustomSessionHandler failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }

  function filterByTagsAndSlice(
    flashcards: FlashcardSnapshot[],
    tags: string[],
    sessionSize: number,
  ): FlashcardSnapshot[] {
    const filtered =
      tags.length === 0 ?
        flashcards :
        flashcards.filter((flashcard) => {
          if (!flashcard.tags || flashcard.tags.length === 0) return true;
          return flashcard.tags.some((tag) => tags.includes(tag));
        });

    logger.info(
      `Filtered flashcards by tags. Original count: ${flashcards.length}, Filtered count: ${filtered.length}`,
      {tags},
    );

    // Random selection, so each session isn't the same first cards.
    const sliced = shuffle(filtered).slice(0, sessionSize);
    logger.info(
      `Sliced flashcards to session size: ${sessionSize}. Result count: ${sliced.length}`,
      {sessionSize},
    );
    return sliced;
  }

  async function isPaidPackSelected(packIds: string[]): Promise<boolean> {
    // posto nemam field 'packId' unutar pack-a, moramo da saljemo 30 request-a bazi da bi dobili sve pekove
    // radi se sa Primise.all() koji paralelno izvrsava zahteve, jeste sporije neko 'in' query ali za max 30 pekova
    // je skoro pa zanemarljivo, valjda :)
    const packRefs = packIds.map((id) =>
      getFirestore().collection("packs").doc(id),
    );
    const packSnapshots = await Promise.all(packRefs.map((ref) => ref.get()));

    const hasPaidPack = packSnapshots.some(
      (doc) => doc.exists && doc.data()?.isPaid === true,
    );
    return hasPaidPack;
  }

  async function getFlashcardsByFilter(
    filter: PackSelectedFilter,
    packIds: string[],
    profileId: string,
  ): Promise<FlashcardSnapshot[]> {
    const db = getFirestore();

    // Unseen: cards of the packs without a progress record (never studied,
    // in regular study or a custom session, bookmarked or ignored).
    if (filter === PackSelectedFilter.unseen) {
      const [cards, progress] = await Promise.all([
        db.collection("flashcards").where("packId", "in", packIds).get(),
        db
          .collection("fcp_data")
          .where("profileId", "==", profileId)
          .where("flashcardSnapshot.packId", "in", packIds)
          .select("flashcardId")
          .get(),
      ]);
      const seenIds = new Set(
        progress.docs.map((doc) => doc.get("flashcardId") as string),
      );
      const unseen: FlashcardSnapshot[] = cards.docs
        .filter((doc) => !seenIds.has(doc.id))
        .map((doc) => {
          const data = doc.data();
          return {
            id: doc.id,
            packId: data.packId,
            question: data.question,
            answer: data.answer,
            tags: data.tags ?? [],
          };
        });

      logger.info(
        `Found ${unseen.length} unseen of ${cards.size} flashcards in packs`,
        {packIds},
      );
      return unseen;
    }

    // prvo da vidimo za "all" slucaj
    if (filter === PackSelectedFilter.all) {
      const query = db.collection("flashcards").where("packId", "in", packIds);
      const snapshot = await query.limit(1000).get();

      const flashcardSnapshots: FlashcardSnapshot[] = snapshot.docs.map(
        (doc) => {
          const data = doc.data()!;
          return {
            id: doc.id,
            packId: data.packId,
            question: data.question,
            answer: data.answer,
            tags: data.tags,
          } as FlashcardSnapshot;
        },
      );

      logger.info(`Found ${flashcardSnapshots.length} flashcards in packs`, {
        packIds,
      });
      return flashcardSnapshots;
    }

    let query = db
      .collection("fcp_data")
      .where("profileId", "==", profileId)
      .where("flashcardSnapshot.packId", "in", packIds);
    switch (filter) {
    case PackSelectedFilter.seen:
      // kartica je seen ako je u fcp_data kolekciji
      break;
    case PackSelectedFilter.bookmarked:
      query = query.where("hasBookmark", "==", true);
      break;
    case PackSelectedFilter.ignored:
      query = query.where("ignored", "==", true);
      break;
    default:
      logger.error(`Unknown filter type: ${filter}`);
      throw new HttpsError(
        "invalid-argument",
        `Unknown filter type: ${filter}`,
      );
    }

    const snapshot = await query.limit(1000).get();
    const flashcardSnapshots: FlashcardSnapshot[] = snapshot.docs.map((doc) => {
      const fcSnapshot = doc.data().flashcardSnapshot;
      return {
        id: doc.data().flashcardId,
        packId: fcSnapshot.packId,
        question: fcSnapshot.question,
        answer: fcSnapshot.answer,
        tags: fcSnapshot.tags,
      } as FlashcardSnapshot;
    });

    logger.info(`Found ${flashcardSnapshots.length} flashcards in fcp_data`, {
      packIds,
    });
    return flashcardSnapshots;
  }

  async function writeToCustomSession(
    profileId: string,
    flashcards: FlashcardSnapshot[],
    hasPaidPack: boolean,
  ) {
    const db = getFirestore();
    const batch = db.batch();
    const sessionRef = db.collection("custom_sessions").doc();
    const flashcardIds = flashcards.map((fc) => fc.id);

    // Kolekcija pamti broj kartica, id-evi se pamte u subkolekciji
    batch.set(sessionRef, {
      profileId,
      cardCount: flashcards.length,
      isPaid: hasPaidPack,
      currentIndex: 0,
      correctCount: 0,
      createdAt: Timestamp.now(),
    });

    batch.set(sessionRef.collection("flashcard_ids").doc("all_ids"), {
      flashcardIds,
    });

    await batch.commit();

    logger.info(
      `Custom session created for profile ${profileId} with ${flashcards.length} flashcards`,
    );
  }
}

/** Returns a shuffled copy of [items] (Fisher-Yates). */
function shuffle<T>(items: T[]): T[] {
  const result = [...items];
  for (let i = result.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [result[i], result[j]] = [result[j], result[i]];
  }
  return result;
}
