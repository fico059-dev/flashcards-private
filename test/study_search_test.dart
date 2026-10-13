import 'package:flashcards/data/repositories/algolia_search/flashcards_searcher_repository.dart';
import 'package:flashcards/data/services/api/algolia_search/flashcards_searcher_service.dart';
import 'package:flashcards/domain/models/algolia/algolia_flashcard/algolia_flashcard.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

class _Service implements FlashcardsSearcherService {
  @override
  Future<Result<List<AlgoliaFlashcard>>> getAllFlashcards() async =>
      Result.ok(const [
        AlgoliaFlashcard(
          objectID: '1',
          question: 'Palivizumab for ex-preterm infants',
          answer: 'RSV prophylaxis',
          isPaid: false,
          tags: [],
          packId: 'neo',
        ),
        AlgoliaFlashcard(
          objectID: '2',
          question: 'Palivizumab dose',
          answer: '15 mg/kg monthly',
          isPaid: false,
          tags: [],
          packId: 'neo-drugs',
        ),
        AlgoliaFlashcard(
          objectID: '3',
          question: 'Palivizumab in CHD',
          answer: 'Hemodynamically significant CHD',
          isPaid: false,
          tags: [],
          packId: 'cardio',
        ),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('searching while studying can stay inside the pack', () async {
    final repo = FlashcardsSearcherRepository(
      flashcardsSearcherService: _Service(),
    );
    Future<List<String>> ids(Set<String>? packs) async {
      final result = await repo.searchFlashcards(
        query: 'palivizumab',
        tags: const [],
        page: 0,
        packIds: packs,
      );
      return (result as Ok).value.hits
          .map<String>((card) => card.objectID as String)
          .toList();
    }

    // The pack and its sub-pack.
    expect(await ids({'neo', 'neo-drugs'}), ['1', '2']);
    expect(await ids(null), ['1', '2', '3']);
  });
}
