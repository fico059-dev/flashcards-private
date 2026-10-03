import 'package:flashcards/bloc/flashcards/session_test/session_test_event.dart';
import 'package:flashcards/bloc/flashcards/session_test/session_test_state.dart';
import 'package:flashcards/data/repositories/flashcards/custom_session_repository.dart';
import 'package:flashcards/data/repositories/flashcards/fcp_repository.dart';
import 'package:flashcards/data/repositories/users/profile_repository.dart';
import 'package:flashcards/data/services/api/exceptions/document_doesnt_exist_exception.dart';
import 'package:flashcards/domain/models/flashcards/custom_session/custom_session.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/domain/models/flashcards/stat_record/stat_record.dart';
import 'package:flashcards/domain/models/profile/streak/streak.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsrs/fsrs.dart';

class SessionTestBloc extends Bloc<SessionTestEvent, SessionTestState> {
  final CustomSessionRepository _sessionRepo;
  final FcpRepository _fcpRepo;
  final ProfileRepository _profileRepo;

  SessionTestBloc({
    required CustomSessionRepository sessionRepo,
    required FcpRepository fcpRepo,
    required ProfileRepository profileRepo,
  }) : _sessionRepo = sessionRepo,
       _fcpRepo = fcpRepo,
       _profileRepo = profileRepo,
       super(SessionTestInitial()) {
    on<SessionTestDataLoaded>(_onLoaded);
    on<SessionTestNextPressed>(_onNextPressed);
    on<SessionTestBookmarkToggled>(_onBookmarkToggled);
    on<SessionTestAnswerShown>(_onAnswerShown);
  }

  void _onAnswerShown(
    SessionTestAnswerShown event,
    Emitter<SessionTestState> emit,
  ) {
    final state = this.state;
    if (state is! SessionTestLoaded) return;
    if (state.status.isLoading) return;

    // format cloze question, if cloze is present
    final updatedFlashcard = state.statRecord.flashcard!.copyWith(
      question: revealClozeQuestion(state.unformattedQuestion),
    );
    //print(updatedFlashcard.question);
    emit(
      state.copyWith(
        answerShown: true,
        statRecord: state.statRecord.copyWith(flashcard: updatedFlashcard),
      ),
    );
  }

  void _onLoaded(
    SessionTestDataLoaded event,
    Emitter<SessionTestState> emit,
  ) async {
    if (state is! SessionTestInitial && state is! SessionTestError) return;

    emit(SessionTestLoading());

    final sessionResult = await _sessionRepo.getCustomSessionFlashcardIds(
      sessionSummary: event.sessionSummary,
    );
    switch (sessionResult) {
      case Error<CustomSession>(:final error):
        emit(SessionTestError(error));
        return;
      case Ok<CustomSession>():
    }
    final customSession = sessionResult.value;
    if (customSession.isFinished) {
      emit(
        SessionTestLoaded(
          unformattedQuestion: "",
          status: SessionTestStatus.finished,
          session: customSession,
          statRecord: StatRecord.empty(),
        ),
      );
      return;
    }

    final recordResult = await _fcpRepo.getStatRecordForFlashcardId(
      customSession.currentFlashcardId,
    );
    switch (recordResult) {
      case Error<StatRecord>(:final error):
        if (error is DocumentDoesntExistException) {
          emit(
            SessionTestLoaded(
              unformattedQuestion: "",
              status: SessionTestStatus.noFlashcard,
              session: customSession,
              statRecord: StatRecord.empty(),
            ),
          );
          return;
        }
        emit(SessionTestError(error));
        return;
      case Ok<StatRecord>():
    }
    final statRecord = recordResult.value;
    final unformattedQuestion = statRecord.flashcard!.question;
    final recordWithCloze = statRecord.copyWith(
      flashcard: statRecord.flashcard!.copyWith(
        question: redactClozeQuestion(unformattedQuestion),
      ),
    );

    // print(customSession.correctCount);
    emit(
      SessionTestLoaded(
        session: customSession,
        statRecord: recordWithCloze,
        unformattedQuestion: unformattedQuestion,
      ),
    );

    final current = state;
    if (current is! SessionTestLoaded) return;

    // start counting
    final streakResult = await _profileRepo.checkAndStartStreak(
      event.userStreak,
    );
    switch (streakResult) {
      case Error<Streak?>(:final error):
        print(error);
      case Ok<Streak?>(:final value):
        if (value == null) break;
        emit(current.copyWith(newStreak: value));
    }
  }

