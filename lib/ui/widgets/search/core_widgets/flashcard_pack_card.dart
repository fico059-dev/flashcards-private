import 'package:flashcards/domain/models/flashcards/card_markup/card_markup.dart';
import 'package:flashcards/domain/models/algolia/algolia_flashcard/algolia_flashcard.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/subs_status_icon.dart';
import 'package:flutter/material.dart';

class FlashcardPackCard extends StatelessWidget {
  final VoidCallback? onTap;
  final AlgoliaFlashcard flashcard;
  final bool? hasCards;

  const FlashcardPackCard({
    super.key,
    required this.flashcard,
    this.onTap,
    required this.hasCards,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        tileColor: context.colors.secondaryContainer.withValues(alpha: 0.6),
        leading: Icon(
          Icons.question_answer_outlined,
          color: context.colors.onSecondaryContainer,
        ),
        title: Text(
          plainCardText(flashcard.question),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: context.colors.onSecondaryContainer),
        ),
        trailing: SubsStatusIcon(
          isPaid: flashcard.isPaid,
          hasAccess: hasCards,
          size: 20,
        ),
      ),
    );
  }
}
