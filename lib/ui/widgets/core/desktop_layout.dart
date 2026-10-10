import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fsrs/fsrs.dart' as fsrs;

/// From this width the app uses its desktop layout (side menu, wider
/// pages, keyboard hints).
const desktopBreakpoint = 900.0;

bool isWideLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= desktopBreakpoint;

/// Centres [child] at a comfortable reading width on wide screens; on
/// phones it fills the screen as before.
class ReadableWidth extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const ReadableWidth({super.key, this.maxWidth = 820, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= maxWidth) return child;
        return Center(
          child: SizedBox(
            width: min(maxWidth, constraints.maxWidth),
            height: constraints.hasBoundedHeight ? constraints.maxHeight : null,
            child: child,
          ),
        );
      },
    );
  }
}

/// Keyboard shortcuts while reviewing cards, like in Anki: Space or Enter
/// shows the answer, 1-4 rate Again, Hard, Good, Easy. On wide screens a
/// short reminder is shown at the bottom.
class ReviewShortcuts extends StatelessWidget {
  final VoidCallback onShowAnswer;
  final ValueChanged<fsrs.Rating> onRate;
  final Widget child;

  const ReviewShortcuts({
    super.key,
    required this.onShowAnswer,
    required this.onRate,
    required this.child,
  });

  static final _ratingKeys = [
    (LogicalKeyboardKey.digit1, fsrs.Rating.again),
    (LogicalKeyboardKey.numpad1, fsrs.Rating.again),
    (LogicalKeyboardKey.digit2, fsrs.Rating.hard),
    (LogicalKeyboardKey.numpad2, fsrs.Rating.hard),
    (LogicalKeyboardKey.digit3, fsrs.Rating.good),
    (LogicalKeyboardKey.numpad3, fsrs.Rating.good),
    (LogicalKeyboardKey.digit4, fsrs.Rating.easy),
    (LogicalKeyboardKey.numpad4, fsrs.Rating.easy),
  ];

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): onShowAnswer,
        const SingleActivator(LogicalKeyboardKey.enter): onShowAnswer,
        const SingleActivator(LogicalKeyboardKey.numpadEnter): onShowAnswer,
        for (final (key, rating) in _ratingKeys)
          SingleActivator(key): () => onRate(rating),
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            Expanded(child: child),
            if (isWideLayout(context))
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 4),
                child: Text(
                  'Keyboard: Space shows the answer · 1 Again · 2 Hard · '
                  '3 Good · 4 Easy',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
