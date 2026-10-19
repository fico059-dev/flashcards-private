#!/usr/bin/env node
// يعيّن مستخدماً كمشرف (لأول مشرف قبل أن تستطيع من التطبيق نفسه).
//
//   GOOGLE_APPLICATION_CREDENTIALS=key.json node make-admin.js --project YOUR_PROJECT_ID user@example.com
//
// المستخدم لازم يكون سجّل في التطبيق مسبقاً، وبعدها يسجّل خروج ودخول لتصله الصلاحية.

const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

const args = process.argv.slice(2);
const pi = args.indexOf("--project");
const projectId = pi >= 0 ? args[pi + 1] : process.env.GCLOUD_PROJECT;
const email = args.filter((a, i) => !a.startsWith("--") && i !== pi + 1)[0];
if (!projectId || !email) {
  console.error("الاستخدام: node make-admin.js --project YOUR_PROJECT_ID user@example.com");
  process.exit(1);
}

initializeApp({ projectId });
(async () => {
  const auth = getAuth();
  const user = await auth.getUserByEmail(email.toLowerCase());
  const claims = user.customClaims ?? {};
  const roles = Array.from(new Set([...(claims.roles ?? []), "admin"]));
  await auth.setCustomUserClaims(user.uid, { ...claims, roles });
  console.log(`✔ ${email} أصبح مشرفاً (uid: ${user.uid})`);
})().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
