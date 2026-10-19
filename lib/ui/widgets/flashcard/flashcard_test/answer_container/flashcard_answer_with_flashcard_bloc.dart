import 'package:flashcards/bloc/flashcards/flashcard/flashcard_bloc.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_state.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/answer_container/widgets/flashcard_answer.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/image_containers/answer/answer_container_with_flashcard_bloc.dart';
import 'package:flashcards/ui/widgets/notebook/highlightable_text.dart';
import 'package:flashcards/domain/models/flashcards/highlight/highlight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FlashcardAnswerWithFlashcardBloc extends StatelessWidget {
  const FlashcardAnswerWithFlashcardBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlashcardBloc, FlashcardState>(
      builder: (context, state) {
        if (state.flashcard == null) return SizedBox.shrink();

        if (state.answerVisible) {
          return FlashcardAnswer(
            answer: state.flashcard!.answer,
            answerImagePreview: AnswerContainerWithFlashcardBloc(),
            highlightTarget: HighlightTarget.of(
              state.flashcard!,
              HighlightSide.answer,
            ),
          );
        }

        return SizedBox.shrink();
      },
    );
  }
}