  void _onNextPressed(
    SessionTestNextPressed event,
    Emitter<SessionTestState> emit,
  ) async {
    var state = this.state;
    if (state is! SessionTestLoaded ||
        state.status.isLoading ||
        state.status.isBookmarkLoading) {
      return;
    }

    emit(state.copyWith(status: SessionTestStatus.loading, error: null));

    // count streak, if it needs to
    final streakResult = await _profileRepo.checkAndIncrementCardsCount(
      event.userStreak,
    );
    switch (streakResult) {
      case Error<Streak?>(:final error):
        print(error);
      case Ok<Streak?>(:final value):
        if (value == null) break;
        emit(
          state.copyWith(
            status: SessionTestStatus.loading,
            newStreak: value,
            error: null,
          ),
        );
    }

    state = (this.state as SessionTestLoaded);

    // Save the rating to the card's progress, so custom sessions count
    // towards spaced repetition like regular study.
    final rating = event.rating;
    if (rating != null && !state.status.isNoFlashcard) {
      final currRecord = state.statRecord.copyWith(
        // The question in state is formatted for display (cloze revealed),
        // the progress record must keep the original.
        flashcard: state.statRecord.flashcard?.copyWith(
          question: state.unformattedQuestion,
        ),
      );
      final newCard = FSRS()
          .repeat(currRecord.card, DateTime.now())[rating]!
          .card;
      final progressResult = await _fcpRepo.safeUpdateCard(
        newStatRecord: currRecord.copyWith(card: newCard),
        currStatRecord: currRecord,
      );
      switch (progressResult) {
        case Error<void>(:final error):
          emit(state.copyWith(status: SessionTestStatus.error, error: error));
          return;
        case Ok<void>():
      }
    }

    late final CustomSession newSession;
    if (event.isCorrect) {
      newSession = state.session.incrementCurrentIndexAndCorrectCount();
    } else {
      newSession = state.session.incrementCurrentIndex();
    }

    final newId = state.session.peekNextFlashcardId;
    StatRecord? statRecord;
    String? unformattedQuestion;
    if (newId != null) {
      final recordResult = await _fcpRepo.getStatRecordForFlashcardId(newId);
      switch (recordResult) {
        case Error<StatRecord>(:final error):
          if (error is DocumentDoesntExistException) {
            await _answerCorrectlyAndEmit(emit);
            return;
          }
          emit(state.copyWith(status: SessionTestStatus.error, error: error));
          return;
        case Ok<StatRecord>():
      }
      statRecord = recordResult.value;
      unformattedQuestion = statRecord.flashcard!.question;
      statRecord = statRecord.copyWith(
        flashcard: statRecord.flashcard!.copyWith(
          question: redactClozeQuestion(unformattedQuestion),
        ),
      );
    }

    late final Result<void> incrementResult;
    if (event.isCorrect) {
      incrementResult = await _sessionRepo.answeredCorrect(state.session.id);
    } else {
      incrementResult = await _sessionRepo.answeredWrong(state.session.id);
    }
    switch (incrementResult) {
      case Error<void>(:final error):
        emit(state.copyWith(status: SessionTestStatus.error, error: error));
        return;
      case Ok<void>():
    }

    //print(newSession.correctCount);
    if (newSession.isFinished) {
      emit(
        state.copyWith(status: SessionTestStatus.finished, session: newSession),
      );
      return;
    }

    emit(
      state.copyWith(
        unformattedQuestion: unformattedQuestion!,
        status: SessionTestStatus.initial,
        statRecord: statRecord!,
        session: newSession,
        answerShown: false,
        error: null,
      ),
    );
  }

  void _onBookmarkToggled(
    SessionTestBookmarkToggled event,
    Emitter<SessionTestState> emit,
  ) async {
    final state = this.state;
    if (state is! SessionTestLoaded ||
        state.status.isLoading ||
        state.status.isBookmarkLoading) {
      return;
    }

    // this is local copy of the currRecord, after emitting
    // new states this will always stay the same
    final currRecord = state.statRecord;
    emit(
      state.copyWith(
        status: SessionTestStatus.bookmarkLoading,
        statRecord: state.statRecord.copyWith(
          hasBookmark: !state.statRecord.hasBookmark,
        ),
        error: null,
      ),
    );

    late final Result<void> bookmarkResult;
    //await Future.delayed(Duration(milliseconds: 1500));
    if (!currRecord.hasBookmark) {
      bookmarkResult = await _fcpRepo.safeAddBookmark(record: currRecord);
    } else {
      bookmarkResult = await _fcpRepo.removeBookmark(
        flashcardId: currRecord.flashcardId,
        record: currRecord,
      );
    }

    switch (bookmarkResult) {
      case Error<void>(:final error):
        // revert previous state and emit error
        print("Error while toggling bookmark");
        print(error);
        // when we write this.state it's referring to the global state, not local one
        // so here we just return back the old local stat record
        emit(
          (this.state as SessionTestLoaded).copyWith(
            status: SessionTestStatus.error,
            statRecord: currRecord,
            error: error,
          ),
        );
        return;
      case Ok<void>():
    }

    emit(
      (this.state as SessionTestLoaded).copyWith(
        status: SessionTestStatus.initial,
      ),
    );
  }

  Future<void> _answerCorrectlyAndEmit(Emitter<SessionTestState> emit) async {
    final state = this.state;
    if (state is! SessionTestLoaded) return;

    final incrementResult = await _sessionRepo.answeredCorrect(
      state.session.id,
    );
    switch (incrementResult) {
      case Error<void>(:final error):
        emit(state.copyWith(status: SessionTestStatus.error, error: error));
        return;
      case Ok<void>():
    }
    final newSession = state.session.incrementCurrentIndexAndCorrectCount();
    if (newSession.isFinished) {
      emit(
        state.copyWith(status: SessionTestStatus.finished, session: newSession),
      );
      return;
    }

    emit(
      state.copyWith(
        unformattedQuestion: '',
        status: SessionTestStatus.noFlashcard,
        statRecord: StatRecord.empty(),
        session: newSession,
        answerShown: false,
        error: null,
      ),
    );
  }
}
