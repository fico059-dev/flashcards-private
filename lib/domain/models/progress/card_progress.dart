import 'dart:math';

import 'package:flashcards/domain/models/progress/study_log.dart';
import 'package:fsrs/fsrs.dart';

/// A card is "mastered" once FSRS expects to remember it for three weeks.
const masteredStabilityDays = 21.0;

/// FSRS difficulty goes from 1 (easy) to 10 (hard).
const hardDifficulty = 7.0;

/// The student's progress on one card, from fcp_data.
class CardProgressItem {
  final String flashcardId;
  final String packId;
  final String question;
  final List<String> tags;
  final Card card;
  final bool ignored;

  const CardProgressItem({
    required this.flashcardId,
    required this.packId,
    required this.question,
    required this.tags,
    required this.card,
    this.ignored = false,
  });

  bool get isStudied => card.state != State.newState && card.reps > 0;

  bool get isMastered =>
      card.state == State.review && card.stability >= masteredStabilityDays;

  bool get isLearning =>
      card.state == State.learning || card.state == State.relearning;

  bool isDue(DateTime now) => isStudied && !ignored && !card.due.isAfter(now);
}

class PackInfo {
  final String id;
  final String name;
  final int totalCards;

  const PackInfo({
    required this.id,
    required this.name,
    required this.totalCards,
  });
}

class PackProgressStat {
  final String packId;
  final String name;
  final int total;
  final int studied;
  final int mastered;
  final int learning;
  final int due;
  final double averageDifficulty;

  const PackProgressStat({
    required this.packId,
    required this.name,
    required this.total,
    required this.studied,
    required this.mastered,
    required this.learning,
    required this.due,
    required this.averageDifficulty,
  });

  int get unseen => max(0, total - studied);
  double get coverage => total == 0 ? 0 : min(1, studied / total);
  double get masteredShare => total == 0 ? 0 : min(1, mastered / total);
}

/// A topic (tag) that causes trouble.
class TopicStat {
  final String tagId;
  final int studied;
  final int lapses;
  final int reps;
  final double averageDifficulty;
  final int mastered;

  const TopicStat({
    required this.tagId,
    required this.studied,
    required this.lapses,
    required this.reps,
    required this.averageDifficulty,
    required this.mastered,
  });

  String get name => tagId
      .replaceAll('__', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  /// Share of reviews that ended with the card forgotten.
  double get forgetRate => reps == 0 ? 0 : lapses / reps;

  /// 0 (fine) to 1 (very weak), mixing forgetting and difficulty.
  double get weakness =>
      (0.6 * min(1, forgetRate * 3) +
              0.4 * ((averageDifficulty - 1) / 9).clamp(0, 1))
          .toDouble();
}

enum TrajectoryStatus {
  noGoal,
  notStarted,
  onTrack,
  behind,
  reached,
  examPassed,
}

class Trajectory {
  final int target;
  final int studied;
  final DateTime? examDate;
  final int? daysLeft;

  /// Average new cards per day over the last two weeks.
  final double pace;

  /// New cards per day needed to reach [target] by [examDate].
  final int? requiredPerDay;
  final int? projectedAtExam;

  /// When [target] is reached at the current [pace].
  final DateTime? projectedFinish;
  final TrajectoryStatus status;

  /// Studied cards on past days, for the chart.
  final List<MapEntry<DateTime, int>> history;

  const Trajectory({
    required this.target,
    required this.studied,
    required this.examDate,
    required this.daysLeft,
    required this.pace,
    required this.requiredPerDay,
    required this.projectedAtExam,
    required this.projectedFinish,
    required this.status,
    required this.history,
  });

  int get remaining => max(0, target - studied);
  double get completion => target == 0 ? 0 : min(1, studied / target);
}

enum AdviceKind { review, newCards, weakTopic, pack, goal, praise }

class StudyAdvice {
  final AdviceKind kind;
  final String title;
  final String detail;

  const StudyAdvice(this.kind, this.title, this.detail);
}

class CardProgressStats {
  final int totalAvailable;
  final int studied;
  final int mastered;
  final int learning;
  final int young;
  final int dueNow;
  final int ignored;

