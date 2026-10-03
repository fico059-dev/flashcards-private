import 'package:flashcards/data/services/api/users/auth_service.dart';
import 'package:flashcards/domain/models/progress/study_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps each user's [StudyLog] on the device.
class StudyLogStore {
  final AuthService _authService;
  final SharedPreferencesAsync _prefs;

  // Reviews can be saved quickly one after another, so writes are chained to
  // keep them from overwriting each other.
  Future<void> _pending = Future.value();

  StudyLogStore({
    required AuthService authService,
    SharedPreferencesAsync? prefs,
  }) : _authService = authService,
       _prefs = prefs ?? SharedPreferencesAsync();

  String? get _key {
    final uid = _authService.getCurrentUser()?.uid;
    return uid == null ? null : 'study_log_$uid';
  }

  Future<StudyLog> load() async {
    await _pending;
    final key = _key;
    if (key == null) return const StudyLog();
    try {
      return StudyLog.decode(await _prefs.getString(key));
    } on Object {
      return const StudyLog();
    }
  }

  /// Applies [change] to the stored log and returns the new log.
  Future<StudyLog> update(StudyLog Function(StudyLog log) change) {
    final result = _pending.then((_) async {
      final key = _key;
      if (key == null) return const StudyLog();
      StudyLog current;
      try {
        current = StudyLog.decode(await _prefs.getString(key));
      } on Object {
        current = const StudyLog();
      }
      final updated = change(current);
      try {
        await _prefs.setString(key, updated.encode());
      } on Object {
        // Progress history is a nice to have, never block studying for it.
      }
      return updated;
    });
    _pending = result.then((_) {}, onError: (_) {});
    return result;
  }
}
