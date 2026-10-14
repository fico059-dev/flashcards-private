import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_bloc.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_event.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flashcards/ui/widgets/rewards/study_rewards_widgets.dart';
import 'package:flutter/material.dart';

/// Shown when today's cards are done, or when the student ends studying for
/// the day early ([endedForToday]).
@RoutePage()
class FlashcardSessionSuccessPage extends StatelessWidget {
  final FlashcardBloc fcBloc;

  /// The student stopped before the target. Today's count is kept, so
  /// opening the pack again today continues where they left off.
  final bool endedForToday;

  const FlashcardSessionSuccessPage({
    super.key,
    required this.fcBloc,
    this.endedForToday = false,
  });

  static const _doneWords = [
    "Every card you finished today is a step closer to exam day.",
    "Consistency wins. You showed up and did the work today!",
    "Your future self thanks you. Rest well, you earned it.",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final state = fcBloc.state;
    final done = state.sessionDone + state.currentCardIndex;
    final total = state.sessionDone + state.statRecords.length;

    final String image;
    final String title;
    final String message;
    if (endedForToday) {
      image = 'assets/images/parrot_like.png';
      title = "Done for today";
      message =
          "You studied $done of $total cards today. Your progress is saved: "
          "open the pack again today to continue, or start fresh tomorrow.";
    } else {
      image = 'assets/images/parrot_fire.png';
      title = "Today's target complete!";
      message = _doneWords[Random().nextInt(_doneWords.length)];
    }

    return Scaffold(
      body: ReadableWidth(
        maxWidth: 820,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  image,
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: theme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: theme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SessionSummaryCard.current(context),
                const SizedBox(height: 24),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.router.replaceAll([const HomeRoute()]);
                        },
                        child: const Text("Back to Home"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          context.router.pop();
                          // Ending early goes back to the same card.
                          if (!endedForToday) {
                            fcBloc.add(FlashcardSessionExtended());
                          }
                        },
                        child: Text(
                          endedForToday ? "Keep studying" : "Continue learning",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