  /// Average chance of recalling a reviewed card right now (0-1).
  final double? retention;

  /// Reviews per day for the last 14 days, oldest first.
  final List<DayActivity> activity;
  final int streak;
  final int reviewsThisWeek;

  /// Cards due on each of the next 14 days (index 0 includes overdue).
  final List<int> forecast;
  final List<PackProgressStat> packs;
  final List<TopicStat> weakTopics;
  final List<CardProgressItem> hardestCards;
  final Trajectory trajectory;
  final List<StudyAdvice> advice;

  const CardProgressStats({
    required this.totalAvailable,
    required this.studied,
    required this.mastered,
    required this.learning,
    required this.young,
    required this.dueNow,
    required this.ignored,
    required this.retention,
    required this.activity,
    required this.streak,
    required this.reviewsThisWeek,
    required this.forecast,
    required this.packs,
    required this.weakTopics,
    required this.hardestCards,
    required this.trajectory,
    required this.advice,
  });

  int get unseen => max(0, totalAvailable - studied);

  factory CardProgressStats.calculate({
    required List<CardProgressItem> items,
    required List<PackInfo> packs,
    required StudyLog log,
    required DateTime now,
  }) {
    final packIds = packs.map((p) => p.id).toSet();
    // Cards of packs that were deleted or aren't available any more.
    final cards = items.where((i) => packIds.contains(i.packId)).toList();
    final studiedCards = cards.where((c) => c.isStudied).toList();

    final totalAvailable = packs.fold(0, (sum, p) => sum + p.totalCards);
    final mastered = studiedCards.where((c) => c.isMastered).length;
    final learning = studiedCards.where((c) => c.isLearning).length;
    final dueNow = cards.where((c) => c.isDue(now)).length;

    final reviewed = studiedCards.where((c) => c.card.state == State.review);
    final recall = reviewed
        .map((c) => c.card.getRetrievability(now))
        .whereType<double>()
        .toList();

    final today = startOfDay(now);
    final activity = [
      for (var i = 13; i >= 0; i--)
        log.activityOn(today.subtract(Duration(days: i))),
    ];

    final forecast = List.filled(14, 0);
    for (final card in studiedCards.where((c) => !c.ignored)) {
      final day = startOfDay(card.card.due).difference(today).inDays;
      if (day < 14) forecast[max(0, day)]++;
    }

    final packStats = [
      for (final pack in packs)
        _packStat(pack, studiedCards.where((c) => c.packId == pack.id), now),
    ];

    final weakTopics = _topics(studiedCards)
      ..removeWhere((t) => t.studied < 3 || t.weakness < 0.2)
      ..sort((a, b) => b.weakness.compareTo(a.weakness));

    final hardest =
        studiedCards
            .where(
              (c) => c.card.lapses > 0 || c.card.difficulty >= hardDifficulty,
            )
            .toList()
          ..sort((a, b) {
            final byLapses = b.card.lapses.compareTo(a.card.lapses);
            return byLapses != 0
                ? byLapses
                : b.card.difficulty.compareTo(a.card.difficulty);
          });

    final trajectory = _trajectory(
      log: log,
      studied: studiedCards.length,
      totalAvailable: totalAvailable,
      now: now,
    );

    final stats = CardProgressStats(
      totalAvailable: totalAvailable,
      studied: studiedCards.length,
      mastered: mastered,
      learning: learning,
      young: studiedCards.length - mastered - learning,
      dueNow: dueNow,
      ignored: cards.where((c) => c.ignored).length,
      retention: recall.isEmpty
          ? null
          : recall.reduce((a, b) => a + b) / recall.length,
      activity: activity,
      streak: _streak(log, today),
      reviewsThisWeek: activity
          .skip(7)
          .fold(0, (sum, day) => sum + day.reviews),
      forecast: forecast,
      packs: packStats,
      weakTopics: weakTopics.take(8).toList(),
      hardestCards: hardest.take(5).toList(),
      trajectory: trajectory,
      advice: const [],
    );
    return stats._withAdvice();
  }

