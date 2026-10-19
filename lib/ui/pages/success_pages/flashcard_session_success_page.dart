import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_bloc.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_event.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flutter/material.dart';

@RoutePage()
class FlashcardSessionSuccessPage extends StatelessWidget {
  final FlashcardBloc fcBloc;

  const FlashcardSessionSuccessPage({super.key, required this.fcBloc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ilustracija papagaja
              Image.asset(
                'assets/images/parrot_weights.png',
                height: MediaQuery.of(context).size.height * 0.3,
              ),
              const SizedBox(height: 32),

              // Glavni naslov
              Text(
                "اكتملت الجلسة!",
                style: theme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Friendly poruka
              Text(
                "أحسنت، راجعت بطاقاتك لليوم.\n"
                "خذ استراحة أو كمّل مذاكرة — القرار لك!",
                style: theme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Dugmad akcija
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context.router.replaceAll([const HomeRoute()]);
                      },
                      child: const Text("العودة للرئيسية"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        context.router.pop();
                        fcBloc.add(FlashcardSessionExtended());
                      },
                      child: const Text("أكمل المذاكرة"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
