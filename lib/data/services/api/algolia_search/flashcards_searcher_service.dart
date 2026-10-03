import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards/data/remote/firestore_db_context.dart';
import 'package:flashcards/domain/models/algolia/algolia_flashcard/algolia_flashcard.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flashcards/utils/typedefs.dart';

/// Loads the flashcards that flashcard search runs over. Search used to go
/// through Algolia, whose app no longer exists, so flashcards are read from
/// Firestore and searched on the device.
class FlashcardsSearcherService {
  final CollectionReference<JsonMap> _flashcards;

  FlashcardsSearcherService({required FirestoreDbContext dbContext})
    : _flashcards = dbContext.flashcards;

  Future<Result<List<AlgoliaFlashcard>>> getAllFlashcards() async {
    try {
      QuerySnapshot<JsonMap> snapshot;
      try {
        snapshot = await _flashcards.orderBy('question').get();
      } on FirebaseException catch (error) {
        // Users without a subscription may only be allowed to read free cards
        if (error.code != 'permission-denied') rethrow;
        snapshot = await _flashcards
            .where('isPaid', isEqualTo: false)
            .orderBy('question')
            .get();
      }
      return Result.ok(
        snapshot.docs.map((doc) {
          final data = doc.data();
          return AlgoliaFlashcard(
            objectID: doc.id,
            question: data['question'] as String? ?? '',
            answer: data['answer'] as String? ?? '',
            isPaid: data['isPaid'] as bool? ?? false,
            tags: List<String>.from(data['tags'] as List? ?? const []),
          );
        }).toList(),
      );
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
