import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:flashcards/data/remote/algolia_service.dart';
import 'package:flashcards/utils/result.dart';

class PacksSearcherService {
  final AlgoliaService _algolia;
  final String _packsIndex;
  final List<String> _packsFacets;

  PacksSearcherService({required AlgoliaService algoliaService})
    : _algolia = algoliaService,
      _packsIndex = algoliaService.packsIndex,
      _packsFacets = algoliaService.packsFacets;

  Future<Result<SearchResponse>> search({
    required String query,
    required List<String> tagIds,
    required int page,
  }) async {
    try {
      final tagsQuery = tagIds.buildTagsAndQuery(_packsFacets[0]);

      final request = SearchForHits(
        indexName: _packsIndex,
        query: query,
        facets: _packsFacets,
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
