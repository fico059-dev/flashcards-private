// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FlashcardDto _$FlashcardDtoFromJson(Map<String, dynamic> json) =>
    _FlashcardDto(
      id: json['id'] as String?,
      packId: json['packId'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      isPaid: json['isPaid'] as bool,
      questionImageUrl: json['questionImageUrl'] as String? ?? null,
      answerImageUrl: json['answerImageUrl'] as String? ?? null,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      sourceKey: json['sourceKey'] as String?,
      sourceImages: json['sourceImages'] as String?,
    );

Map<String, dynamic> _$FlashcardDtoToJson(_FlashcardDto instance) =>
    <String, dynamic>{
      'packId': instance.packId,
      'question': instance.question,
      'answer': instance.answer,
      'isPaid': instance.isPaid,
      'questionImageUrl': instance.questionImageUrl,
      'answerImageUrl': instance.answerImageUrl,
      'tags': instance.tags,
      'sourceKey': ?instance.sourceKey,
      'sourceImages': ?instance.sourceImages,
    };
