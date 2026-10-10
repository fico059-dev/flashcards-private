import 'package:flashcards/data/services/api/algolia_search/flashcards_searcher_service.dart';
import 'package:flashcards/data/services/api/algolia_search/local_search.dart';
import 'package:flashcards/domain/models/algolia/algolia_flashcard/algolia_flashcard.dart';
import 'package:flashcards/domain/models/algolia/pack_search_result/search_result_with_tags.dart';
import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:flashcards/utils/result.dart';

class FlashcardsSearcherRepository {
  final FlashcardsSearcherService _flashcardsSearcherService;

  /// Flashcards are kept for a while, since there can be many of them and
  /// every keystroke runs a search.
  static const _cacheDuration = Duration(minutes: 10);
  List<LocalSearchItem<AlgoliaFlashcard>>? _items;
  DateTime? _loadedAt;

  FlashcardsSearcherRepository({
    required FlashcardsSearcherService flashcardsSearcherService,
  }) : _flashcardsSearcherService = flashcardsSearcherService;

  /// Searches flashcards by question, answer and tags.
  Future<Result<SearchResultWithTags<AlgoliaFlashcard>>> searchFlashcards({
    required String query,
    required List<Tag> tags,
    required int page,
  }) async {
    final isStale =
        _loadedAt == null ||
        DateTime.now().difference(_loadedAt!) > _cacheDuration;
    if (_items == null || isStale) {
      final result = await _flashcardsSearcherService.getAllFlashcards();
      switch (result) {
        case Error<List<AlgoliaFlashcard>>(:final error):
          return Result.error(error);
        case Ok<List<AlgoliaFlashcard>>(:final value):
          _items = value
              .map(
                (card) => LocalSearchItem(
                  item: card,
                  text: '${card.question}\n${card.answer}',
                  tagIds: card.tags,
                ),
              )
              .toList();
          _loadedAt = DateTime.now();
      }
    }

    return Result.ok(
      searchLocally(
        items: _items!,
        query: query,
        tagIds: tags.map((tag) => tag.id).toList(),
        page: page,
      ),
    );
  }
}
