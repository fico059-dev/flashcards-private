import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result_with_tags.freezed.dart';

@freezed
abstract class SearchResultWithTags<T> with _$SearchResultWithTags<T> {
  const factory SearchResultWithTags({
    required List<T> hits,
    required List<MapEntry<Tag, int>> tagCounts,
    required int pageKey,
    required int? nextPageKey,
    required bool isLastPage,
    required int hitCount,
  }) = _SearchResultWithTags<T>;
}
