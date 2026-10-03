import 'package:flashcards/bloc/flashcards/flashcard/flashcard_bloc.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_state.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_cubit.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StreakListenerWithFcBloc extends StatelessWidget {
  final Widget child;

  const StreakListenerWithFcBloc({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FlashcardBloc, FlashcardState>(
      listenWhen: (previous, current) =>
          current.newStreak != null && current.newStreak != previous.newStreak,
      listener: (context, state) {
        final newStreak = state.newStreak;
        if (newStreak == null) return;
        print("Ha, new streak found, updating profile bloc now");
        context.read<ProfileReaderCubit>().updateProfileState(
          (profile) => profile.copyWith(streak: newStreak),
        );

        final profileState = context.read<ProfileReaderCubit>().state;
        final streakProfile =
            (profileState as ProfileReaderIsLoaded).profile.streak;
        print("New streak from bloc state: $streakProfile");
      },
      child: child,
    );
  }
}
