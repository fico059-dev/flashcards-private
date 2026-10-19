import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/fc_review_getter/fc_review_getter_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flutter/material.dart';

class FcReviewSheetUserFloatingButton extends StatelessWidget {
  final FcReviewGetterLoaded state;

  const FcReviewSheetUserFloatingButton({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    void onPreview() {
      context.router.push(
        FlashcardPreviewRoute(flashcard: state.fcReview.record.flashcard!),
      );
    }

    return FloatingActionButton(
      tooltip: "معاينة البطاقة",
      onPressed: onPreview,
      child: Icon(Icons.remove_red_eye),
    );
  }
}
