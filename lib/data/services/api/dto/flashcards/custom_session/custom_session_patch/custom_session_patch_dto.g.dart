// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_session_patch_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomSessionPatchDto _$CustomSessionPatchDtoFromJson(
  Map<String, dynamic> json,
) => _CustomSessionPatchDto(
  correctCount: (json['correctCount'] as num?)?.toInt(),
  currentIndex: (json['currentIndex'] as num?)?.toInt(),
);

Map<String, dynamic> _$CustomSessionPatchDtoToJson(
  _CustomSessionPatchDto instance,
) => <String, dynamic>{
  'correctCount': ?instance.correctCount,
  'currentIndex': ?instance.currentIndex,
};
