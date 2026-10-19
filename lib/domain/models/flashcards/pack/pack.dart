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
    @Default('verbal') String section,
  }) = _Pack;
}

extension PackX on Pack {
  List<Tag> get tags => tagCounts.keys.map((id) => Tag.fromId(id)).toList();
}
