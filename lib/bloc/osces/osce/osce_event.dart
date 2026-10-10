import 'package:equatable/equatable.dart';
import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';

sealed class OsceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class OsceRequested extends OsceEvent {
  final SimpleOsce simpleOsce;

  OsceRequested({required this.simpleOsce});

  @override
  List<Object?> get props => [simpleOsce];
}

class OsceTestStarted extends OsceEvent {}

class ToggleCheck extends OsceEvent {
  final int checkIndex;

  /// The question the check belongs to, the current question if null.
  final int? questionIndex;

  ToggleCheck({required this.checkIndex, this.questionIndex});

  @override
  List<Object?> get props => [checkIndex, questionIndex];
}

/// The questions are done (or time ran out): show every checklist.
class OsceChecklistOpened extends OsceEvent {}

/// Go back from the checklist to the questions.
class OsceChecklistClosed extends OsceEvent {}

class NextQuestionRequested extends OsceEvent {}

class OsceCurrentQuestionRevealed extends OsceEvent {}

class PreviousQuestionRequested extends OsceEvent {}

class OsceTutorialSeenChecked extends OsceEvent {}

class OsceTutorialFinished extends OsceEvent {}
