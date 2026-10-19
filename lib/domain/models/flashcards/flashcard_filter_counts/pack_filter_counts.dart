import 'package:flashcards/domain/enums/pack_selected_filter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pack_filter_counts.freezed.dart';

@freezed
abstract class PackFilterCounts with _$PackFilterCounts {
  const factory PackFilterCounts({
    required int allCount,
    required int seenCount,
    required int bookmarkedCount,
    required int ignoredCount,
  }) = _PackFilterCounts;
}

extension PackFilterCountsX on PackFilterCounts {
  /// Cards never studied (in regular study or a custom session), bookmarked
  /// or ignored, i.e. cards without a progress record.
  int get unseenCount => allCount - seenCount < 0 ? 0 : allCount - seenCount;

  int getCountForFilter(PackSelectedFilter filter) => switch (filter) {
    PackSelectedFilter.all => allCount,
    PackSelectedFilter.unseen => unseenCount,
    PackSelectedFilter.seen => seenCount,
    PackSelectedFilter.bookmarked => bookmarkedCount,
    PackSelectedFilter.ignored => ignoredCount,
  };
}
