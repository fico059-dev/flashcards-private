import {logger} from "firebase-functions";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {getAuth} from "firebase-admin/auth";
import {getFirestore} from "firebase-admin/firestore";
import {checkIfAdminAndThrow} from "../utils/utils";

/** Days shown in the daily charts. */
const historyDays = 90;
/** Weekly sign-up groups shown in the retention table. */
const cohortWeeks = 8;
const dayMs = 24 * 60 * 60 * 1000;

/** One user as the numbers need them. */
export type AnalyticsUser = {
  createdAt: number;
  providers: string[];
  educationLevel?: string;
  streak?: number;
  hasGoal: boolean;
  /** Day ("YYYY-MM-DD") -> [reviews, new cards, forgotten]. */
  days: Record<string, number[]>;
  osceAttempts: number;
};

export type ContentCounts = {packs: number; flashcards: number; osces: number};

/**
 * Day key in UTC, like the study history's "YYYY-MM-DD".
 * @param {number} ms Time in milliseconds.
 * @return {string} The key.
 */
export function utcDay(ms: number): string {
  return new Date(ms).toISOString().slice(0, 10);
}

/**
 * Milliseconds at the start of a day key (UTC).
 * @param {string} day The key.
 * @return {number} The time.
 */
function dayStart(day: string): number {
  return Date.parse(`${day}T00:00:00Z`);
}

/**
 * Share as a whole percent, or null when there is nobody to count.
 * @param {number} part How many did it.
 * @param {number} whole How many could have.
 * @return {number | null} The percent.
 */
function percent(part: number, whole: number): number | null {
  return whole > 0 ? Math.round((part / whole) * 1000) / 10 : null;
}

/**
 * Works out the investor numbers from all users.
 * @param {AnalyticsUser[]} users Every user.
 * @param {ContentCounts} content How much content the app has.
 * @param {number} now The current time (ms).
 * @return {object} The numbers.
 */
