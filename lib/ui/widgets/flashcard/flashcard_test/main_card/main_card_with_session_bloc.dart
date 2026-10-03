import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_bloc.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_state.dart';
import 'package:flashcards/bloc/flashcards/session_test/session_test_bloc.dart';
import 'package:flashcards/bloc/flashcards/session_test/session_test_state.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/main_card/widgets/main_card_container.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/main_card/widgets/question_text.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/main_card/widgets/test_finished_text.dart';
import 'package:flashcards/ui/widgets/notebook/highlightable_text.dart';
import 'package:flashcards/domain/models/flashcards/highlight/highlight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainCardWithSessionBloc extends StatelessWidget {
  const MainCardWithSessionBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return MainCardContainer(
      child: BlocSelector<SessionTestBloc, SessionTestState, Flashcard?>(
        selector: (state) {
          if (state is! SessionTestLoaded) {
            throw Exception("State is not SessionTestLoaded");
          }
          if (state.status.isFinished) {
            return null;
          } else {
            return state.statRecord.flashcard;
          }
        },
        builder: (context, flashcard) {
          if (flashcard == null) {
            return TestFinishedText();
          }

          return QuestionText(
            question: flashcard.question,
            tags: flashcard.tags,
            highlightTarget: HighlightTarget.of(
              flashcard,
              HighlightSide.question,
            ),
          );
        },
      ),
    );
  }
}
