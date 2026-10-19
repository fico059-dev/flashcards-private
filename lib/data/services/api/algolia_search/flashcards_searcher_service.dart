import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:flashcards/data/remote/algolia_service.dart';
import 'package:flashcards/utils/result.dart';

class FlashcardsSearcherService {
  final AlgoliaService _algolia;
  final String _flashcardsIndex;
  final List<String> _flashcardsFacets;

  FlashcardsSearcherService({required AlgoliaService algoliaService})
    : _algolia = algoliaService,
      _flashcardsFacets = algoliaService.flashcardsFacets,
      _flashcardsIndex = algoliaService.flashcardsIndex;

  Future<Result<SearchResponse>> search({
    required String query,
    required List<String> tagIds,
    required int page,
  }) async {
    try {
      final tagsQuery = tagIds.buildTagsAndQuery(_flashcardsFacets[0]);

      final request = SearchForHits(
        indexName: _flashcardsIndex,
        query: query,
        facets: _flashcardsFacets,
        facetFilters: tagsQuery,
        page: page,
      );

      final response = await _algolia.client.searchIndex(request: request);

      return Result.ok(response);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
