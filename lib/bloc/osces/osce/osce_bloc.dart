import 'package:flashcards/bloc/osces/osce/osce_event.dart';
import 'package:flashcards/bloc/osces/osce/osce_state.dart';
import 'package:flashcards/data/repositories/osces/osce_repository.dart';
import 'package:flashcards/data/services/local/local_storage_service.dart';
import 'package:flashcards/domain/models/osce/osce.dart';
import 'package:flashcards/domain/models/osce/question/check/check.dart';
import 'package:flashcards/domain/models/osce/question/question.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OsceBloc extends Bloc<OsceEvent, OsceState> {
  final OsceRepository _osceRepo;
  final LocalStorageService _localStorageService;

  OsceBloc({
    required OsceRepository osceRepo,
    required LocalStorageService localStorageService,
  }) : _osceRepo = osceRepo,
       _localStorageService = localStorageService,
       super(OsceInitial()) {
    on<OsceRequested>(_onOsceRequested);
    on<OsceTestStarted>(_onTestStarted);
    on<ToggleCheck>(_onToggleCheck);
    on<NextQuestionRequested>(_onNextQuestionRequested);
    on<PreviousQuestionRequested>(_onPreviousQuestionRequested);
    on<OsceCurrentQuestionRevealed>(_onQuestionRevealed);
    on<OsceChecklistOpened>(_onChecklistOpened);
    on<OsceChecklistClosed>(_onChecklistClosed);
    on<OsceTutorialSeenChecked>(_onTutorialChecked);
    on<OsceTutorialFinished>(_onTutorialFinished);
  }

  void _onTutorialChecked(
    OsceTutorialSeenChecked event,
    Emitter<OsceState> emit,
  ) async {
    final state = this.state;
    if (state is! OsceShowcase || state.tutorialSeen == true) return;

    final isSeen = await _localStorageService.getOsceTutorialSeen();
    if (!isSeen) {
      emit(state.copyWith(tutorialSeen: false));
    }
  }

  void _onTutorialFinished(
    OsceTutorialFinished event,
    Emitter<OsceState> emit,
  ) async {
    final state = this.state;
    if (state is! OsceShowcase || state.tutorialSeen == true) return;

    _localStorageService.setOsceTutorialSeen();
    emit(state.copyWith(tutorialSeen: true));
  }

  void _onQuestionRevealed(
    OsceCurrentQuestionRevealed event,
    Emitter<OsceState> emit,
  ) {
    final state = this.state;
    if (state is! OsceLoaded) return;

    final newMap = Map.of(state.revealedQuestions);
    final currentQuestionId = state.currentQuestion.id!;
    newMap[currentQuestionId] = true;

    emit(state.copyWith(revealedQuestions: newMap));
  }

  void _onChecklistOpened(OsceChecklistOpened event, Emitter<OsceState> emit) {
    final state = this.state;
    if (state is! OsceLoaded) return;
    emit(state.copyWith(reviewingChecklist: true, error: null));
  }

  void _onChecklistClosed(OsceChecklistClosed event, Emitter<OsceState> emit) {
    final state = this.state;
    if (state is! OsceLoaded) return;
    emit(state.copyWith(reviewingChecklist: false, error: null));
  }

  void _onTestStarted(OsceTestStarted event, Emitter<OsceState> emit) {
    final state = this.state;
    if (state is! OsceShowcase) return;

    emit(OsceLoaded(osce: state.osce));
  }

  void _onNextQuestionRequested(
    NextQuestionRequested event,
    Emitter<OsceState> emit,
  ) {
    final state = this.state;
    if (state is! OsceLoaded) return;

    final currentIndex = state.currentQuestionIndex;
    if (currentIndex < state.osce.questions.length - 1) {
      emit(state.copyWith(currentQuestionIndex: currentIndex + 1, error: null));
    }
  }

  void _onPreviousQuestionRequested(
    PreviousQuestionRequested event,
    Emitter<OsceState> emit,
  ) {
    final state = this.state;
    if (state is! OsceLoaded) return;

    final currentIndex = state.currentQuestionIndex;
    if (currentIndex > 0) {
      emit(state.copyWith(currentQuestionIndex: currentIndex - 1, error: null));
    }
  }

  void _onToggleCheck(ToggleCheck event, Emitter<OsceState> emit) {
    final state = this.state;
    if (state is! OsceLoaded) return;

    emit(state.copyWith(status: OsceStatus.checkToggling, error: null));

    final questionIndex = event.questionIndex ?? state.currentQuestionIndex;
    final question = state.osce.questions[questionIndex];
    final updatedChecks = List<Check>.from(question.checks);
    final originalCheck = updatedChecks[event.checkIndex];
    updatedChecks[event.checkIndex] = originalCheck.copyWith(
      isChecked: !originalCheck.isChecked,
    );

    final updatedQuestion = question.copyWith(checks: updatedChecks);
    final updatedQuestions = List<Question>.from(state.osce.questions);
    updatedQuestions[questionIndex] = updatedQuestion;

    final updatedOsce = state.osce.copyWith(questions: updatedQuestions);

    emit(state.copyWith(status: OsceStatus.loaded, osce: updatedOsce));
  }

  void _onOsceRequested(OsceRequested event, Emitter<OsceState> emit) async {
    if (state is! OsceInitial) return;

    emit(OsceLoading());

    final osceResult = await _osceRepo.getOsce(event.simpleOsce);
    switch (osceResult) {
      case Error<Osce>(:final error):
        emit(OsceError(error: error));
        return;
      case Ok<Osce>():
    }
    emit(OsceShowcase(osce: osceResult.value));

    // when everything is loaded and user is ready to start the test,
    // we check to see if he saw the tutorial
    add(OsceTutorialSeenChecked());
  }
}
