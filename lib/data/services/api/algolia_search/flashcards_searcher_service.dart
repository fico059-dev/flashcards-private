import 'package:flashcards/data/remote/cloud_function_service.dart';
import 'package:flashcards/domain/models/algolia/algolia_flashcard/algolia_flashcard.dart';
import 'package:flashcards/utils/result.dart';

/// Loads the flashcards that flashcard search runs over. Search used to go
/// through Algolia, whose app no longer exists, so flashcards are read from
/// Firestore and searched on the device.
class FlashcardsSearcherService {
  final CloudFunctionService _functions;

  FlashcardsSearcherService({required CloudFunctionService functions})
    : _functions = functions;

  /// Cards the user may search. The server leaves out premium cards without
  /// a subscription and packs limited to other users.
  Future<Result<List<AlgoliaFlashcard>>> getAllFlashcards() async {
    try {
      final cards = await _functions.listSearchableFlashcards();
      cards.sort(
        (a, b) => (a['question'] as String? ?? '').compareTo(
          b['question'] as String? ?? '',
        ),
      );
      return Result.ok([
        for (final data in cards)
          AlgoliaFlashcard(
            objectID: data['id'] as String,
            question: data['question'] as String? ?? '',
            answer: data['answer'] as String? ?? '',
            isPaid: data['isPaid'] as bool? ?? false,
            tags: List<String>.from(data['tags'] as List? ?? const []),
          ),
      ]);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
