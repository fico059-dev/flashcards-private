import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_bloc.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_event.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_state.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_cubit.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/flashcard_page_dialogs.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FlashcardPagePopScope extends StatelessWidget {
  final Widget child;

  const FlashcardPagePopScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FlashcardBloc, FlashcardState>(
      listenWhen: (previous, current) =>
          current.status.isProfileUpdated && current.status != previous.status,
      listener: (context, state) {
        if (!state.status.isProfileUpdated) return;

        context.read<ProfileReaderCubit>().readProfile();
        context.router.replace(ProfileRoute());
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          final flashcardBloc = context.read<FlashcardBloc>();
          final flashcardState = flashcardBloc.state;
          final profileState = context.read<ProfileReaderCubit>().state;

          if (profileState is! ProfileReaderIsLoaded) {
            throw Exception(
              "Profile is not loaded inside flashcardPagePopScope",
            );
          }
          if (flashcardState.cardsPerSession == null) {
            throw Exception(
              "Cards per session in flashcardState is null inside flashcardPagePopScope",
            );
          }

          final userCardsPerSession =
              profileState.profile.profileSettings.cardsPerSession;
          final cardDifference = calculateCardsPerSessionDifference(
            currentBatch: flashcardState.currentBatch,
            currentFlashcardIndex: flashcardState.currentCardIndex,
            currentCardsPerSession: flashcardState.cardsPerSession!,
          );
          final newTargetCardsPerSession = userCardsPerSession + cardDifference;

          print("[card diff] $cardDifference");
          // Pop the route if session is not extended
          if (cardDifference <= 0) {
            context.router.pop();
            return;
          }

          // if session is extended, show the dialog
          final shouldUpdateTarget = await showUpdateCardsPerSessionDialog(
            context: context,
            cardDifference: cardDifference,
            userCardsPerSession:
                profileState.profile.profileSettings.cardsPerSession,
          );

          // barrier is dismissed, don't do anything
          if (shouldUpdateTarget == null) {
            return;
          }

          // If user don't want to update target, just pop the page
          if (shouldUpdateTarget == false) {
            if (context.mounted) {
              context.router.pop();
            }
            return;
          }
          // call bloc to update target
          flashcardBloc.add(
            FlashcardCardsPerSessionUpdated(
              cardPerSession: newTargetCardsPerSession,
            ),
          );
          return;
        },
        child: child,
      ),
    );
  }
}
