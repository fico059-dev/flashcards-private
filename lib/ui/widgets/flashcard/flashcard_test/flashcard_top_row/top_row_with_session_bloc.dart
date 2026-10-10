import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/session_test/session_test_bloc.dart';
import 'package:flashcards/bloc/flashcards/session_test/session_test_event.dart';
import 'package:flashcards/bloc/flashcards/session_test/session_test_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/flashcard_top_row/widgets/admin_edit_card_button.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/flashcard_top_row/widgets/bookmark_button.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/flashcard_top_row/widgets/popup_menu_button.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/flashcard_top_row/widgets/question_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopRowWithSessionBloc extends StatelessWidget {
  const TopRowWithSessionBloc({super.key});

  @override
  Widget build(BuildContext context) {
    void onReport({required Flashcard flashcard}) {
      context.router.push(
        ReportFlashcardRoute(flashcard: flashcard, packId: flashcard.packId),
      );
    }

    void onToggleBookmark() {
      context.read<SessionTestBloc>().add(SessionTestBookmarkToggled());
    }

    return BlocSelector<
      SessionTestBloc,
      SessionTestState,
      (int, int, bool?, Flashcard, String)
    >(
      selector: (state) {
        if (state is! SessionTestLoaded) {
          throw Exception("State is not SessionTestLoaded");
        }

        final currentIndex = state.session.currentIndex;
        final allCount = state.session.cardCount;
        final noFlashcard = state.status.isNoFlashcard;

        return (
          (currentIndex + 1).clamp(0, allCount),
          allCount,
          noFlashcard ? null : state.statRecord.hasBookmark,
          state.statRecord.flashcard!,
          state.unformattedQuestion,
        );
      },
      builder: (context, tuple) {
        final currentIndex = tuple.$1;
        final allCount = tuple.$2;
        final hasBookmark = tuple.$3;
        final flashcard = tuple.$4;
        // The card as stored, with any cloze not hidden.
        final storedCard = flashcard.copyWith(question: tuple.$5);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            QuestionCounter(
              currentFlashcard: currentIndex,
              allFlashcards: allCount,
            ),

            Row(
              children: [
                AdminEditCardButton(
                  flashcard: hasBookmark == null ? null : storedCard,
                  onEdited: (card) => context.read<SessionTestBloc>().add(
                    SessionTestCardEdited(card),
                  ),
                ),
                BookmarkButton(
                  isBookmarked: hasBookmark ?? false,
                  onToggleBookmark: hasBookmark != null
                      ? onToggleBookmark
                      : null,
                ),

                PopupMenuButtonTopRow(
                  onReport: hasBookmark != null
                      ? () => onReport(flashcard: flashcard)
                      : null,
                  enabled: true,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
