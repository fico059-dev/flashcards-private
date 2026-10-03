import 'package:flashcards/bloc/progress/progress_cubit.dart';
import 'package:flashcards/data/repositories/progress/progress_repository.dart';
import 'package:flashcards/domain/models/progress/card_progress.dart';
import 'package:flashcards/domain/models/progress/osce_progress.dart';
import 'package:flashcards/domain/models/progress/study_log.dart';
import 'package:flashcards/ui/pages/main_tab_pages/learning_progress/learning_progress_page.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/material.dart' hide Card, State;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fsrs/fsrs.dart';

final now = DateTime(2026, 10, 3, 12);

Card _card({
  State state = State.review,
  double stability = 5,
  double difficulty = 5,
  int reps = 3,
  int lapses = 0,
  int dueInDays = 3,
}) {
  final card = Card()
    ..state = state
    ..stability = stability
    ..difficulty = difficulty
    ..reps = reps
    ..lapses = lapses
    ..lastReview = now.subtract(const Duration(days: 2))
    ..due = now.add(Duration(days: dueInDays));
  return card;
}

CardProgressItem _item(
  String id,
  String packId,
  Card card, {
  List<String> tags = const [],
}) => CardProgressItem(
  flashcardId: id,
  packId: packId,
  question: 'Question $id',
  tags: tags,
  card: card,
);

/// Ten days of studying 10 new cards a day.
StudyLog _log({StudyGoal goal = const StudyGoal()}) {
  var log = StudyLog(goal: goal);
  for (var day = 9; day >= 0; day--) {
    final date = now.subtract(Duration(days: day));
    for (var i = 0; i < 12; i++) {
      log = log.recordReview(now: date, isNew: i < 10, forgot: i == 11);
    }
    log = log.recordStudiedCount(date, ((10 - day) * 4.7).round());
  }
  return log;
}

List<CardProgressItem> _items() => [
  for (var i = 0; i < 40; i++)
    _item('c$i', 'cardio', _card(stability: i < 10 ? 30 : 5), tags: ['heart']),
  // A topic the student keeps forgetting.
  for (var i = 0; i < 6; i++)
    _item(
      'r$i',
      'renal',
      _card(difficulty: 9, reps: 6, lapses: 3, dueInDays: -1),
      tags: ['acid__base'],
    ),
  _item('l1', 'renal', _card(state: State.learning, dueInDays: 0)),
  _item('n1', 'renal', _card(state: State.newState, reps: 0)),
  _item('gone', 'deleted_pack', _card()),
];

const _packs = [
  PackInfo(id: 'cardio', name: 'Cardiology', totalCards: 100),
  PackInfo(id: 'renal', name: 'Renal', totalCards: 50),
  PackInfo(id: 'neuro', name: 'Neurology', totalCards: 80),
];

