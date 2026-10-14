import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/osces/osce/osce_bloc.dart';
import 'package:flashcards/bloc/osces/osce/osce_event.dart';
import 'package:flashcards/bloc/osces/osce/osce_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/domain/models/osce/osce.dart';
import 'package:flashcards/domain/models/osce/question/question.dart';
import 'package:flashcards/l10n/app_localizations.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

/// Shown after the last question: the checklist of every question, where the
/// user ticks what they covered, then submits to see their score.
class OsceChecklistReview extends StatelessWidget {
  const OsceChecklistReview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OsceBloc, OsceState, Osce>(
      selector: (state) {
        if (state is! OsceLoaded) {
          throw Exception("Osce is not in loaded state");
        }
        return state.osce;
      },
      builder: (context, osce) {
        final textTheme = TextTheme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text("Checklist", style: textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text(
                    "Tick everything you covered, then submit to see your "
                    "score.",
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < osce.questions.length; i++)
                    _QuestionChecklist(
                      questionIndex: i,
                      question: osce.questions[i],
                      showNumber: osce.questions.length > 1,
                    ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  children: [
                    LinearPercentIndicator(
                      alignment: MainAxisAlignment.center,
                      lineHeight: 14.0,
                      percent: osce.questions.percentChecked(),
                      backgroundColor: context.colors.surfaceContainerHighest,
                      progressColor: context.colors.primary,
                      animation: true,
                      animateFromLastPercent: true,
                      animationDuration: 250,
                      barRadius: const Radius.elliptical(100, 100),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => context.read<OsceBloc>().add(
                            OsceChecklistClosed(),
                          ),
                          child: const Text("Back to questions"),
                        ),
                        FilledButton(
                          onPressed: () => context.router.replace(
                            OsceSubmitRoute(submittedOsce: osce),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.oscePage_submit,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuestionChecklist extends StatelessWidget {
  final int questionIndex;
  final Question question;
  final bool showNumber;

  const _QuestionChecklist({
    required this.questionIndex,
    required this.question,
    required this.showNumber,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                showNumber
                    ? "${questionIndex + 1}. ${question.text}"
                    : question.text,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < question.checks.length; i++)
              if (question.checks[i].isTitle)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    question.checks[i].text,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                CheckboxListTile(
                  title: Text(question.checks[i].text),
                  value: question.checks[i].isChecked,
                  onChanged: (_) => context.read<OsceBloc>().add(
                    ToggleCheck(checkIndex: i, questionIndex: questionIndex),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
