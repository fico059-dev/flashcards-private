import 'package:flashcards/bloc/osces/osce/osce_bloc.dart';
import 'package:flashcards/bloc/osces/osce/osce_event.dart';
import 'package:flashcards/bloc/osces/osce/osce_state.dart';
import 'package:flashcards/domain/models/osce/osce.dart';
import 'package:flashcards/l10n/app_localizations.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';

class OsceBottomActionButtons extends StatelessWidget {
  const OsceBottomActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OsceBloc, OsceState, (Osce, int, bool?)>(
      selector: (state) {
        if (state is! OsceLoaded) {
          throw Exception("Osce is not in loaded state");
        }

        // it works like this:
        // true => it's the first question
        // null => it's the question in between
        // false => it's the last question;
        bool? questionIndexState;
        if (state.osce.questions.length == 1) {
          questionIndexState = false;
        } else if (state.currentQuestionIndex == 0) {
          questionIndexState = true;
        } else if (state.currentQuestionIndex ==
            state.osce.questions.length - 1) {
          questionIndexState = false;
        }

        return (state.osce, state.currentQuestionIndex, questionIndexState);
      },
      builder: (context, tuple) {
        final osce = tuple.$1;
        final currentIndex = tuple.$2;
        final questionIndexState = tuple.$3;
        void onFinish() {
          context.read<OsceBloc>().add(OsceChecklistOpened());
        }

        // if (osce == null) {
        //   return SafeArea(
        //     top: false,
        //     child: SizedBox(
        //       height: 40,
        //       width: double.infinity,
        //       child: FilledButton(onPressed: onReveal, child: Text("Reveal")),
        //     ),
        //   );
        // }

        return SafeArea(
          top: false,
          child: Column(
            children: [
              LinearPercentIndicator(
                alignment: MainAxisAlignment.center,
                //width: MediaQuery.of(context).size.width * 0.75,
                lineHeight: 14.0,
                // Progress through the questions; the checklist comes at the
                // end.
                percent: (currentIndex + 1) / osce.questions.length,
                backgroundColor: context.colors.surfaceContainerHighest,
                progressColor: context.colors.primary,
                animation: true,
                curve: Curves.easeInOut,
                animationDuration: 250,
                barRadius: Radius.elliptical(100, 100),
                animateFromLastPercent: true,
                animateToInitialPercent: true,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (questionIndexState == true)
                    const SizedBox(width: 100)
                  else
                    ElevatedButton(
                      onPressed: () {
                        context.read<OsceBloc>().add(
                          PreviousQuestionRequested(),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.oscePage_previous,
                      ),
                    ),

                  if (questionIndexState == false)
                    FilledButton(
                      onPressed: onFinish,
                      child: const Text("Finish & see checklist"),
                    )
                  else
                    FilledButton(
                      onPressed: () {
                        context.read<OsceBloc>().add(NextQuestionRequested());
                      },
                      child: Text(AppLocalizations.of(context)!.oscePage_next),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
