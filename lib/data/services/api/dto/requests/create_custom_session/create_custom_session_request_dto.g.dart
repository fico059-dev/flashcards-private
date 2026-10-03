// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_custom_session_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateCustomSessionRequestDto _$CreateCustomSessionRequestDtoFromJson(
  Map<String, dynamic> json,
) => _CreateCustomSessionRequestDto(
  profileId: json['profileId'] as String,
  filter: $enumDecode(_$PackSelectedFilterEnumMap, json['filter']),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  packIds: (json['packIds'] as List<dynamic>).map((e) => e as String).toList(),
  sessionSize: (json['sessionSize'] as num).toInt(),
);

Map<String, dynamic> _$CreateCustomSessionRequestDtoToJson(
  _CreateCustomSessionRequestDto instance,
) => <String, dynamic>{
  'profileId': instance.profileId,
  'filter': _$PackSelectedFilterEnumMap[instance.filter]!,
  'tags': instance.tags,
  'packIds': instance.packIds,
  'sessionSize': instance.sessionSize,
};

const _$PackSelectedFilterEnumMap = {
  PackSelectedFilter.all: 'all',
  PackSelectedFilter.unseen: 'unseen',
  PackSelectedFilter.seen: 'seen',
  PackSelectedFilter.bookmarked: 'bookmarked',
  PackSelectedFilter.ignored: 'ignored',
};
