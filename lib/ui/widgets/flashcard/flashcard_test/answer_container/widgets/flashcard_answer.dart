import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/flashcard/card_content.dart';
import 'package:flashcards/ui/widgets/notebook/highlightable_text.dart';
import 'package:flutter/material.dart';

class FlashcardAnswer extends StatelessWidget {
  final String answer;
  final Widget? answerImagePreview;

  /// The card this answer belongs to, so text can be highlighted.
  final HighlightTarget? highlightTarget;

  const FlashcardAnswer({
    super.key,
    required this.answer,
    this.answerImagePreview,
    this.highlightTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          // Selectable so the answer can be copied and highlighted.
          CardContent(
            answer,
            target: highlightTarget,
            style: TextTheme.of(context).bodyLarge?.merge(
              TextStyle(color: context.colors.onSecondaryContainer),
            ),
          ),
          SizedBox(height: 15),
          answerImagePreview ?? SizedBox.shrink(),
        ],
      ),
    );
  }
}
