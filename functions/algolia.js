const { algoliasearch } = require("algoliasearch");

function config() {
  const appId = process.env.ALGOLIA_APP_ID;
  const adminKey = process.env.ALGOLIA_ADMIN_KEY;
  if (!appId || !adminKey) return null;
  return {
    client: algoliasearch(appId, adminKey),
    packsIndex: process.env.ALGOLIA_PACKS_INDEX || "taqdir_packs",
    flashcardsIndex: process.env.ALGOLIA_FLASHCARDS_INDEX || "taqdir_flashcards",
  };
}

async function sync(indexKey, id, data) {
  const cfg = config();
  if (!cfg) return; // البحث غير مفعّل
  const indexName = cfg[indexKey];
  if (!data) {
    await cfg.client.deleteObject({ indexName, objectID: id });
    return;
  }
  const body =
    indexKey === "packsIndex"
      ? { objectID: id, name: data.name, tags: data.tags ?? [], isPaid: !!data.isPaid, section: data.section ?? "verbal" }
      : { objectID: id, question: data.question, answer: data.answer, isPaid: !!data.isPaid, tags: data.tags ?? [], packId: data.packId };
  await cfg.client.saveObject({ indexName, body });
}

module.exports = { sync, config };
