import 'dart:math';

import 'package:flashcards/bloc/flashcards/flashcard/flashcard_bloc.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_state.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _sessionMilestones = [25, 50, 75];

const _styles = {
  25: (
    'assets/images/parrot_fire_eyes.png',
    "Great start!",
    [
      "A quarter of today's cards done. Keep the rhythm going!",
      "You're warmed up now. The next cards will feel easier.",
    ],
  ),
  50: (
    'assets/images/parrot_chest.png',
    "Halfway through today!",
    [
      "Half of today's cards are in the treasure chest.",
      "Great focus! The second half goes faster.",
    ],
  ),
  75: (
    'assets/images/parrot_weights.png',
    "Almost there!",
    [
      "Only a quarter left for today. Finish strong!",
      "Your memory is getting stronger with every card.",
    ],
  ),
};

/// The session milestone (25, 50 or 75%) reached by going from [before] to
/// [after] cards of [total], if any.
int? sessionMilestoneReached({
  required int before,
  required int after,
  required int total,
}) {
  if (total <= 0) return null;
  for (final m in _sessionMilestones.reversed) {
    if (before * 100 < m * total && after * 100 >= m * total) return m;
  }
  return null;
}

/// Encourages the student at 25, 50 and 75% of today's cards. Reaching 100%
/// shows the "target complete" page.
class SessionMilestoneListener extends StatelessWidget {
  final Widget child;

  const SessionMilestoneListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FlashcardBloc, FlashcardState>(
      // Only a rated card counts, not opening the pack part-way through.
      listenWhen: (previous, current) =>
          previous.currentBatch == 0 &&
          current.currentBatch == 0 &&
          current.currentCardIndex == previous.currentCardIndex + 1,
      listener: (context, state) {
        final total = state.sessionDone + state.statRecords.length;
        final after = state.sessionDone + state.currentCardIndex;
        final reached = sessionMilestoneReached(
          before: after - 1,
          after: after,
          total: total,
        );
        if (reached == null) return;
        showDialog<void>(
          context: context,
          builder: (_) => SessionMilestoneDialog(
            percent: reached,
            done: after,
            total: total,
          ),
        );
      },
      child: child,
    );
  }
}

class SessionMilestoneDialog extends StatelessWidget {
  final int percent;
  final int done;
  final int total;

  const SessionMilestoneDialog({
    super.key,
    required this.percent,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final (image, title, words) = _styles[percent] ?? _styles[25]!;
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(image, height: 150),
          const SizedBox(height: 8),
          Text(
            "$percent% of today's cards",
            style: context.text.labelLarge?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            words[Random().nextInt(words.length)],
            textAlign: TextAlign.center,
            style: context.text.bodyLarge,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : min(1.0, done / total),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Text('$done of $total cards', style: context.text.bodySmall),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep going'),
        ),
      ],
    );
  }
}
