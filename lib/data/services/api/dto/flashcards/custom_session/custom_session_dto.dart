import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards/data/mappers/datetime_timestamp_converter.dart';
import 'package:flashcards/domain/models/flashcards/custom_session_summary/custom_session_summary.dart';
import 'package:flashcards/utils/typedefs.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_session_dto.freezed.dart';

part 'custom_session_dto.g.dart';

@freezed
abstract class CustomSessionDto with _$CustomSessionDto {
  const factory CustomSessionDto({
    String? id,
    required String profileId,
    required int currentIndex,
    required bool isPaid,

    /// Number of flashcards answered right
    required int correctCount,
    required int cardCount,
    @DatetimeTimestampConverter() required DateTime createdAt,

    /// Set by the student, older sessions don't have one.
    String? name,
  }) = _CustomSessionDto;

  factory CustomSessionDto.fromJson(JsonMap json) =>
      _$CustomSessionDtoFromJson(json);

  factory CustomSessionDto.fromJsonWithId(JsonMap json, String id) =>
      CustomSessionDto.fromJson(json).copyWith(id: id);
}

extension CustomSessionDtoX on CustomSessionDto {
  CustomSessionSummary toCustomSessionSummary() => CustomSessionSummary(
    id: id!,
    createdAt: createdAt,
    cardCount: cardCount,
    currentIndex: currentIndex,
    correctCount: correctCount,
    isPaid: isPaid,
    name: name,
  );
}
