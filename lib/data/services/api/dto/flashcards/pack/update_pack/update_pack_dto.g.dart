// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_pack_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdatePackDto _$UpdatePackDtoFromJson(Map<String, dynamic> json) =>
    _UpdatePackDto(
      name: json['name'] as String?,
      flashcardsCount: (json['flashcardsCount'] as num?)?.toInt(),
      tagCounts: (json['tagCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UpdatePackDtoToJson(_UpdatePackDto instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'flashcardsCount': ?instance.flashcardsCount,
      'tagCounts': ?instance.tagCounts,
      'tags': ?instance.tags,
    };
