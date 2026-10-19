import 'package:flashcards/domain/models/algolia/pack_search_result/search_result_with_tags.dart';
import 'package:flashcards/domain/models/flashcards/tag/tag.dart';

/// Results per page, same as Algolia's default.
const searchPageSize = 20;

/// Something that can be found by [searchLocally].
class LocalSearchItem<T> {
  final T item;

  /// Lowercase text the query is matched against.
  final String text;
  final List<String> tagIds;

  LocalSearchItem({
    required this.item,
    required String text,
    required this.tagIds,
  }) : text = text.toLowerCase();
}

/// Searches [items] on the device. Every word of [query] must appear in the
/// item's text and the item must have every tag in [tagIds]. Tag counts are
/// returned for every known tag, counting only the matching items, like the
/// facets Algolia used to return.
SearchResultWithTags<T> searchLocally<T>({
  required List<LocalSearchItem<T>> items,
  required String query,
  required List<String> tagIds,
  required int page,
}) {
  final words = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();

  final matches = items
      .where(
        (item) =>
            words.every(item.text.contains) &&
            tagIds.every(item.tagIds.contains),
      )
      .toList();

  final counts = <String, int>{};
  for (final item in items) {
    for (final tag in item.tagIds) {
      counts.putIfAbsent(tag, () => 0);
    }
  }
  for (final item in matches) {
    for (final tag in item.tagIds) {
      counts[tag] = counts[tag]! + 1;
    }
  }
  final tagCounts =
      counts.entries.map((e) => MapEntry(Tag.fromId(e.key), e.value)).toList()
        ..sort((a, b) => a.key.id.compareTo(b.key.id));

  final start = page * searchPageSize;
  final hits = matches
      .skip(start)
      .take(searchPageSize)
      .map((match) => match.item)
      .toList();
  final isLastPage = start + searchPageSize >= matches.length;

  return SearchResultWithTags(
    hits: hits,
    tagCounts: tagCounts,
    pageKey: page,
    nextPageKey: isLastPage ? null : page + 1,
    isLastPage: isLastPage,
    hitCount: matches.length,
  );
}
