import 'dart:math';

import 'package:flashcards/domain/models/progress/card_progress.dart';
import 'package:flashcards/domain/models/progress/study_log.dart';

class OsceAttemptPoint {
  final DateTime date;
  final double percent;

  const OsceAttemptPoint(this.date, this.percent);
}

class OsceStationStat {
  final String osceId;
  final String name;

  /// Attempts oldest first.
  final List<OsceAttemptPoint> attempts;

  const OsceStationStat({
    required this.osceId,
    required this.name,
    required this.attempts,
  });

  double get best => attempts.map((a) => a.percent).fold(0, max);
  double get latest => attempts.last.percent;
  double get first => attempts.first.percent;
  double get improvement => latest - first;
  DateTime get lastDate => attempts.last.date;
}

class OsceWeakArea {
  final String stationName;
  final String text;
  final double percent;
  final int attempts;

  const OsceWeakArea({
    required this.stationName,
    required this.text,
    required this.percent,
    required this.attempts,
  });
}

class MissedCheck {
  final String stationName;
  final String text;
  final int times;

  const MissedCheck(this.stationName, this.text, this.times);
}

class OsceProgressStats {
  final int stationsTotal;
  final List<OsceStationStat> stations;
  final List<String> untriedStations;
  final List<OsceAttemptPoint> allAttempts;
  final int targetScore;
  final List<OsceWeakArea> weakAreas;
  final List<MissedCheck> missedChecks;
  final List<StudyAdvice> advice;

  const OsceProgressStats({
    required this.stationsTotal,
    required this.stations,
    required this.untriedStations,
    required this.allAttempts,
    required this.targetScore,
    required this.weakAreas,
    required this.missedChecks,
    required this.advice,
  });

  int get attemptsCount => allAttempts.length;

  double? get averageLatest => stations.isEmpty
      ? null
      : stations.fold(0.0, (sum, s) => sum + s.latest) / stations.length;

  double? get averageBest => stations.isEmpty
      ? null
      : stations.fold(0.0, (sum, s) => sum + s.best) / stations.length;

  int get stationsAtTarget =>
      stations.where((s) => s.latest >= targetScore).length;

  /// Stations sorted weakest (latest score) first.
  List<OsceStationStat> get weakestFirst =>
      [...stations]..sort((a, b) => a.latest.compareTo(b.latest));

  factory OsceProgressStats.calculate({
    required Map<String, String> allStations,
    required Map<String, List<OsceAttemptPoint>> attemptsByStation,
    required StudyLog log,
    required DateTime now,
  }) {
    final stations = <OsceStationStat>[];
    for (final entry in attemptsByStation.entries) {
      if (entry.value.isEmpty) continue;
      final attempts = [...entry.value]
        ..sort((a, b) => a.date.compareTo(b.date));
      stations.add(
        OsceStationStat(
          osceId: entry.key,
          name: allStations[entry.key] ?? log.osce[entry.key]?.name ?? 'OSCE',
          attempts: attempts,
        ),
      );
    }
    stations.sort((a, b) => a.name.compareTo(b.name));

    final tried = stations.map((s) => s.osceId).toSet();
    final untried =
        allStations.entries
            .where((e) => !tried.contains(e.key))
            .map((e) => e.value)
            .toList()
          ..sort();

    final allAttempts = [for (final s in stations) ...s.attempts]
      ..sort((a, b) => a.date.compareTo(b.date));

    final weakAreas = <OsceWeakArea>[];
    final missed = <MissedCheck>[];
    for (final entry in log.osce.entries) {
      final name = allStations[entry.key] ?? entry.value.name;
      for (final q in entry.value.questions.values) {
        if (q.max == 0 || q.percent >= 0.75) continue;
        weakAreas.add(
          OsceWeakArea(
            stationName: name,
            text: q.text,
            percent: q.percent * 100,
            attempts: q.attempts,
          ),
        );
      }
      entry.value.missedChecks.forEach(
        (text, times) => missed.add(MissedCheck(name, text, times)),
      );
    }
    weakAreas.sort((a, b) => a.percent.compareTo(b.percent));
    missed.sort((a, b) => b.times.compareTo(a.times));

    final stats = OsceProgressStats(
      stationsTotal: allStations.length,
      stations: stations,
      untriedStations: untried,
      allAttempts: allAttempts,
      targetScore: log.goal.targetOsceScore,
      weakAreas: weakAreas.take(6).toList(),
      missedChecks: missed.take(8).toList(),
      advice: const [],
    );
    return stats._withAdvice(now, log.goal);
  }

  OsceProgressStats _withAdvice(DateTime now, StudyGoal goal) {
    final advice = <StudyAdvice>[];
    final below = weakestFirst.where((s) => s.latest < targetScore).toList();

    if (below.isNotEmpty) {
      final station = below.first;
      advice.add(
        StudyAdvice(
          AdviceKind.weakTopic,
          "Retry ${station.name}",
          "Your last score was ${station.latest.round()}%, below your "
              "$targetScore% target.",
        ),
      );
    }
    if (weakAreas.isNotEmpty) {
      final area = weakAreas.first;
      advice.add(
        StudyAdvice(
          AdviceKind.weakTopic,
          "Work on \"${_short(area.text)}\"",
          "In ${area.stationName} you score ${area.percent.round()}% on this "
              "part.",
        ),
      );
    }
    final stale =
        stations.where((s) => now.difference(s.lastDate).inDays >= 14).toList()
          ..sort((a, b) => a.lastDate.compareTo(b.lastDate));
    if (stale.isNotEmpty) {
      advice.add(
        StudyAdvice(
          AdviceKind.review,
          "Revisit ${stale.first.name}",
          "You last practised it ${now.difference(stale.first.lastDate).inDays} "
              "days ago.",
        ),
      );
    }
    if (untriedStations.isNotEmpty) {
      advice.add(
        StudyAdvice(
          AdviceKind.newCards,
          untriedStations.length == 1
              ? "1 station not tried yet"
              : "${untriedStations.length} stations not tried yet",
          "Try ${untriedStations.first} next.",
        ),
      );
    }
    final daysLeft = goal.examDate == null
        ? null
        : startOfDay(goal.examDate!).difference(startOfDay(now)).inDays;
    if (daysLeft != null &&
        daysLeft > 0 &&
        below.length + untriedStations.length > 0) {
      final toDo = below.length + untriedStations.length;
      final perWeek = (toDo / max(1, daysLeft / 7)).ceil();
      advice.add(
        StudyAdvice(
          AdviceKind.goal,
          "Practise about $perWeek ${perWeek == 1 ? 'station' : 'stations'} a week",
          "$toDo stations are below $targetScore% or untried, and your exam "
              "is in $daysLeft days.",
        ),
      );
    }
    if (advice.isEmpty) {
      advice.add(
        StudyAdvice(
          AdviceKind.praise,
          stations.isEmpty ? "Start your first OSCE" : "All stations on target",
          stations.isEmpty
              ? "Your scores and weak areas will appear here."
              : "Every station you tried is at or above $targetScore%.",
        ),
      );
    }

    return OsceProgressStats(
      stationsTotal: stationsTotal,
      stations: stations,
      untriedStations: untriedStations,
      allAttempts: allAttempts,
      targetScore: targetScore,
      weakAreas: weakAreas,
      missedChecks: missedChecks,
      advice: advice,
    );
  }

  static String _short(String text) {
    final line = text.split('\n').first.trim();
    return line.length > 50 ? '${line.substring(0, 47)}…' : line;
  }
}
