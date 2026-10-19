// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'osce_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OsceDto _$OsceDtoFromJson(Map<String, dynamic> json) => _OsceDto(
  id: json['id'] as String?,
  name: json['name'] as String,
  scenario: json['scenario'] as String,
  questions: json['questions'] as List<dynamic>? ?? const <dynamic>[],
  isPaid: json['isPaid'] as bool? ?? false,
  folderId: json['folderId'] as String?,
  scenarioImageUrl: json['scenarioImageUrl'] as String?,
);

Map<String, dynamic> _$OsceDtoToJson(_OsceDto instance) => <String, dynamic>{
  'name': instance.name,
  'scenario': instance.scenario,
  'questions': instance.questions,
  'isPaid': instance.isPaid,
};
