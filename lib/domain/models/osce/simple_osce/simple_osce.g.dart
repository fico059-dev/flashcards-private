// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_osce.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SimpleOsce _$SimpleOsceFromJson(Map<String, dynamic> json) => _SimpleOsce(
  id: json['id'] as String,
  name: json['name'] as String,
  scenario: json['scenario'] as String,
  isPaid: json['isPaid'] as bool,
  folderId: json['folderId'] as String?,
  scenarioImageUrl: json['scenarioImageUrl'] as String?,
);

Map<String, dynamic> _$SimpleOsceToJson(_SimpleOsce instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'scenario': instance.scenario,
      'isPaid': instance.isPaid,
      'folderId': instance.folderId,
      'scenarioImageUrl': instance.scenarioImageUrl,
    };
