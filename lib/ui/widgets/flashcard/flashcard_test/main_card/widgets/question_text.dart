import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class QuestionText extends StatelessWidget {
  final String question;
  final List<Tag> tags;

  const QuestionText({super.key, required this.question, this.tags = const []});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        if (tags.isNotEmpty) FlashcardTags(tags: tags),
        // Selectable so the question can be copied.
        SelectableText(
          question,
          style: TextStyle(
            color: context.colors.onPrimaryContainer,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

/// The card's tags, shown above the question.
class FlashcardTags extends StatelessWidget {
  final List<Tag> tags;

  const FlashcardTags({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final tag in tags)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.onPrimaryContainer.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tag.name,
              style: TextTheme.of(
                context,
              ).labelMedium?.copyWith(color: context.colors.onPrimaryContainer),
            ),
          ),
      ],
    );
  }
}