export function computeAnalytics(
  users: AnalyticsUser[], content: ContentCounts, now: number,
) {
  const today = utcDay(now);
  const todayStart = dayStart(today);
  const dayKeys: string[] = [];
  for (let i = historyDays - 1; i >= 0; i--) {
    dayKeys.push(utcDay(todayStart - i * dayMs));
  }
  const daily = new Map(dayKeys.map((d) => [d, {
    date: d, signups: 0, activeLearners: 0, cardsStudied: 0, newCards: 0,
  }]));
  const firstDay = dayKeys[0];

  const providers: Record<string, number> = {};
  const education: Record<string, number> = {};
  let cardsAllTime = 0;
  let newCardsAllTime = 0;
  let osceAttempts = 0;
  let learnersEver = 0;
  let withGoal = 0;
  let streakSum = 0;
  let streak3 = 0;
  let activeDaysLast30 = 0;
  let cardsLast30 = 0;
  const activeWithin = {1: 0, 7: 0, 30: 0} as Record<number, number>;
  const retention = {
    1: {eligible: 0, returned: 0},
    7: {eligible: 0, returned: 0},
    30: {eligible: 0, returned: 0},
  } as Record<number, {eligible: number; returned: number}>;
  const weekStart = (ms: number) => {
    const d = new Date(utcDay(ms));
    // Weeks start on Monday.
    return dayStart(utcDay(d.getTime() - ((d.getUTCDay() + 6) % 7) * dayMs));
  };
  const thisWeek = weekStart(now);
  const cohorts = new Map<number, {
    size: number; week1: number; week2: number; week4: number;
  }>();
  for (let i = cohortWeeks - 1; i >= 0; i--) {
    cohorts.set(thisWeek - i * 7 * dayMs,
      {size: 0, week1: 0, week2: 0, week4: 0});
  }

  for (const user of users) {
    for (const p of user.providers.length ? user.providers : ["other"]) {
      providers[p] = (providers[p] ?? 0) + 1;
    }
    const level = user.educationLevel ?? "notSet";
    education[level] = (education[level] ?? 0) + 1;
    if (user.hasGoal) withGoal++;
    const streak = user.streak ?? 0;
    streakSum += streak;
    if (streak >= 3) streak3++;
    osceAttempts += user.osceAttempts;

    const created = utcDay(user.createdAt);
    const signupDay = daily.get(created);
    if (signupDay) signupDay.signups++;

    const studied = Object.entries(user.days)
      .filter(([, v]) => (v[0] ?? 0) > 0);
    if (studied.length || user.osceAttempts > 0) learnersEver++;
    let lastStudied = "";
    for (const [day, [reviews = 0, fresh = 0]] of studied) {
      cardsAllTime += reviews;
      newCardsAllTime += fresh;
      if (day > lastStudied) lastStudied = day;
      const point = day >= firstDay ? daily.get(day) : undefined;
      if (point) {
        point.activeLearners++;
        point.cardsStudied += reviews;
        point.newCards += fresh;
      }
      const ago = (todayStart - dayStart(day)) / dayMs;
      if (ago >= 0 && ago < 30) {
        activeDaysLast30++;
        cardsLast30 += reviews;
      }
    }
    if (lastStudied) {
      const ago = (todayStart - dayStart(lastStudied)) / dayMs;
      for (const n of [1, 7, 30]) {
        // "Today" counts for the last day too: users study in many zones.
        if (ago < n + (n === 1 ? 1 : 0)) activeWithin[n]++;
      }
    }

    // Came back: studied N or more days after signing up.
    const createdStart = dayStart(created);
    const daysAfter = studied.map(([d]) => (dayStart(d) - createdStart) / dayMs);
    for (const n of [1, 7, 30]) {
      if (todayStart - createdStart < n * dayMs) continue;
      retention[n].eligible++;
      if (daysAfter.some((a) => a >= n)) retention[n].returned++;
    }

    const cohort = cohorts.get(weekStart(user.createdAt));
    if (cohort) {
      cohort.size++;
      const weeksAfter = new Set(studied.map(([d]) =>
        Math.floor((dayStart(d) - weekStart(user.createdAt)) / (7 * dayMs))));
      if (weeksAfter.has(1)) cohort.week1++;
      if (weeksAfter.has(2)) cohort.week2++;
      if (weeksAfter.has(4)) cohort.week4++;
    }
  }

  const series = [...daily.values()];
  let running = users.filter((u) => utcDay(u.createdAt) < firstDay).length;
  const growth = series.map((p) => {
    running += p.signups;
    return running;
  });
  const last7 = series.slice(-7);
  const avgDau = last7.reduce((a, p) => a + p.activeLearners, 0) / 7;
  const newLast = (n: number) =>
    users.filter((u) => now - u.createdAt < n * dayMs).length;
  const prevNew30 = users.filter((u) =>
    now - u.createdAt >= 30 * dayMs && now - u.createdAt < 60 * dayMs).length;

  return {
    generatedAt: new Date(now).toISOString(),
    users: {
      total: users.length,
      new7: newLast(7),
      new30: newLast(30),
      new30Previous: prevNew30,
      learnersEver,
      byProvider: providers,
      byEducation: education,
    },
    activity: {
      dau: activeWithin[1],
      wau: activeWithin[7],
      mau: activeWithin[30],
      avgDauLast7: Math.round(avgDau * 10) / 10,
      stickiness: percent(avgDau, activeWithin[30]),
      cardsAllTime,
      newCardsAllTime,
      cardsLast30,
      cardsPerActiveDay: activeDaysLast30 > 0 ?
        Math.round(cardsLast30 / activeDaysLast30) : 0,
      osceAttempts,
      withGoal,
      avgStreak: users.length ?
        Math.round((streakSum / users.length) * 10) / 10 : 0,
      streak3,
    },
    retention: {
      d1: percent(retention[1].returned, retention[1].eligible),
      d7: percent(retention[7].returned, retention[7].eligible),
      d30: percent(retention[30].returned, retention[30].eligible),
    },
    cohorts: [...cohorts.entries()].map(([start, c]) => {
      const age = (thisWeek - start) / (7 * dayMs);
      return {
        week: utcDay(start),
        size: c.size,
        week1: age >= 1 ? percent(c.week1, c.size) : null,
        week2: age >= 2 ? percent(c.week2, c.size) : null,
        week4: age >= 4 ? percent(c.week4, c.size) : null,
      };
    }),
    daily: series.map((p, i) => ({...p, totalUsers: growth[i]})),
    content,
  };
}

