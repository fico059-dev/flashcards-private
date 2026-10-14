// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'algolia_flashcard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlgoliaFlashcard _$AlgoliaFlashcardFromJson(Map<String, dynamic> json) =>
    _AlgoliaFlashcard(
      objectID: json['objectID'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      isPaid: json['isPaid'] as bool,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      packId: json['packId'] as String? ?? '',
    );

Map<String, dynamic> _$AlgoliaFlashcardToJson(_AlgoliaFlashcard instance) =>
    <String, dynamic>{
      'objectID': instance.objectID,
      'question': instance.question,
      'answer': instance.answer,
      'isPaid': instance.isPaid,
      'tags': instance.tags,
      'packId': instance.packId,
    };
