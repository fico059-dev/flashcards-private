import 'package:flashcards/bloc/flashcards/session_test/session_test_bloc.dart';
import 'package:flashcards/bloc/flashcards/session_test/session_test_event.dart';
import 'package:flashcards/bloc/flashcards/session_test/session_test_state.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_cubit.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NextButtonWithSessionBloc extends StatelessWidget {
  const NextButtonWithSessionBloc({super.key});

  @override
  Widget build(BuildContext context) {
    void onPressed(bool isCorrect) {
      final profileState = context.read<ProfileReaderCubit>().state;
      if (profileState is! ProfileReaderIsLoaded) {
        throw Exception("Profile is not loaded when pressing bloc button");
      }

      context.read<SessionTestBloc>().add(
        SessionTestNextPressed(
          isCorrect: isCorrect,
          userStreak: profileState.profile.streak,
        ),
      );
    }

    return BlocSelector<SessionTestBloc, SessionTestState, bool?>(
      selector: (state) {
        if (state is! SessionTestLoaded) {
          throw Exception("State is not loaded state");
        }

        if (state.status.isNoFlashcard) return null;

        return state.answerShown;
      },
      builder: (context, answerShown) {
        if (answerShown == null) {
          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: () => onPressed(true),
                    child: Text(
                      "تخطّي هذا السؤال",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        if (!answerShown) {
          return SizedBox.shrink();
        }

        return Row(
          spacing: 10,
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: () => onPressed(false),
                  child: Text("أجبت خطأ", textAlign: TextAlign.center),
                ),
              ),
            ),

            Expanded(
              child: SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: () => onPressed(true),
                  child: Text(
                    "أجبت صح",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
