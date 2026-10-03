import 'package:flashcards/bloc/flashcards/flashcard/flashcard_bloc.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_event.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_state.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_cubit.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_state.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/rating_buttons/rating_segments.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/rating_buttons/score_segmented_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsrs/fsrs.dart' as fsrs;

class FlashcardRatingButtons extends StatefulWidget {
  const FlashcardRatingButtons({super.key});

  @override
  State<FlashcardRatingButtons> createState() => _FlashcardRatingButtonsState();
}

class _FlashcardRatingButtonsState extends State<FlashcardRatingButtons> {
  fsrs.Rating? _activeRating;

  void _onSelectRating(fsrs.Rating? rating) {
    setState(() => _activeRating = rating);
    if (rating == null) return;

    final profileState = context.read<ProfileReaderCubit>().state;
    if (profileState is! ProfileReaderIsLoaded) {
      throw Exception("Profile is not loaded");
    }

    context.read<FlashcardBloc>().add(
      FlashcardRatingGiven(
        rating: rating,
        userStreak: profileState.profile.streak,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FlashcardBloc, FlashcardState>(
      listenWhen: (previous, current) =>
          current.status.isLoaded && current.status != previous.status,
      listener: (context, state) {
        if (state.status.isLoaded) {
          setState(() => _activeRating = null);
        }
      },
      builder: (context, state) {
        if (!state.answerVisible) return SizedBox.shrink();

        return ScoreSegmentedButton<fsrs.Rating>(
          onChanged: _onSelectRating,
          segments: buildRatingSegments(
            context,
            state.statRecords[state.currentCardIndex].card,
          ),
          selectedValue: _activeRating,
        );
      },
    );
  }
}
