import 'package:flashcards/bloc/osces/osce/osce_bloc.dart';
import 'package:flashcards/bloc/osces/osce/osce_event.dart';
import 'package:flashcards/bloc/osces/osce/osce_state.dart';
import 'package:flashcards/domain/models/osce/question/question.dart';
import 'package:flashcards/ui/widgets/osce/osce_checklist_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

OsceMode? _modeOf(OsceState state) => switch (state) {
  OsceShowcase(:final mode) => mode,
  OsceLoaded(:final mode) => mode,
  _ => null,
};

/// Learning or Exam, at the top of the OSCE screen.
class OsceModeSwitch extends StatelessWidget {
  /// Explains the two modes under the switch.
  final bool showHint;

  const OsceModeSwitch({super.key, this.showHint = false});

  @override
  Widget build(BuildContext context) {
    final mode = context.select<OsceBloc, OsceMode?>(
      (bloc) => _modeOf(bloc.state),
    );
    if (mode == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<OsceMode>(
          segments: const [
            ButtonSegment(
              value: OsceMode.learning,
              icon: Icon(Icons.school_outlined),
              label: Text('Learning'),
            ),
            ButtonSegment(
              value: OsceMode.exam,
              icon: Icon(Icons.timer_outlined),
              label: Text('Exam'),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (value) =>
              context.read<OsceBloc>().add(OsceModeChanged(value.first)),
        ),
        if (showHint) ...[
          const SizedBox(height: 6),
          Text(
            mode == OsceMode.learning
                ? 'Learning: see the answers after each question, and again '
                      'at the end.'
                : 'Exam: answer every question first, the answers are shown '
                      'at the end.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// In Learning mode, the current question's answers: hidden behind a
/// button until the student has answered, then its checklist to tick.
class OsceLearningAnswer extends StatelessWidget {
  const OsceLearningAnswer({super.key});

  @override
  Widget build(BuildContext context) {
    final view = context.select<OsceBloc, (OsceMode, int, bool)?>((bloc) {
      final state = bloc.state;
      if (state is! OsceLoaded) return null;
      return (
        state.mode,
        state.currentQuestionIndex,
        state.revealedQuestions[state.currentQuestion.id] == true,
      );
    });
    if (view == null || view.$1 != OsceMode.learning) {
      return const SizedBox.shrink();
    }
    final (_, index, revealed) = view;
    if (!revealed) {
      return Center(
        child: OutlinedButton.icon(
          onPressed: () =>
              context.read<OsceBloc>().add(OsceCurrentQuestionRevealed()),
          icon: const Icon(Icons.visibility_outlined),
          label: const Text('Show answer'),
        ),
      );
    }
    final question = context.select<OsceBloc, Question>(
      (bloc) => (bloc.state as OsceLoaded).osce.questions[index],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Answer: tick what you covered',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        OsceQuestionChecklist(
          questionIndex: index,
          question: question,
          showNumber: false,
        ),
      ],
    );
  }
}
