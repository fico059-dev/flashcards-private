import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_event.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flashcards/config/router/router.dart';

@RoutePage()
class PackFinishedPage extends StatelessWidget {
  final TestType testType;

  const PackFinishedPage({super.key, required this.testType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      body: ReadableWidth(
        maxWidth: 820,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ilustracija papagaja za pack finished
                Image.asset(
                  testType == TestType.regular
                      ? 'assets/images/parrot_fire_eyes.png'
                      : 'assets/images/happy_parrot.png',
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
                const SizedBox(height: 12),

                // Glavni naslov
                Text(
                  testType == TestType.regular
                      ? "Pack completed!"
                      : "Test complete!",
                  style: theme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Friendly poruka
                Text(
                  testType == TestType.regular
                      ? "Congrats! You’ve gone through all cards in this pack for now.\n"
                            "Come back later or explore other packs!"
                      : "Great job! You’ve finished all your bookmarked cards for this session.\n"
                            "Time to take a break or review them again later!",
                  style: theme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Dugmad akcija
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () =>
                        context.router.replaceAll([const HomeRoute()]),
                    child: const Text("Back to Home"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