  static PackProgressStat _packStat(
    PackInfo pack,
    Iterable<CardProgressItem> studied,
    DateTime now,
  ) {
    final list = studied.toList();
    return PackProgressStat(
      packId: pack.id,
      name: pack.name,
      total: pack.totalCards,
      studied: list.length,
      mastered: list.where((c) => c.isMastered).length,
      learning: list.where((c) => c.isLearning).length,
      due: list.where((c) => c.isDue(now)).length,
      averageDifficulty: list.isEmpty
          ? 0
          : list.fold(0.0, (sum, c) => sum + c.card.difficulty) / list.length,
    );
  }

  static List<TopicStat> _topics(List<CardProgressItem> studied) {
    final byTag = <String, List<CardProgressItem>>{};
    for (final card in studied) {
      for (final tag in card.tags.toSet()) {
        byTag.putIfAbsent(tag, () => []).add(card);
      }
    }
    return [
      for (final entry in byTag.entries)
        TopicStat(
          tagId: entry.key,
          studied: entry.value.length,
          lapses: entry.value.fold(0, (sum, c) => sum + c.card.lapses),
          reps: entry.value.fold(0, (sum, c) => sum + c.card.reps),
          averageDifficulty:
              entry.value.fold(0.0, (sum, c) => sum + c.card.difficulty) /
              entry.value.length,
          mastered: entry.value.where((c) => c.isMastered).length,
        ),
    ];
  }

