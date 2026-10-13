import 'dart:convert';
import 'dart:math';

import 'package:flashcards/data/services/api/users/auth_service.dart';
import 'package:flashcards/data/services/local/study_log_store.dart';
import 'package:flashcards/domain/models/progress/study_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cards a day the exam goal needs: what is left divided by the days to the
/// exam (like "Needed: 70 new cards/day" on the Progress tab). Null when
/// there is no exam date or the goal hasn't been counted yet.
int? goalCardsPerDay(StudyLog log, DateTime now) {
  final exam = log.goal.examDate;
  final progress = log.goalProgress;
  if (exam == null || progress == null || progress.target <= 0) return null;
  final daysLeft = startOfDay(exam).difference(startOfDay(now)).inDays;
  if (daysLeft <= 0) return null;
  final remaining = max(0, progress.target - progress.estimate);
  if (remaining == 0) return null;
  return max(1, (remaining / daysLeft).ceil());
}

/// How the student is doing with today's cards, shown as a parrot.
enum DailyMood {
  /// Today's target is done.
  happy,

  /// Half of today's target is done.
  excited,

  /// Less than 4 hours left today and the target isn't done.
  anxious,

  /// Yesterday's target wasn't reached.
  sad,

  /// Nothing special: keep going.
  calm,
}

DailyMood dailyMood({
  required int done,
  required int target,
  required DateTime now,
  int? yesterdayDone,
  int? yesterdayTarget,
}) {
  if (target > 0 && done >= target) return DailyMood.happy;
  final midnight = startOfDay(now).add(const Duration(days: 1));
  if (midnight.difference(now) <= const Duration(hours: 4)) {
    return DailyMood.anxious;
  }
  if (target > 0 && done * 2 >= target) return DailyMood.excited;
  if (yesterdayTarget != null &&
      yesterdayTarget > 0 &&
      (yesterdayDone ?? 0) < yesterdayTarget) {
    return DailyMood.sad;
  }
  return DailyMood.calm;
}

/// Today's card target and how much of it is done.
class DailyStatus {
  final int target;
  final int done;
  final int? yesterdayTarget;
  final int? yesterdayDone;

  /// Whether the target comes from the exam goal (else cards per session).
  final bool fromGoal;
  final DailyMood mood;

  const DailyStatus({
    required this.target,
    required this.done,
    required this.fromGoal,
    required this.mood,
    this.yesterdayTarget,
    this.yesterdayDone,
  });

  double get progress => target <= 0 ? 0 : min(1.0, done / target);
}

/// Works out the day's card target. With an exam goal it is what the goal
/// needs per day; otherwise the student's cards per session. The target is
/// fixed for the day when first worked out, so studying doesn't move it.
class DailyTargetService {
  final StudyLogStore _logStore;
  final AuthService _auth;
  final DateTime Function() _now;
  SharedPreferencesAsync? _prefsInstance;

  SharedPreferencesAsync get _prefs =>
      _prefsInstance ??= SharedPreferencesAsync();

  DailyTargetService({
    required StudyLogStore logStore,
    required AuthService auth,
    SharedPreferencesAsync? prefs,
    DateTime Function()? now,
  }) : _logStore = logStore,
       _auth = auth,
       _prefsInstance = prefs,
       _now = now ?? DateTime.now;

  String? get _key {
    final uid = _auth.getCurrentUser()?.uid;
    return uid == null ? null : 'daily_targets_$uid';
  }

  Future<Map<String, int>> _readTargets() async {
    final key = _key;
    if (key == null) return {};
    try {
      final saved = await _prefs.getString(key);
      if (saved == null) return {};
      return (jsonDecode(saved) as Map<String, dynamic>).map(
        (day, value) => MapEntry(day, (value as num).toInt()),
      );
    } catch (_) {
      return {};
    }
  }

  /// Today's target, worked out once a day.
  Future<({int target, bool fromGoal})> todayTarget(int cardsPerSession) async {
    final now = _now();
    final today = dayKey(now);
    final log = await _logStore.load();
    final fromGoal = goalCardsPerDay(log, now);
    final targets = await _readTargets();
    final saved = targets[today];
    if (saved != null) {
      // Kept for the day, unless the goal was removed or set since.
      if (fromGoal != null) return (target: saved, fromGoal: true);
      return (target: cardsPerSession, fromGoal: false);
    }
    final target = fromGoal ?? cardsPerSession;
    final key = _key;
    if (key != null) {
      final oldest = dayKey(now.subtract(const Duration(days: 7)));
      final kept = {
        for (final e in targets.entries)
          if (e.key.compareTo(oldest) >= 0) e.key: e.value,
        today: target,
      };
      try {
        await _prefs.setString(key, jsonEncode(kept));
      } catch (_) {
        // The target is worked out again next time.
      }
    }
    return (target: target, fromGoal: fromGoal != null);
  }

  /// Whether studying [packIds] counts towards the exam goal's daily target.
  Future<bool> isGoalPack(Iterable<String> packIds) async {
    final log = await _logStore.load();
    if (goalCardsPerDay(log, _now()) == null) return false;
    return packIds.any(log.goal.includesPack);
  }

  /// Today's target, cards studied today and the mood that goes with it.
  Future<DailyStatus> status(int cardsPerSession) async {
    final now = _now();
    final today = await todayTarget(cardsPerSession);
    final log = await _logStore.load();
    final yesterday = now.subtract(const Duration(days: 1));
    final targets = await _readTargets();
    // Not opened yesterday: yesterday's target was likely the same.
    final studiedBefore = log.days.keys.any(
      (day) => day.compareTo(dayKey(yesterday)) < 0,
    );
    final yesterdayTarget =
        targets[dayKey(yesterday)] ?? (studiedBefore ? today.target : null);
    final done = log.activityOn(now).reviews;
    final yesterdayDone = log.activityOn(yesterday).reviews;
    return DailyStatus(
      target: today.target,
      done: done,
      fromGoal: today.fromGoal,
      yesterdayTarget: yesterdayTarget,
      yesterdayDone: yesterdayDone,
      mood: dailyMood(
        done: done,
        target: today.target,
        now: now,
        yesterdayDone: yesterdayDone,
        yesterdayTarget: yesterdayTarget,
      ),
    );
  }
}
