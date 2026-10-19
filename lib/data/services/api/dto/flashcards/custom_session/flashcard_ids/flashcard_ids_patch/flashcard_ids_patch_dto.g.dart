// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_ids_patch_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FlashcardIdsPatchDto _$FlashcardIdsPatchDtoFromJson(
  Map<String, dynamic> json,
) => _FlashcardIdsPatchDto(
  flashcardIds: (json['flashcardIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$FlashcardIdsPatchDtoToJson(
  _FlashcardIdsPatchDto instance,
) => <String, dynamic>{'flashcardIds': ?instance.flashcardIds};
