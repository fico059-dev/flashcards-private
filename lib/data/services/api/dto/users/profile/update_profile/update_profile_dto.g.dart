// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateProfileDto _$UpdateProfileDtoFromJson(Map<String, dynamic> json) =>
    _UpdateProfileDto(
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      educationLevel: $enumDecodeNullable(
        _$EducationLevelEnumMap,
        json['educationLevel'],
      ),
      profileSettings: json['profileSettings'] == null
          ? null
          : UpdateProfileSettingsDto.fromJson(
              json['profileSettings'] as Map<String, dynamic>,
            ),
      streak: json['streak'] == null
          ? null
          : Streak.fromJson(json['streak'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateProfileDtoToJson(_UpdateProfileDto instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'surname': ?instance.surname,
      'username': ?instance.username,
      'email': ?instance.email,
      'phoneNumber': ?instance.phoneNumber,
      'educationLevel': ?_$EducationLevelEnumMap[instance.educationLevel],
      'profileSettings': ?instance.profileSettings?.toJson(),
      'streak': ?instance.streak?.toJson(),
    };

const _$EducationLevelEnumMap = {
  EducationLevel.highSchoolStudent: 'highSchoolStudent',
  EducationLevel.graduate: 'graduate',
  EducationLevel.universityStudent: 'universityStudent',
  EducationLevel.other: 'other',
};
