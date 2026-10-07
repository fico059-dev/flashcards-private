// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackDto _$PackDtoFromJson(Map<String, dynamic> json) => _PackDto(
  id: json['id'] as String?,
  name: json['name'] as String,
  flashcardsCount: (json['flashcardsCount'] as num).toInt(),
  tagCounts:
      (json['tagCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isPaid: json['isPaid'] as bool? ?? false,
  allowedEmails:
      (json['allowedEmails'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$PackDtoToJson(_PackDto instance) => <String, dynamic>{
  'name': instance.name,
  'flashcardsCount': instance.flashcardsCount,
  'tagCounts': instance.tagCounts,
  'tags': instance.tags,
  'isPaid': instance.isPaid,
};
