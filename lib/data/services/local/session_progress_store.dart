import 'package:flashcards/data/services/local/study_log_store.dart';
import 'package:flashcards/domain/models/progress/study_log.dart' show dayKey;
import 'package:shared_preferences/shared_preferences.dart';

/// How many cards of today's session target were studied in each pack, so
/// closing and opening a pack again continues the session instead of
/// starting a new one. Starts over every day.
///
/// With a [StudyLogStore] the counts and chosen targets are kept in the study
/// history, which is shared online, so the phone, the website and other
/// devices of the same account continue the same session. Without one they
/// stay on this device.
class SessionProgressStore {
  SharedPreferencesAsync? _prefsInstance;
  final StudyLogStore? _logStore;
  final DateTime Function() _now;

  /// How long a session start waits for the other devices' counts.
  static const syncWait = Duration(seconds: 5);

  // Created when first used, as storage isn't available everywhere (tests).
  SharedPreferencesAsync get _prefs =>
      _prefsInstance ??= SharedPreferencesAsync();

  SessionProgressStore({
    SharedPreferencesAsync? prefs,
    StudyLogStore? logStore,
    DateTime Function()? now,
  }) : _prefsInstance = prefs,
       _logStore = logStore,
       _now = now ?? DateTime.now;

  String _key(String uid, String packId) => 'session_progress_${uid}_$packId';

  /// Reads the other devices' latest counts; the next reads use them.
  Future<void> refresh() async {
    try {
      await _logStore?.loadCombined(fresh: true, timeout: syncWait);
    } catch (_) {
      // Offline: this device's counts are used.
    }
  }

  /// Cards of the target studied in the pack today, on all devices.
  Future<int> doneToday(String uid, String packId) async {
    final logStore = _logStore;
    if (logStore != null) {
      try {
        final log = await logStore.loadCombined(timeout: syncWait);
        return log.sessionDone(_now(), packId);
      } catch (_) {
        return 0;
      }
    }
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
    final logStore = _logStore;
    try {
      if (logStore != null) {
        await logStore.update((log) => log.addSessionCard(_now(), packId));
        return;
      }
      final done = await doneToday(uid, packId);
      await _prefs.setString(
        _key(uid, packId),
        '${dayKey(_now())}|${done + 1}',
      );
    } catch (_) {
      // Only the session counter is lost, never the card's progress.
    }
  }

  /// Sends this device's counts online now, e.g. when a session closes.
  Future<void> flush() async {
    try {
      await _logStore?.uploadNow();
    } catch (_) {
      // Sent with the next review.
    }
  }

  String _targetKey(String uid, String packId) =>
      'pack_session_target_${uid}_$packId';

  /// The session target the student chose for this pack, if any.
  Future<int?> packTarget(String uid, String packId) async {
    final logStore = _logStore;
    if (logStore != null) {
      try {
        final log = await logStore.loadCombined(timeout: syncWait);
        return log.packTarget(packId);
      } catch (_) {
        return null;
      }
    }
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
    final logStore = _logStore;
    try {
      if (logStore != null) {
        await logStore.update(
          (log) => log.setPackTarget(packId, target, _now()),
        );
        await logStore.uploadNow();
        return;
      }
      await _prefs.setString(_targetKey(uid, packId), '${target ?? 0}');
    } catch (_) {
      // Not saved: the default is used.
    }
  }
}
