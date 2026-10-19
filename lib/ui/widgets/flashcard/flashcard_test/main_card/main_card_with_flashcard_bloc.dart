import 'package:flashcards/bloc/flashcards/flashcard/flashcard_bloc.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_event.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_state.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/main_card/widgets/main_card_container.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/main_card/widgets/question_text.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/main_card/widgets/refresh_button.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/main_card/widgets/test_finished_text.dart';
import 'package:flashcards/ui/widgets/notebook/highlightable_text.dart';
import 'package:flashcards/domain/models/flashcards/highlight/highlight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainCardWithFlashcardBloc extends StatelessWidget {
  final VoidCallback onStart;

  const MainCardWithFlashcardBloc({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return MainCardContainer(
      child: BlocBuilder<FlashcardBloc, FlashcardState>(
        builder: (context, state) {
          if (state.flashcard == null && state.status.isError) {
            return RefreshButton(onRefresh: onStart);
          }

          if (state.status.isPackFinished) {
            return TestFinishedText();
          }

          if (state.flashcard == null) {
            return SizedBox.shrink();
          }

          return QuestionText(
            question: state.flashcard!.question,
            tags: state.flashcard!.tags,
            highlightTarget: HighlightTarget.of(
              state.flashcard!,
              HighlightSide.question,
            ),
          );
        },
      ),
    );
  }
}

class _HintButton extends StatelessWidget {
  const _HintButton({super.key});

  @override
  Widget build(BuildContext context) {
    void toggleHint() {
      context.read<FlashcardBloc>().add(FlashcardHintToggled());
    }

    return BlocBuilder<FlashcardBloc, FlashcardState>(
      builder: (context, state) {
        if (state.status.isLoading ||
            state.flashcard == null ||
            state.answerVisible) {
          return SizedBox.shrink();
        }

        return Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(7),
          child: IconButton(
            onPressed: toggleHint,
            icon: Icon(Icons.lightbulb_outline, size: 35, color: Colors.white),
          ),
        );
      },
    );
  }
}