/**
 * Adds up one user's study history from all their devices.
 * @param {Record<string, any>} devices The study_log document's devices.
 * @return {object} Days and OSCE question attempts.
 */
export function mergeDeviceLogs(devices: Record<string, any>) {
  const days: Record<string, number[]> = {};
  let osceAttempts = 0;
  for (const entry of Object.values(devices ?? {})) {
    if (typeof entry?.log !== "string") continue;
    let log: any;
    try {
      log = JSON.parse(entry.log);
    } catch {
      continue;
    }
    for (const [day, value] of Object.entries(log?.days ?? {})) {
      if (!Array.isArray(value)) continue;
      const sum = days[day] ?? [0, 0, 0];
      value.slice(0, 3).forEach((v, i) => sum[i] += Number(v) || 0);
      days[day] = sum;
    }
    for (const station of Object.values(log?.osce ?? {}) as any[]) {
      for (const q of Object.values(station?.q ?? {}) as any[]) {
        osceAttempts += Number(q?.n) || 0;
      }
    }
  }
  return {days, osceAttempts};
}

/**
 * Numbers about users and study for the admin dashboard (admins only).
 * @param {CallableRequest} request No data needed.
 * @return {Promise<object>} The numbers.
 */
export async function getAppAnalyticsHandler(request: CallableRequest) {
  try {
    checkIfAdminAndThrow(request.auth);
    const db = getFirestore();

    const accounts: {uid: string; createdAt: number; providers: string[]}[] =
      [];
    let pageToken: string | undefined;
    do {
      const page = await getAuth().listUsers(1000, pageToken);
      for (const u of page.users) {
        accounts.push({
          uid: u.uid,
          createdAt: Date.parse(u.metadata.creationTime),
          providers: u.providerData.map((p) => p.providerId),
        });
      }
      pageToken = page.pageToken;
    } while (pageToken);

    const [profiles, logs, packs, flashcards, osces] = await Promise.all([
      db.collection("users").select("educationLevel", "streak").get(),
      db.collectionGroup("progress").get(),
      db.collection("packs").count().get(),
      db.collection("flashcards").count().get(),
      db.collection("osces").count().get(),
    ]);
    const profileById = new Map(profiles.docs.map((d) => [d.id, d.data()]));
    const logById = new Map<string, FirebaseFirestore.DocumentData>();
    for (const doc of logs.docs) {
      const owner = doc.ref.parent.parent;
      if (doc.id === "study_log" && owner?.parent.id === "users") {
        logById.set(owner.id, doc.data());
      }
    }

    const users: AnalyticsUser[] = accounts.map((a) => {
      const profile = profileById.get(a.uid);
      const log = logById.get(a.uid);
      const merged = mergeDeviceLogs(log?.devices ?? {});
      let hasGoal = false;
      try {
        const goal = JSON.parse(log?.goal?.value ?? "null");
        hasGoal = !!(goal?.examDate || goal?.targetCards || goal?.packs?.length);
      } catch {
        hasGoal = false;
      }
      return {
        createdAt: a.createdAt,
        providers: a.providers,
        educationLevel: typeof profile?.educationLevel === "string" ?
          profile.educationLevel : undefined,
        streak: Number(profile?.streak?.count) || 0,
        hasGoal,
        ...merged,
      };
    });

    return computeAnalytics(users, {
      packs: packs.data().count,
      flashcards: flashcards.data().count,
      osces: osces.data().count,
    }, Date.now());
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;
    logger.error("getAppAnalytics failed", {error});
    throw new HttpsError("internal", error.message || "Internal error");
  }
}
