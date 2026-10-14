import 'package:flashcards/domain/models/osce/osce.dart';
import 'package:flashcards/domain/models/osce/question/question.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'osce_state.freezed.dart';

enum OsceStatus {
  initial,
  checkToggling,
  questionLoading,
  osceSubmitting,
  loaded,
  success,
  error,
}

extension OsceStatusX on OsceStatus {
  bool get isInitial => this == OsceStatus.initial;

  bool get isLoaded => this == OsceStatus.loaded;

  bool get isSuccess => this == OsceStatus.success;

  bool get isError => this == OsceStatus.error;

  bool get isQuestionLoading => this == OsceStatus.questionLoading;

  bool get isCheckToggling => this == OsceStatus.checkToggling;

  bool get isOsceSubmitting => this == OsceStatus.osceSubmitting;
}

extension OsceLoadedX on OsceLoaded {
  Question get currentQuestion {
    final state = this;
    return state.osce.questions[state.currentQuestionIndex];
  }
}

@freezed
sealed class OsceState with _$OsceState {
  const factory OsceState.initial() = OsceInitial;

  const factory OsceState.loading() = OsceLoading;

  const factory OsceState.osceShowcase({
    required Osce osce,

    /// it reads local storage to see if the osce tutorial has been seen or not
    bool? tutorialSeen,
  }) = OsceShowcase;

  const factory OsceState.loaded({
    @Default(OsceStatus.initial) OsceStatus status,
    required Osce osce,
    @Default(0) int currentQuestionIndex,
    @Default({}) Map<String, bool> revealedQuestions,

    /// True once the questions are done and the user is ticking the
    /// checklist of every question to get their score.
    @Default(false) bool reviewingChecklist,
    Exception? error,
  }) = OsceLoaded;

  const factory OsceState.error({required Exception error}) = OsceError;
}
