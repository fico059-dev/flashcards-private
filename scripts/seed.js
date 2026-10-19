#!/usr/bin/env node
// يملأ Firestore بحزم وبطاقات تجريبية للقدرات (لفظي وكمي).
//
// الاستخدام:
//   GOOGLE_APPLICATION_CREDENTIALS=key.json node seed.js --project YOUR_PROJECT_ID
// أو على المحاكي:
//   FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 node seed.js --project demo-taqdir
//
// آمن للتشغيل أكثر من مرة (المعرّفات ثابتة وتُستبدل).

const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const packs = require("./qudurat_sample");

const args = process.argv.slice(2);
const projectId = args[args.indexOf("--project") + 1] || process.env.GCLOUD_PROJECT;
if (!projectId || projectId.startsWith("--")) {
  console.error("حدّد المشروع: node seed.js --project YOUR_PROJECT_ID");
  process.exit(1);
}

initializeApp({ projectId });
const db = getFirestore();

// نفس منطق Tag.fromName في التطبيق: حروف صغيرة + المسافة => __
const tagId = (name) => name.trim().toLowerCase().replace(/\s+/g, "__").replace(/^_+|_+$/g, "");

async function main() {
  const batch = db.batch();
  for (const pack of packs) {
    const id = tagId(pack.tag);
    batch.set(db.collection("tags").doc(id), { name: pack.tag });

    const cardIds = [];
    pack.cards.forEach((card, i) => {
      const cardId = `${pack.id}-${String(i + 1).padStart(2, "0")}`;
      cardIds.push(cardId);
      batch.set(db.collection("flashcards").doc(cardId), {
        packId: pack.id,
        question: card.question,
        answer: card.answer,
        isPaid: pack.isPaid,
        questionImageUrl: null,
        answerImageUrl: null,
        tags: [id],
      });
    });

    const packRef = db.collection("packs").doc(pack.id);
    batch.set(packRef, {
      name: pack.name,
      section: pack.section,
      flashcardsCount: pack.cards.length,
      isPaid: pack.isPaid,
      tags: [id],
      tagCounts: { [id]: pack.cards.length },
    });
    batch.set(packRef.collection("flashcard_ids").doc("all_ids"), { flashcardIds: cardIds });
  }
  await batch.commit();
  const total = packs.reduce((n, p) => n + p.cards.length, 0);
  console.log(`تمت إضافة ${packs.length} حزمة و${total} بطاقة إلى ${projectId}`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