void main() {
  group('StudyLog', () {
    test('records reviews per day and survives a save', () {
      final log = _log(
        goal: StudyGoal(examDate: DateTime(2026, 12, 1), targetCards: 200),
      );
      final restored = StudyLog.decode(log.encode());
      final today = restored.activityOn(now);
      expect(today.reviews, 12);
      expect(today.newCards, 10);
      expect(today.forgotten, 1);
      expect(restored.goal.targetCards, 200);
      expect(restored.goal.examDate, DateTime(2026, 12, 1));
      expect(restored.studiedSnapshots[dayKey(now)], 47);
    });

    test('a damaged log starts over instead of crashing', () {
      expect(StudyLog.decode('{not json').days, isEmpty);
    });

    test('records OSCE sections and missed checks', () {
      var log = const StudyLog();
      for (var i = 0; i < 2; i++) {
        log = log.recordOsce(
          osceId: 'o1',
          name: 'Chest pain',
          results: const [
            OsceQuestionResult(
              text: 'History',
              achieved: 3,
              max: 10,
              missedChecks: ['Ask about radiation'],
            ),
          ],
        );
      }
      final station = StudyLog.decode(log.encode()).osce['o1']!;
      expect(station.questions['History']!.attempts, 2);
      expect(station.questions['History']!.percent, 0.3);
      expect(station.missedChecks['Ask about radiation'], 2);
    });
  });

  group('CardProgressStats', () {
    test('counts stages, due cards and ignores deleted packs', () {
      final stats = CardProgressStats.calculate(
        items: _items(),
        packs: _packs,
        log: _log(),
        now: now,
      );
      expect(stats.totalAvailable, 230);
      expect(stats.studied, 47);
      expect(stats.mastered, 10);
      expect(stats.learning, 1);
      expect(stats.young, 36);
      expect(stats.dueNow, 7);
      expect(stats.unseen, 183);
      expect(stats.forecast.first, 7);
      expect(stats.forecast[3], 40);
      expect(stats.streak, 10);
      expect(stats.reviewsThisWeek, 84);
      expect(stats.retention, isNotNull);
    });

    test('finds weak topics, hardest cards and gaps', () {
      final stats = CardProgressStats.calculate(
        items: _items(),
        packs: _packs,
        log: _log(),
        now: now,
      );
      expect(stats.weakTopics.map((t) => t.name), ['Acid Base']);
      expect(stats.hardestCards.first.flashcardId, startsWith('r'));
      final titles = stats.advice.map((a) => a.title).toList();
      expect(titles.first, 'Review 7 due cards first');
      expect(titles, contains('Strengthen your weak topics: Acid Base'));
      expect(titles, contains("You haven't started Neurology"));
      expect(titles, contains('Set your exam date and target'));
    });

    test('trajectory: on track when the pace is enough', () {
      final stats = CardProgressStats.calculate(
        items: _items(),
        packs: _packs,
        log: _log(
          goal: StudyGoal(examDate: DateTime(2026, 11, 2), targetCards: 200),
        ),
        now: now,
      );
      final t = stats.trajectory;
      expect(t.daysLeft, 30);
      expect(t.pace, 10);
      expect(t.remaining, 153);
      expect(t.requiredPerDay, 6);
      expect(t.status, TrajectoryStatus.onTrack);
      expect(t.history.last.value, 47);
    });

    test('trajectory: behind when the exam is close', () {
      final stats = CardProgressStats.calculate(
        items: _items(),
        packs: _packs,
        log: _log(
          goal: StudyGoal(examDate: DateTime(2026, 10, 13), targetCards: 230),
        ),
        now: now,
      );
      final t = stats.trajectory;
      expect(t.status, TrajectoryStatus.behind);
      expect(t.requiredPerDay, 19);
      expect(t.projectedAtExam, 147);
      expect(
        stats.advice.map((a) => a.title),
        contains('Study 19 new cards a day to reach your goal'),
      );
    });
  });

  group('OsceProgressStats', () {
    OsceProgressStats calculate() => OsceProgressStats.calculate(
      allStations: const {
        'o1': 'Chest pain',
        'o2': 'Abdominal exam',
        'o3': 'Breaking bad news',
      },
      attemptsByStation: {
        'o1': [
          OsceAttemptPoint(now.subtract(const Duration(days: 20)), 40),
          OsceAttemptPoint(now.subtract(const Duration(days: 2)), 65),
        ],
        'o2': [OsceAttemptPoint(now.subtract(const Duration(days: 1)), 90)],
      },
      log: const StudyLog(goal: StudyGoal(targetOsceScore: 80)).recordOsce(
        osceId: 'o1',
        name: 'Chest pain',
        results: const [
          OsceQuestionResult(
            text: 'Examination',
            achieved: 2,
            max: 8,
            missedChecks: ['Check JVP'],
          ),
          OsceQuestionResult(
            text: 'History',
            achieved: 9,
            max: 10,
            missedChecks: [],
          ),
        ],
      ),
      now: now,
    );

    test('scores, trend, weakest station and untried stations', () {
      final stats = calculate();
      expect(stats.attemptsCount, 3);
      expect(stats.stationsAtTarget, 1);
      expect(stats.averageLatest, 77.5);
      expect(stats.weakestFirst.first.name, 'Chest pain');
      expect(stats.weakestFirst.first.improvement, 25);
      expect(stats.untriedStations, ['Breaking bad news']);
      expect(stats.weakAreas.single.text, 'Examination');
      expect(stats.missedChecks.single.text, 'Check JVP');
      expect(stats.advice.first.title, 'Retry Chest pain');
    });
  });

  testWidgets('Progress page shows both tabs without layout errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repo = FakeProgressRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => ProgressCubit(progressRepo: repo)..load(),
          child: const LearningProgressView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Goal & trajectory'), findsOneWidget);
    expect(find.text('On track'), findsOneWidget);
    expect(find.text('Review 7 due cards first'), findsOneWidget);

    // Scroll through the whole Cards tab.
    for (final title in [
      'Card status',
      'Daily activity',
      'Upcoming reviews',
      'Gaps and weak topics',
      'Hardest cards',
      'Packs',
    ]) {
      await tester.scrollUntilVisible(
        find.text(title),
        300,
        scrollable: find.byType(Scrollable).first,
      );
    }

    await tester.tap(find.text('OSCE'));
    await tester.pumpAndSettle();
    expect(find.text('OSCE target'), findsOneWidget);
    expect(find.text('1 of 3 stations at 80% or more'), findsOneWidget);
    for (final title in ['Score trend', 'Stations', 'Gaps in your OSCE']) {
      await tester.scrollUntilVisible(
        find.text(title),
        300,
        scrollable: find.byType(Scrollable).last,
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Setting a goal updates the trajectory', (tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repo = FakeProgressRepository(goal: const StudyGoal());
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => ProgressCubit(progressRepo: repo)..load(),
          child: const LearningProgressView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No goal yet'), findsOneWidget);

    await tester.tap(find.text('Set goal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '150');
    await tester.tap(find.text('Save goal'));
    await tester.pumpAndSettle();

    expect(repo.goal.targetCards, 150);
    expect(find.text('No goal yet'), findsNothing);
    expect(find.textContaining('47 of 150 cards studied'), findsOneWidget);
  });
}

class FakeProgressRepository implements ProgressRepository {
  StudyGoal goal;

  FakeProgressRepository({
    this.goal = const StudyGoal(targetCards: 200, targetOsceScore: 80),
  });

  StudyLog get _currentLog {
    final log = _log(goal: goal);
    return log.recordOsce(
      osceId: 'o1',
      name: 'Chest pain',
      results: const [
        OsceQuestionResult(
          text: 'Examination of the cardiovascular system',
          achieved: 2,
          max: 8,
          missedChecks: ['Check JVP', 'Auscultate the carotids'],
        ),
      ],
    );
  }

  @override
  Future<StudyLog> getLog() async => _currentLog;

  @override
  Future<StudyLog> saveGoal(StudyGoal goal) async {
    this.goal = goal;
    return _currentLog;
  }

  @override
  Future<Result<CardProgressStats>> getCardStats({
    bool refresh = false,
  }) async => Result.ok(
    CardProgressStats.calculate(
      items: _items(),
      packs: _packs,
      log: _currentLog,
      now: DateTime.now(),
    ),
  );

  @override
  Future<Result<OsceProgressStats>> getOsceStats({bool refresh = false}) async {
    final today = DateTime.now();
    return Result.ok(
      OsceProgressStats.calculate(
        allStations: const {
          'o1': 'Chest pain',
          'o2': 'Abdominal exam',
          'o3': 'Breaking bad news',
        },
        attemptsByStation: {
          'o1': [
            for (var i = 0; i < 5; i++)
              OsceAttemptPoint(
                today.subtract(Duration(days: 30 - i * 5)),
                40.0 + i * 6,
              ),
          ],
          'o2': [OsceAttemptPoint(today, 92)],
        },
        log: _currentLog,
        now: today,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
