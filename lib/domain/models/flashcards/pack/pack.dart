import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pack.freezed.dart';

@freezed
abstract class Pack with _$Pack {
  const factory Pack({
    required String id,
    required String name,
    required int flashcardsCount,
    required int dueCount,
    required int newCount,
    required int learningCount,
    @Default({}) Map<String, int> tagCounts,
    @Default(false) bool isPaid,

    /// The pack this one is shown inside, if any.
    String? parentId,

    /// Every pack inside this one (all levels). Studying this pack also
    /// studies their cards.
    @Default([]) List<Pack> subPacks,
  }) = _Pack;
}

extension PackX on Pack {
  List<Tag> get tags => tagCounts.keys.map((id) => Tag.fromId(id)).toList();
}
