import 'package:flashcards/data/services/api/algolia_search/local_search.dart';
import 'package:flashcards/data/services/api/algolia_search/packs_searcher_service.dart';
import 'package:flashcards/domain/models/algolia/algolia_pack/algolia_pack.dart';
import 'package:flashcards/domain/models/algolia/pack_search_result/search_result_with_tags.dart';
import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:flashcards/utils/result.dart';

class PacksSearcherRepository {
  final PacksSearcherService _packSearcherService;

  /// Packs loaded for the current search. The first page of every search
  /// reloads them, so new or renamed packs show up right away.
  List<LocalSearchItem<AlgoliaPack>>? _items;

  PacksSearcherRepository({required PacksSearcherService packSearcherService})
    : _packSearcherService = packSearcherService;

  /// Searches packs by name and tags.
  Future<Result<SearchResultWithTags<AlgoliaPack>>> searchPacks({
    required String query,
    required List<Tag> tags,
    required int page,
  }) async {
    if (page == 0 || _items == null) {
      final result = await _packSearcherService.getAllPacks();
      switch (result) {
        case Error<List<AlgoliaPack>>(:final error):
          return Result.error(error);
        case Ok<List<AlgoliaPack>>(:final value):
          _items = value
              .map(
                (pack) => LocalSearchItem(
                  item: pack,
                  text: pack.name,
                  tagIds: pack.tags,
                ),
              )
              .toList();
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
