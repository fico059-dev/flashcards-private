import 'package:flashcards/domain/models/flashcards/card_markup/card_markup.dart';
import 'package:flashcards/bloc/flashcards/ignored_card/ignored_card_bloc.dart';
import 'package:flashcards/bloc/flashcards/ignored_card/ignored_card_event.dart';
import 'package:flashcards/domain/models/flashcards/ignored_flashcard/ignored_flashcard.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipeable_tile/swipeable_tile.dart';

class IgnoredFlashcardCard extends StatelessWidget {
  final IgnoredFlashcard card;
  final int index;
  final void Function({required IgnoredFlashcard card, required int index})
  onUndo;

  const IgnoredFlashcardCard({
    super.key,
    required this.card,
    required this.onUndo,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(color: context.colors.onPrimaryContainer);

    void showSuccessSnackBar() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"${card.question}"',
                style: const TextStyle(fontStyle: FontStyle.italic),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Text('unignored'),
            ],
          ),
          action: SnackBarAction(
            label: "Undo",
            onPressed: () => onUndo(card: card, index: index),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }

    return SwipeableTile.card(
      shadow: BoxShadow(color: context.customColors.success),
      borderRadius: 12,
      horizontalPadding: horizontalScreenPadding,
      verticalPadding: 7,
      key: key!,
      color: Colors.transparent,
      swipeThreshold: 0.4,
      direction: SwipeDirection.endToStart,
      onSwiped: (direction) {
        context.read<IgnoredCardBloc>().add(
          IgnoredCardUnignored(ignoredCard: card),
        );
        showSuccessSnackBar();
      },
      backgroundBuilder: (context, direction, progress) {
        return Container(
          alignment: Alignment.center,
          color: context.customColors.success,
          child: ListTile(
            trailing: Icon(
              Icons.visibility,
              color: context.customColors.onSuccess,
            ),
          ),
        );
      },
      child: Material(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          //onTap: () {},
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(plainCardText(card.question), style: textStyle)],
            ),
          ),
        ),
      ),
    );
  }
}
