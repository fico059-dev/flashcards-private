import 'dart:async';

import 'package:flashcards/data/services/local/study_log_store.dart';
import 'package:flashcards/domain/models/progress/level.dart';
import 'package:flashcards/domain/models/progress/study_log.dart';
import 'package:flutter/foundation.dart';
import 'package:fsrs/fsrs.dart' show Rating;

/// Something worth celebrating while studying.
sealed class StudyReward {
  const StudyReward();
}

/// A share of the goal (see [goalMilestones]) was reached.
class MilestoneReward extends StudyReward {
  final int percent;
  final int studied;
  final int target;
  final int bonusXp;

  const MilestoneReward({
    required this.percent,
    required this.studied,
    required this.target,
    required this.bonusXp,
  });
}

/// The student reached a new level.
class LevelUpReward extends StudyReward {
  final LevelInfo level;

  const LevelUpReward(this.level);
}

/// What happened in one study session, shown when it ends.
class SessionSummary {
  final DateTime startedAt;
  final DateTime lastReviewAt;
  final int reviewed;
  final int newCards;
  final int again;
  final int hard;
  final int good;
  final int easy;
  final int xpAtStart;
  final int xpNow;
  final List<int> milestones;

  /// Goal progress after the last review, when a goal is set.
  final GoalProgress? goal;

  const SessionSummary({
    required this.startedAt,
    required this.lastReviewAt,
    this.reviewed = 0,
    this.newCards = 0,
    this.again = 0,
    this.hard = 0,
    this.good = 0,
    this.easy = 0,
    required this.xpAtStart,
    required this.xpNow,
    this.milestones = const [],
    this.goal,
  });

  int get xpEarned => xpNow - xpAtStart;
  LevelInfo get levelAtStart => LevelInfo.fromXp(xpAtStart);
  LevelInfo get level => LevelInfo.fromXp(xpNow);
  int get levelsGained => level.level - levelAtStart.level;

  /// Cards remembered (not rated Again), out of those rated.
  double? get recall {
    final rated = again + hard + good + easy;
    return rated == 0 ? null : (rated - again) / rated;
  }

  Duration get duration => lastReviewAt.difference(startedAt);

  SessionSummary add({
    required DateTime now,
    required bool isNew,
    required Rating? rating,
    required int xpNow,
    required List<int> milestones,
    required GoalProgress? goal,
  }) => SessionSummary(
    startedAt: startedAt,
    lastReviewAt: now,
    reviewed: reviewed + 1,
    newCards: newCards + (isNew ? 1 : 0),
    again: again + (rating == Rating.again ? 1 : 0),
    hard: hard + (rating == Rating.hard ? 1 : 0),
    good: good + (rating == Rating.good ? 1 : 0),
    easy: easy + (rating == Rating.easy ? 1 : 0),
    xpAtStart: xpAtStart,
    xpNow: xpNow,
    milestones: [...this.milestones, ...milestones],
    goal: goal,
  );
}

/// Records every review in the study log and turns it into XP, levels and
/// goal milestones for the study screens to celebrate.
class StudyRewards {
  final StudyLogStore _store;
  final DateTime Function() _now;
  final _rewards = StreamController<StudyReward>.broadcast();

  // Reviews are recorded once saved, which can be just after the session
  // screen ends, so the summary is shown as it updates.
  final _session = ValueNotifier<SessionSummary?>(null);

  /// XP of the user's other devices, added to this device's own.
  Future<int>? _otherDevicesXp;

  StudyRewards({required StudyLogStore store, DateTime Function()? now})
    : _store = store,
      _now = now ?? DateTime.now;

  Stream<StudyReward> get rewards => _rewards.stream;

  /// The current (or last) session, for the summary.
  SessionSummary? get session => _session.value;

  ValueListenable<SessionSummary?> get sessionListenable => _session;

  /// Starts counting a new session.
  Future<void> startSession() async {
    _otherDevicesXp = _loadOtherDevicesXp();
    final xp = await currentXp();
    final now = _now();
    _session.value = SessionSummary(
      startedAt: now,
      lastReviewAt: now,
      xpAtStart: xp,
      xpNow: xp,
      goal: (await _store.load()).goalProgress,
    );
  }

  /// XP of all the user's devices.
  Future<int> currentXp() async {
    final others = await (_otherDevicesXp ??= _loadOtherDevicesXp());
    return others + (await _store.load()).xp;
  }

  Future<int> _loadOtherDevicesXp() async {
    try {
      final combined = await _store.loadCombined();
      final local = await _store.load();
      return combined.xp - local.xp;
    } catch (_) {
      return 0;
    }
  }

  /// Records one rated card. Returns what it earned.
  Future<List<StudyReward>> recordReview({
    required String packId,
    required bool isNew,
    required bool forgot,
    Rating? rating,
  }) async {
    if (_session.value == null) await startSession();
    final now = _now();
    var milestones = const <int>[];
    var xpBefore = 0;
    final log = await _store.update((log) {
      xpBefore = log.xp;
      var updated = log.recordReview(now: now, isNew: isNew, forgot: forgot);
      if (isNew) {
        final (withGoal, reached) = updated.recordGoalCard(packId);
        updated = withGoal;
        milestones = reached;
      }
      return updated;
    });

    final others = await (_otherDevicesXp ?? Future.value(0));
    final totalBefore = others + xpBefore;
    final totalNow = others + log.xp;
    _session.value = _session.value!.add(
      now: now,
      isNew: isNew,
      rating: rating,
      xpNow: totalNow,
      milestones: milestones,
      goal: log.goalProgress,
    );

    final progress = log.goalProgress;
    final earned = <StudyReward>[
      for (final m in milestones)
        MilestoneReward(
          percent: m,
          studied: progress?.estimate ?? 0,
          target: progress?.target ?? 0,
          bonusXp: milestoneBonusXp[m] ?? 0,
        ),
      if (LevelInfo.fromXp(totalNow).level >
          LevelInfo.fromXp(totalBefore).level)
        LevelUpReward(LevelInfo.fromXp(totalNow)),
    ];
    earned.forEach(_rewards.add);
    return earned;
  }

  void dispose() {
    _rewards.close();
    _session.dispose();
  }
}
