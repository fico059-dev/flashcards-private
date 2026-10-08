import {initializeTestEnvironment, assertSucceeds, assertFails} from '@firebase/rules-unit-testing';
import {doc, getDoc, setDoc, collection, getDocs, query, where, orderBy} from 'firebase/firestore';
import fs from 'fs';

const env = await initializeTestEnvironment({
  projectId: 'demo-flashpedz',
  firestore: {rules: fs.readFileSync('../../firestore.rules', 'utf8'), host: '127.0.0.1', port: 8085},
});
await env.withSecurityRulesDisabled(async (ctx) => {
  const db = ctx.firestore();
  await setDoc(doc(db, 'packs/open'), {name: 'Open', isPaid: false, flashcardsCount: 1});
  await setDoc(doc(db, 'packs/private'), {name: 'Private', isPaid: false, restricted: true, flashcardsCount: 1});
  await setDoc(doc(db, 'packs/paid'), {name: 'Paid', isPaid: true, flashcardsCount: 1});
  await setDoc(doc(db, 'packs/open/flashcard_ids/ids'), {flashcardIds: ['c1']});
  await setDoc(doc(db, 'packs/private/flashcard_ids/ids'), {flashcardIds: ['c2']});
  await setDoc(doc(db, 'flashcards/c1'), {packId: 'open', question: 'q1', isPaid: false});
  await setDoc(doc(db, 'flashcards/c2'), {packId: 'private', question: 'q2', isPaid: false});
  await setDoc(doc(db, 'flashcards/c3'), {packId: 'deletedpack', question: 'q3', isPaid: false});
  await setDoc(doc(db, 'flashcards/c4'), {packId: 'paid', question: 'q4', isPaid: true});
  await setDoc(doc(db, 'pack_access/private'), {emails: ['ali@mail.com']});
  await setDoc(doc(db, 'pack_access_by_email/ali@mail.com'), {packIds: ['private']});
});

const user = (uid, email, extra = {}) =>
  env.authenticatedContext(uid, {email, email_verified: true, ...extra}).firestore();
const ali = user('ali', 'Ali@Mail.com');
const bob = user('bob', 'bob@mail.com');
const admin = user('adm', 'admin@mail.com', {roles: ['admin']});
const noEmail = env.authenticatedContext('x', {email_verified: true}).firestore();

const checks = [
  ['bob lists packs (names only)', assertSucceeds(getDocs(query(collection(bob, 'packs'), orderBy('name'))))],
  ['bob lists free packs', assertSucceeds(getDocs(query(collection(bob, 'packs'), where('isPaid', '==', false), orderBy('name'))))],
  ['bob opens open pack', assertSucceeds(getDoc(doc(bob, 'packs/open')))],
  ['bob opens open card', assertSucceeds(getDoc(doc(bob, 'flashcards/c1')))],
  ['bob opens open pack card ids', assertSucceeds(getDoc(doc(bob, 'packs/open/flashcard_ids/ids')))],
  ['bob opens card of deleted pack', assertSucceeds(getDoc(doc(bob, 'flashcards/c3')))],
  ['bob BLOCKED private pack', assertFails(getDoc(doc(bob, 'packs/private')))],
  ['bob BLOCKED private card', assertFails(getDoc(doc(bob, 'flashcards/c2')))],
  ['bob BLOCKED private card ids', assertFails(getDoc(doc(bob, 'packs/private/flashcard_ids/ids')))],
  ['bob BLOCKED listing cards', assertFails(getDocs(collection(bob, 'flashcards')))],
  ['bob BLOCKED paid card', assertFails(getDoc(doc(bob, 'flashcards/c4')))],
  ['bob BLOCKED reading access list', assertFails(getDoc(doc(bob, 'pack_access/private')))],
  ['bob BLOCKED reading ali access', assertFails(getDoc(doc(bob, 'pack_access_by_email/ali@mail.com')))],
  ['bob reads own (missing) access doc', assertSucceeds(getDoc(doc(bob, 'pack_access_by_email/bob@mail.com')))],
  ['ali opens private pack', assertSucceeds(getDoc(doc(ali, 'packs/private')))],
  ['ali opens private card', assertSucceeds(getDoc(doc(ali, 'flashcards/c2')))],
  ['ali opens private card ids', assertSucceeds(getDoc(doc(ali, 'packs/private/flashcard_ids/ids')))],
  ['ali reads own access doc', assertSucceeds(getDoc(doc(ali, 'pack_access_by_email/ali@mail.com')))],
  ['ali BLOCKED writing access doc', assertFails(setDoc(doc(ali, 'pack_access_by_email/ali@mail.com'), {packIds: ['paid']}))],
  ['no-email user opens open card', assertSucceeds(getDoc(doc(noEmail, 'flashcards/c1')))],
  ['no-email user BLOCKED private card', assertFails(getDoc(doc(noEmail, 'flashcards/c2')))],
  ['admin opens private card', assertSucceeds(getDoc(doc(admin, 'flashcards/c2')))],
  ['admin lists cards by pack', assertSucceeds(getDocs(query(collection(admin, 'flashcards'), where('packId', '==', 'private'))))],
  ['admin reads access list', assertSucceeds(getDoc(doc(admin, 'pack_access/private')))],
];
let failed = 0;
for (const [name, p] of checks) {
  try { await p; console.log('PASS', name); } catch (e) { failed++; console.log('FAIL', name, e.message.slice(0, 200)); }
}
await env.cleanup();
console.log(failed ? `${failed} FAILED` : 'ALL RULE CHECKS PASSED');
process.exit(failed ? 1 : 0);
