import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards/utils/typedefs.dart';

class FirestoreDbContext {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final flashcardIdsDocName = "all_ids";

  // Flashcards and packs
  CollectionReference<JsonMap> get fcpData => _db.collection('fcp_data');

  CollectionReference<JsonMap> get flashcards => _db.collection('flashcards');

  CollectionReference<JsonMap> get packs => _db.collection('packs');

  CollectionReference<JsonMap> getPacksFlashcardIdsCollection(String packId) =>
      packs.doc(packId).collection("flashcard_ids");

  CollectionReference<JsonMap> get ppData => _db.collection("pp_data");

  // Reports
  CollectionReference<JsonMap> get flashcardReports =>
      _db.collection("flashcard_reports");

  CollectionReference<JsonMap> getUserReportsCollection(String flashcardId) =>
      flashcardReports.doc(flashcardId).collection("user_reports");

  CollectionReference<JsonMap> get tags => _db.collection('tags');

  CollectionReference<JsonMap> get customSessions =>
      _db.collection("custom_sessions");

  CollectionReference<JsonMap> getSessionFlashcardIdsCollection(
    String customSessionId,
  ) => customSessions.doc(customSessionId).collection("flashcard_ids");

  CollectionReference<JsonMap> get users => _db.collection('users');

  WriteBatch createBatch() => _db.batch();

  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionHandler,
  ) => _db.runTransaction(transactionHandler);
}
