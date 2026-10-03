import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_bloc.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_event.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/flashcard_top_row/widgets/batch_counter.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/flashcard_top_row/widgets/bookmark_button.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/flashcard_top_row/widgets/popup_menu_button.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/flashcard_top_row/widgets/question_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopRowWithFlashcardBloc extends StatelessWidget {
  const TopRowWithFlashcardBloc({super.key});

  @override
  Widget build(BuildContext context) {
    void onIgnore() {
      context.read<FlashcardBloc>().add(FlashcardIgnored());
    }

    void onReport({
      required Flashcard flashcard,
      required String packId,
      required String packName,
    }) {
      context.router.push(
        ReportFlashcardRoute(
          packId: packId,
          flashcard: flashcard,
          packName: packName,
        ),
      );
    }

    void onToggleBookmark() {
      context.read<FlashcardBloc>().add(FlashcardBookmarkToggled());
    }

    return BlocBuilder<FlashcardBloc, FlashcardState>(
      builder: (context, state) {
        int allFlashcards = state.statRecords.length;
        int currFlashcard = state.currentCardIndex + 1;
        final isBookmarked = state.flashcard == null
            ? false
            : state.statRecords[state.currentCardIndex].hasBookmark;
        var enabled = false;
        if (state.flashcard != null && state.pack != null) {
          enabled = true;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (state.currentBatch > 0)
              BatchCounter(
                currentBatch: state.currentBatch,
                currentFlashcard: currFlashcard,
                allFlashcards: allFlashcards,
              )
            else
              QuestionCounter(
                currentFlashcard: currFlashcard,
                allFlashcards: allFlashcards,
              ),

            Row(
              children: [
                BookmarkButton(
                  isBookmarked: isBookmarked,
                  onToggleBookmark: onToggleBookmark,
                ),

                PopupMenuButtonTopRow(
                  onIgnore: onIgnore,
                  onReport: () => onReport(
                    packName: state.pack!.name,
                    flashcard: state.flashcard!,
                    packId: state.pack!.id,
                  ),
                  enabled: enabled,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
