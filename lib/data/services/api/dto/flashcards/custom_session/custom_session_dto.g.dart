// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomSessionDto _$CustomSessionDtoFromJson(Map<String, dynamic> json) =>
    _CustomSessionDto(
      id: json['id'] as String?,
      profileId: json['profileId'] as String,
      currentIndex: (json['currentIndex'] as num).toInt(),
      isPaid: json['isPaid'] as bool,
      correctCount: (json['correctCount'] as num).toInt(),
      cardCount: (json['cardCount'] as num).toInt(),
      createdAt: const DatetimeTimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$CustomSessionDtoToJson(
  _CustomSessionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'profileId': instance.profileId,
  'currentIndex': instance.currentIndex,
  'isPaid': instance.isPaid,
  'correctCount': instance.correctCount,
  'cardCount': instance.cardCount,
  'createdAt': const DatetimeTimestampConverter().toJson(instance.createdAt),
  'name': instance.name,
};
