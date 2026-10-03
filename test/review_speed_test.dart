import 'dart:async';

import 'package:flashcards/bloc/flashcards/session_test/session_test_bloc.dart';
import 'package:flashcards/bloc/flashcards/session_test/session_test_event.dart';
import 'package:flashcards/bloc/flashcards/session_test/session_test_state.dart';
import 'package:flashcards/data/repositories/flashcards/custom_session_repository.dart';
import 'package:flashcards/data/repositories/flashcards/fcp_repository.dart';
import 'package:flashcards/data/repositories/users/profile_repository.dart';
import 'package:flashcards/domain/models/flashcards/custom_session/custom_session.dart';
import 'package:flashcards/domain/models/flashcards/custom_session_summary/custom_session_summary.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/domain/models/flashcards/stat_record/stat_record.dart';
import 'package:flashcards/domain/models/profile/streak/streak.dart';
import 'package:flashcards/utils/background_save.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fsrs/fsrs.dart';

/// Server writes that never finish, like on a dead connection.
class _NeverSavingSessionRepo implements CustomSessionRepository {
  int answered = 0;

  @override
  Future<Result<CustomSession>> getCustomSessionFlashcardIds({
    required CustomSessionSummary sessionSummary,
  }) async => Result.ok(
    CustomSession(
      id: sessionSummary.id,
      flashcardIds: ['a', 'b', 'c', 'd', 'e'],
      currentIndex: sessionSummary.currentIndex,
      cardCount: 5,
      correctCount: 0,
    ),
  );

  @override
  Future<Result<void>> answeredCorrect(String sessionId) {
    answered++;
    return Completer<Result<void>>().future;
  }

  @override
  Future<Result<void>> answeredWrong(String sessionId) {
    answered++;
    return Completer<Result<void>>().future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FcpRepo implements FcpRepository {
  final fetched = <String>[];
  final saved = <String>[];
  final hanging = <String>{};
  final failing = <String>{};

  @override
  Future<Result<StatRecord>> getStatRecordForFlashcardId(String id) async {
    fetched.add(id);
    if (hanging.contains(id)) return Completer<Result<StatRecord>>().future;
    if (failing.remove(id)) return Result.error(Exception('offline'));
    return Result.ok(
      StatRecord(
        packId: 'p',
        flashcardId: id,
        isPaid: false,
        card: Card(),
        flashcard: Flashcard(
          id: id,
          packId: 'p',
          question: 'Question $id',
          answer: 'Answer $id',
          questionImageUrl: 'https://img/$id.jpg',
          tags: const [],
        ),
      ),
    );
  }

  @override
  Future<Result<void>> safeUpdateCard({
    required StatRecord newStatRecord,
    required StatRecord currStatRecord,
  }) {
    saved.add(newStatRecord.flashcardId);
    return Completer<Result<void>>().future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ProfileRepo implements ProfileRepository {
  @override
  Future<Result<Streak?>> checkAndStartStreak(Streak streak) =>
      Completer<Result<Streak?>>().future;

  @override
  Future<Result<Streak?>> checkAndIncrementCardsCount(Streak streak) =>
      Completer<Result<Streak?>>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _streak = Streak(count: 0, lastStreakDate: DateTime(2026, 10, 1));

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late _NeverSavingSessionRepo sessionRepo;
  late _FcpRepo fcpRepo;
  late SessionTestBloc bloc;

  setUp(() {
    sessionRepo = _NeverSavingSessionRepo();
    fcpRepo = _FcpRepo();
    bloc = SessionTestBloc(
      sessionRepo: sessionRepo,
      fcpRepo: fcpRepo,
      profileRepo: _ProfileRepo(),
    );
  });

  Future<void> load() async {
    bloc.add(
      SessionTestDataLoaded(
        sessionSummary: CustomSessionSummary(
          id: 's1',
          createdAt: DateTime(2026, 10, 1),
          isPaid: false,
          cardCount: 5,
          correctCount: 0,
          currentIndex: 0,
        ),
        userStreak: _streak,
      ),
    );
    await _settle();
  }

  SessionTestLoaded loaded() => bloc.state as SessionTestLoaded;

  test('downloads the next cards ahead and their images', () async {
    final images = <String>[];
    bloc.upcomingImages.listen(images.add);
    await load();
    expect(loaded().statRecord.flashcardId, 'a');
    expect(fcpRepo.fetched, ['a', 'b', 'c', 'd']);
    expect(
      images,
      containsAll([
        'https://img/b.jpg',
        'https://img/c.jpg',
        'https://img/d.jpg',
      ]),
    );
    expect(images, isNot(contains('https://img/e.jpg')));
  });

  test('moves on even when the server never confirms the saves', () async {
    await load();
    for (final expected in ['b', 'c', 'd', 'e']) {
      bloc
        ..add(SessionTestAnswerShown())
        ..add(SessionTestNextPressed(rating: Rating.good, userStreak: _streak));
      await _settle();
      expect(loaded().statRecord.flashcardId, expected);
      expect(loaded().status, SessionTestStatus.initial);
    }
    expect(fcpRepo.saved, ['a', 'b', 'c', 'd']);
    expect(sessionRepo.answered, 4);

    bloc
      ..add(SessionTestAnswerShown())
      ..add(SessionTestNextPressed(rating: Rating.again, userStreak: _streak));
    await _settle();
    expect(loaded().status, SessionTestStatus.finished);
    expect(loaded().session.correctCount, 4);
  });

  test('a double tap answers the card once', () async {
    await load();
    bloc
      ..add(SessionTestAnswerShown())
      ..add(SessionTestNextPressed(rating: Rating.good, userStreak: _streak))
      ..add(SessionTestNextPressed(rating: Rating.good, userStreak: _streak));
    await _settle();
    expect(loaded().statRecord.flashcardId, 'b');
    expect(fcpRepo.saved, ['a']);
  });

  test('a slow download shows an error instead of loading forever', () async {
    networkReadTimeout = const Duration(milliseconds: 50);
    addTearDown(() => networkReadTimeout = const Duration(seconds: 20));
    fcpRepo.hanging.add('b');
    await load();

    bloc
      ..add(SessionTestAnswerShown())
      ..add(SessionTestNextPressed(rating: Rating.good, userStreak: _streak));
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(loaded().status, SessionTestStatus.error);
    expect(loaded().statRecord.flashcardId, 'a');
    // Nothing was saved, so trying again doesn't count the card twice.
    expect(fcpRepo.saved, isEmpty);

    fcpRepo.hanging.remove('b');
    bloc.add(SessionTestNextPressed(rating: Rating.good, userStreak: _streak));
    await _settle();
    expect(loaded().statRecord.flashcardId, 'b');
    expect(fcpRepo.saved, ['a']);
  });

  test('BackgroundSaver reports failures and can wait for saves', () async {
    final saver = BackgroundSaver();
    final errors = <Exception>[];
    saver.errors.listen(errors.add);
    final slow = Completer<Result<void>>();
    saver.run('ok', () async => Result.ok(null));
    saver.run('bad', () async => Result.error(Exception('denied')));
    saver.run('slow', () => slow.future);
    await _settle();
    expect(errors.single.toString(), contains('denied'));
    expect(saver.hasPendingSaves, isTrue);

    await saver.settle(const Duration(milliseconds: 20));
    slow.complete(Result.ok(null));
    await saver.settle();
    expect(saver.hasPendingSaves, isFalse);
    saver.dispose();
  });
}
