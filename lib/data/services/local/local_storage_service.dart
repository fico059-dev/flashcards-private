import 'package:flashcards/bloc/theme/theme_cubit.dart';
import 'package:flashcards/data/services/api/users/auth_service.dart';
import 'package:flashcards/data/utils/data_utils.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationFrequency {
  none,
  onceDaily,
  twiceDaily,
  threePerWeek,
  oncePerWeek,
}

extension NotificationFrequencyX on NotificationFrequency {
  String get displayName {
    switch (this) {
      case NotificationFrequency.none:
        return "Never";
      case NotificationFrequency.onceDaily:
        return "Once per day";
      case NotificationFrequency.twiceDaily:
        return "Twice per day";
      case NotificationFrequency.threePerWeek:
        return "Three times per week";
      case NotificationFrequency.oncePerWeek:
        return "Once per week";
      default:
        return "No display name";
    }
  }
}

class LocalStorageService {
  late final SharedPreferencesAsync _sharedPrefAsync;
  late final AuthService _authService;

  LocalStorageService({required AuthService authService}) {
    _authService = authService;
    _sharedPrefAsync = SharedPreferencesAsync();
  }

  // Theme mode
  String _getThemeModeKey() {
    return "theme_mode";
  }

  Future<ThemeMode> getThemeMode() async {
    final themeString =
        await _sharedPrefAsync.getString(_getThemeModeKey()) ??
        ThemeMode.system.toStorageString();
    print("Read ${themeString.toThemeMode()}");
    return themeString.toThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    print("Setting mode ${mode.toStorageString()}");
    await _sharedPrefAsync.setString(
      _getThemeModeKey(),
      mode.toStorageString(),
    );
  }

  // Notification frequency functions

  String _getNotificationFrequencyKey() {
    //return "notification_frequency_${_getUid()}";
    return "notification_frequency";
  }

  Future<Result<NotificationFrequency>> getNotificationFrequency() async {
    try {
      final value = await _sharedPrefAsync.getString(
        _getNotificationFrequencyKey(),
      );
      if (value == null) {
        return Result.ok(NotificationFrequency.none);
      }

      final resultValue = NotificationFrequency.values.firstWhere(
        (element) => element.name == value,
        orElse: () => NotificationFrequency.none,
      );

      return Result.ok(resultValue);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> setNotificationFrequency(
    NotificationFrequency frequency,
  ) async {
    try {
      await _sharedPrefAsync.setString(
        _getNotificationFrequencyKey(),
        frequency.name,
      );

      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Flashcards tutorial seen functions
  String _getFlashcardsTutorialKey() {
    return "flashcards_tutorial_seen_${_getUid()}";
  }

  Future<bool> getFlashcardsTutorialSeen() async {
    return await _sharedPrefAsync.getBool(_getFlashcardsTutorialKey()) ?? false;
  }

  Future<void> setFlashcardsTutorialSeen({bool seen = true}) async {
    await _sharedPrefAsync.setBool(_getFlashcardsTutorialKey(), seen);
  }

  Future<void> removeFlashcardsTutorialSeen() async {
    await _sharedPrefAsync.remove(_getFlashcardsTutorialKey());
  }

  // Osce tutorial seen functions
  String _getOsceTutorialKey() {
    return "osce_tutorial_seen_${_getUid()}";
  }

  Future<bool> getOsceTutorialSeen() async {
    return await _sharedPrefAsync.getBool(_getOsceTutorialKey()) ?? false;
  }

  Future<void> setOsceTutorialSeen({bool seen = true}) async {
    await _sharedPrefAsync.setBool(_getOsceTutorialKey(), seen);
  }

  /// Whether OSCEs are practised in Learning mode (answers after each
  /// question) rather than Exam mode (answers at the end).
  Future<bool> getOsceLearningMode() async {
    return await _sharedPrefAsync.getBool(_getOsceModeKey()) ?? false;
  }

  Future<void> setOsceLearningMode(bool learning) async {
    await _sharedPrefAsync.setBool(_getOsceModeKey(), learning);
  }

  String _getOsceModeKey() => 'osce_learning_mode_${_getUid()}';

  Future<void> removeOsceTutorialSeen() async {
    await _sharedPrefAsync.remove(_getOsceTutorialKey());
  }

  Future<void> clearLocalStorage() async {
    await _sharedPrefAsync.clear();
  }

  String _getUid() {
    return getCurrentUserAndThrow(
      authService: _authService,
      repoName: "LocalStorageService",
    ).uid;
  }
}
