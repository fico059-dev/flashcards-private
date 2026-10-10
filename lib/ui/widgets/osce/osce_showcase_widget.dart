import 'package:flashcards/bloc/osces/osce/osce_bloc.dart';
import 'package:flashcards/bloc/osces/osce/osce_event.dart';
import 'package:flashcards/domain/models/osce/osce.dart';
import 'package:flashcards/domain/models/osce/question/question.dart';
import 'package:flashcards/ui/widgets/core/images/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OsceShowcaseWidget extends StatelessWidget {
  final Osce osce;

  const OsceShowcaseWidget({super.key, required this.osce});

  @override
  Widget build(BuildContext context) {
    void onStartTest() {
      context.read<OsceBloc>().add(OsceTestStarted());
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  osce.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  osce.scenario,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (osce.scenarioImageUrl?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 12),
                  ImagePreview(downloadUrl: osce.scenarioImageUrl, height: 220),
                ],
                const SizedBox(height: 16),

                // QuestionsAndChecksCount(questions: osce.questions);
                // const SizedBox(height: 8),
                const Text(
                  "Time for the test is 10 minutes",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        if (osce.questions.isNotEmpty)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: FilledButton(
                  onPressed: onStartTest,
                  child: const Text("Start test"),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuestionsAndChecksCount extends StatelessWidget {
  final List<Question> questions;

  const _QuestionsAndChecksCount({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
    int totalChecks() =>
        questions.expand((q) => q.checks).where((c) => !c.isTitle).length;

    return Column(
      children: [
        Text(
          "Number of questions: ${questions.length}",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          "Number of checks: $totalChecks",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