  static int _streak(StudyLog log, DateTime today) {
    var streak = 0;
    var day = today;
    // Today still counts as part of the streak before studying.
    if (log.activityOn(day).reviews == 0) {
      day = day.subtract(const Duration(days: 1));
    }
    while (log.activityOn(day).reviews > 0) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static Trajectory _trajectory({
    required StudyLog log,
    required int studied,
    required int totalAvailable,
    required DateTime now,
  }) {
    final goal = log.goal;
    final today = startOfDay(now);
    final target = goal.targetCards ?? totalAvailable;

    // New cards per day over the last 14 days (fewer if the log is newer).
    final recentDays = [
      for (var i = 0; i < 14; i++)
        log.activityOn(today.subtract(Duration(days: i))),
    ];
    final firstLogged = log.days.keys.isEmpty
        ? null
        : DateTime.parse(
            log.days.keys.reduce((a, b) => a.compareTo(b) < 0 ? a : b),
          );
    final loggedDays = firstLogged == null
        ? 0
        : min(14, today.difference(firstLogged).inDays + 1);
    final newCards = recentDays.fold(0, (sum, d) => sum + d.newCards);
    final pace = loggedDays == 0 ? 0.0 : newCards / loggedDays;

    final history =
        log.studiedSnapshots.entries
            .map((e) => MapEntry(DateTime.parse(e.key), e.value))
            .where((e) => e.key.isBefore(today))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    history.add(MapEntry(today, studied));

    final exam = goal.examDate == null ? null : startOfDay(goal.examDate!);
    final daysLeft = exam?.difference(today).inDays;
    final remaining = max(0, target - studied);

    int? requiredPerDay;
    int? projectedAtExam;
    if (daysLeft != null && daysLeft > 0) {
      requiredPerDay = (remaining / daysLeft).ceil();
      projectedAtExam = min(
        max(target, totalAvailable),
        studied + (pace * daysLeft).round(),
      );
    }
    final projectedFinish = remaining == 0
        ? today
        : pace > 0
        ? today.add(Duration(days: (remaining / pace).ceil()))
        : null;

    final TrajectoryStatus status;
    if (goal.isEmpty) {
      status = TrajectoryStatus.noGoal;
    } else if (remaining == 0) {
      status = TrajectoryStatus.reached;
    } else if (daysLeft != null && daysLeft <= 0) {
      status = TrajectoryStatus.examPassed;
    } else if (pace == 0) {
      status = TrajectoryStatus.notStarted;
    } else if (daysLeft == null) {
      status = TrajectoryStatus.onTrack;
    } else {
      status = projectedAtExam! >= target
          ? TrajectoryStatus.onTrack
          : TrajectoryStatus.behind;
    }

    return Trajectory(
      target: target,
      studied: studied,
      examDate: exam,
      daysLeft: daysLeft,
      pace: pace,
      requiredPerDay: requiredPerDay,
      projectedAtExam: projectedAtExam,
      projectedFinish: projectedFinish,
      status: status,
      history: history,
    );
  }

  CardProgressStats _withAdvice() {
    final advice = <StudyAdvice>[];
    final t = trajectory;

    if (dueNow > 0) {
      advice.add(
        StudyAdvice(
          AdviceKind.review,
          "Review $dueNow due ${dueNow == 1 ? 'card' : 'cards'} first",
          "Reviewing on time keeps what you learned. Start each session with "
              "due cards before adding new ones.",
        ),
      );
    }

    if (t.status == TrajectoryStatus.behind && t.requiredPerDay != null) {
      advice.add(
        StudyAdvice(
          AdviceKind.goal,
          "Study ${t.requiredPerDay} new cards a day to reach your goal",
          "You're averaging ${t.pace.toStringAsFixed(1)} new cards a day; at "
              "this pace you'd reach ${t.projectedAtExam} of ${t.target} cards "
              "by your exam.",
        ),
      );
    } else if (t.status == TrajectoryStatus.notStarted &&
        t.requiredPerDay != null) {
      advice.add(
        StudyAdvice(
          AdviceKind.goal,
          "Aim for ${t.requiredPerDay} new cards a day",
          "That covers the ${t.remaining} cards left before your exam in "
              "${t.daysLeft} days.",
        ),
      );
    } else if (t.status == TrajectoryStatus.noGoal) {
      advice.add(
        const StudyAdvice(
          AdviceKind.goal,
          "Set your exam date and target",
          "You'll see how many cards a day you need and whether you're on "
              "track.",
        ),
      );
    }

    if (weakTopics.isNotEmpty) {
      final names = weakTopics.take(3).map((t) => t.name).join(', ');
      advice.add(
        StudyAdvice(
          AdviceKind.weakTopic,
          "Strengthen your weak topics: $names",
          "You forget these more often than other topics. Make a custom "
              "session with these tags.",
        ),
      );
    }

    final untouched = packs.where((p) => p.total > 0 && p.studied == 0).toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    final lowCoverage =
        packs
            .where((p) => p.total > 0 && p.studied > 0 && p.coverage < 0.5)
            .toList()
          ..sort((a, b) => a.coverage.compareTo(b.coverage));
    if (lowCoverage.isNotEmpty) {
      final pack = lowCoverage.first;
      advice.add(
        StudyAdvice(
          AdviceKind.pack,
          "Keep going with ${pack.name}",
          "Only ${(pack.coverage * 100).round()}% studied, ${pack.unseen} "
              "cards are still new.",
        ),
      );
    }
    if (untouched.isNotEmpty) {
      advice.add(
        StudyAdvice(
          AdviceKind.newCards,
          untouched.length == 1
              ? "You haven't started ${untouched.first.name}"
              : "${untouched.length} packs not started yet",
          "Start with ${untouched.first.name} "
          "(${untouched.first.total} cards).",
        ),
      );
    }

    if (advice.isEmpty || (dueNow == 0 && studied > 0 && streak >= 3)) {
      advice.add(
        StudyAdvice(
          AdviceKind.praise,
          streak >= 3 ? "$streak day streak, great work!" : "You're up to date",
          "Nothing is due right now. Learn new cards or review weak topics.",
        ),
      );
    }

    return CardProgressStats(
      totalAvailable: totalAvailable,
      studied: studied,
      mastered: mastered,
      learning: learning,
      young: young,
      dueNow: dueNow,
      ignored: ignored,
      retention: retention,
      activity: activity,
      streak: streak,
      reviewsThisWeek: reviewsThisWeek,
      forecast: forecast,
      packs: packs,
      weakTopics: weakTopics,
      hardestCards: hardestCards,
      trajectory: trajectory,
      advice: advice,
    );
  }
}
