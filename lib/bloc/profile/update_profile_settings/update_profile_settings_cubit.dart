import 'package:flashcards/bloc/profile/update_profile_settings/update_profile_settings_state.dart';
import 'package:flashcards/data/repositories/users/profile_repository.dart';
import 'package:flashcards/data/services/api/dto/users/profile/update_profile/update_profile_dto.dart';
import 'package:flashcards/data/services/api/dto/users/profile/update_profile/update_profile_settings/update_profile_settings_dto.dart';
import 'package:flashcards/domain/models/profile/profile_settings/profile_settings.dart';
import 'package:flashcards/utils/form_validations.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateProfileSettingsCubit extends Cubit<UpdateProfileSettingsState> {
  final ProfileRepository _profileRepo;

  UpdateProfileSettingsCubit({required ProfileRepository profileRepo})
    : _profileRepo = profileRepo,
      super(UpdateProfileSettingsDisabled());

  void enableForm() {
    emit(UpdateProfileSettingsEnabled());
  }

  void disableForm() {
    emit(UpdateProfileSettingsDisabled());
  }

  Future<void> updateProfileSettings({
    required ProfileSettings currentSettings,
    required String cardsPerSessionString,
  }) async {
    emit(UpdateProfileSettingsLoading());

    final validationResult = _validateForm(cardsPerSessionString);
    if (validationResult.errors.isNotEmpty) {
      emit(UpdateProfileSettingsFormInvalid(errors: validationResult.errors));
      return;
    }

    final cardsPerSession = validationResult.parsedValue!;
    final newSettings = currentSettings.copyWith(
      cardsPerSession: cardsPerSession,
    );
    if (currentSettings == newSettings) {
      emit(UpdateProfileSettingsError(message: "All set — nothing to update"));
      return;
    }

    final updateDto = UpdateProfileDto(
      profileSettings: UpdateProfileSettingsDto(
        cardsPerSession: cardsPerSession,
      ),
    );
    var result = await _profileRepo.updateCurrentProfile(updateDto);

    switch (result) {
      case Ok<void>():
        emit(UpdateProfileSettingsSuccessful());
        break;
      case Error<void>(:final error):
        emit(UpdateProfileSettingsError(message: error.toString()));
        break;
    }
  }

  _ValidationResult _validateForm(String cardsPerSession) {
    final Map<String, String> errors = {};
    final parsedValue = int.tryParse(cardsPerSession);
    if (parsedValue == null) {
      putErrorIfExists(errors, 'cardsPerSession', "أدخل رقماً");
      return _ValidationResult(errors: errors, parsedValue: parsedValue);
    }

    putErrorIfExists(
      errors,
      'cardsPerSession',
      validateCardsPerSession(parsedValue),
    );
    return _ValidationResult(errors: errors, parsedValue: parsedValue);
  }
}

class _ValidationResult {
  final Map<String, String> errors;
  final int? parsedValue;

  const _ValidationResult({required this.errors, required this.parsedValue});
}
