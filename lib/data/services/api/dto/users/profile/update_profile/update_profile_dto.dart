import 'package:flashcards/data/services/api/dto/users/profile/update_profile/update_profile_settings/update_profile_settings_dto.dart';
import 'package:flashcards/domain/models/profile/education_level.dart';
import 'package:flashcards/domain/models/profile/streak/streak.dart';
import 'package:flashcards/utils/typedefs.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_profile_dto.freezed.dart';
part 'update_profile_dto.g.dart';

@freezed
abstract class UpdateProfileDto with _$UpdateProfileDto {
  @JsonSerializable(includeIfNull: false, explicitToJson: true)
  const factory UpdateProfileDto({
    String? name,
    String? surname,
    String? username,
    String? email,
    String? phoneNumber,
    EducationLevel? educationLevel,
    UpdateProfileSettingsDto? profileSettings,
    Streak? streak,
  }) = _UpdateProfileDto;

  factory UpdateProfileDto.fromJson(JsonMap json) =>
      _$UpdateProfileDtoFromJson(json);
}
