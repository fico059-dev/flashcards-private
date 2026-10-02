// Admin management functions used by the "Assign Admin" page of the admin
// dashboard. Admins are users whose custom claims contain `roles: ["admin"]`
// (set by the existing `addAdminRole` function).
//
// Deployed as its own codebase so it doesn't touch the other functions:
//   firebase deploy --only functions:admin-roles --project prod

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

initializeApp();

const ADMIN_ROLE = "admin";

function hasAdminRole(claims) {
  return Array.isArray(claims?.roles) && claims.roles.includes(ADMIN_ROLE);
}

function assertCallerIsAdmin(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You need to be signed in.");
  }
  if (!hasAdminRole(request.auth.token)) {
    throw new HttpsError(
      "permission-denied",
      "Only admins can manage other admins.",
    );
  }
}

/** Returns every user with the admin role. */
exports.listAdmins = onCall(async (request) => {
  assertCallerIsAdmin(request);

  const admins = [];
  let pageToken;
  do {
    const page = await getAuth().listUsers(1000, pageToken);
    for (const user of page.users) {
      if (!hasAdminRole(user.customClaims)) continue;
      admins.push({
        uid: user.uid,
        email: user.email ?? null,
        displayName: user.displayName ?? null,
        lastSignInTime: user.metadata.lastSignInTime ?? null,
      });
    }
    pageToken = page.pageToken;
  } while (pageToken);

  admins.sort((a, b) => (a.email ?? "").localeCompare(b.email ?? ""));
  return { admins };
});

/**
 * Removes the admin role from a user, keeping their other claims (e.g.
 * subscription entitlements). Admins can't remove themselves, so there is
 * always at least one admin left.
 */
exports.removeAdminRole = onCall(async (request) => {
  assertCallerIsAdmin(request);

  const uid = request.data?.uid;
  if (typeof uid !== "string" || uid.length === 0) {
    throw new HttpsError("invalid-argument", "A user id is required.");
  }
  if (uid === request.auth.uid) {
    throw new HttpsError(
      "failed-precondition",
      "You can't remove your own admin access.",
    );
  }

  let user;
  try {
    user = await getAuth().getUser(uid);
  } catch (error) {
    if (error.code === "auth/user-not-found") {
      throw new HttpsError("not-found", "This user no longer exists.");
    }
    throw error;
  }

  const claims = user.customClaims ?? {};
  if (!hasAdminRole(claims)) {
    return { removed: false };
  }

  await getAuth().setCustomUserClaims(uid, {
    ...claims,
    roles: claims.roles.filter((role) => role !== ADMIN_ROLE),
  });
  return { removed: true };
});
