// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_flashcard_snapshot_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateFlashcardSnapshotDto _$UpdateFlashcardSnapshotDtoFromJson(
  Map<String, dynamic> json,
) => _UpdateFlashcardSnapshotDto(
  packId: json['packId'] as String?,
  question: json['question'] as String?,
  answer: json['answer'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$UpdateFlashcardSnapshotDtoToJson(
  _UpdateFlashcardSnapshotDto instance,
) => <String, dynamic>{
  'packId': ?instance.packId,
  'question': ?instance.question,
  'answer': ?instance.answer,
  'tags': ?instance.tags,
};
