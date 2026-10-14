import 'package:flashcards/domain/models/progress/study_log.dart' show dayKey;
import 'package:shared_preferences/shared_preferences.dart';

/// How many cards of today's session target were studied in each pack, so
/// closing and opening a pack again continues the session instead of
/// starting a new one. Starts over every day.
class SessionProgressStore {
  SharedPreferencesAsync? _prefsInstance;
  final DateTime Function() _now;

  // Created when first used, as storage isn't available everywhere (tests).
  SharedPreferencesAsync get _prefs =>
      _prefsInstance ??= SharedPreferencesAsync();

  SessionProgressStore({
    SharedPreferencesAsync? prefs,
    DateTime Function()? now,
  }) : _prefsInstance = prefs,
       _now = now ?? DateTime.now;

  String _key(String uid, String packId) => 'session_progress_${uid}_$packId';

  /// Cards of the target studied in the pack today.
  Future<int> doneToday(String uid, String packId) async {
    try {
      final saved = await _prefs.getString(_key(uid, packId));
      if (saved == null) return 0;
      final [day, count] = saved.split('|');
      if (day != dayKey(_now())) return 0;
      return int.tryParse(count) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Counts one more studied card.
  Future<void> add(String uid, String packId) async {
    try {
      final done = await doneToday(uid, packId);
      await _prefs.setString(
        _key(uid, packId),
        '${dayKey(_now())}|${done + 1}',
      );
    } catch (_) {
      // Only the session counter is lost, never the card's progress.
    }
  }

  String _targetKey(String uid, String packId) =>
      'pack_session_target_${uid}_$packId';

  /// The session target the student chose for this pack, if any.
  Future<int?> packTarget(String uid, String packId) async {
    try {
      final saved = await _prefs.getString(_targetKey(uid, packId));
      final value = saved == null ? null : int.tryParse(saved);
      return value == null || value <= 0 ? null : value;
    } catch (_) {
      return null;
    }
  }

  /// Sets this pack's session target, or with null goes back to the
  /// default (the exam goal, else the cards per session).
  Future<void> setPackTarget(String uid, String packId, int? target) async {
    try {
      await _prefs.setString(_targetKey(uid, packId), '${target ?? 0}');
    } catch (_) {
      // Not saved: the default is used.
    }
  }
}
