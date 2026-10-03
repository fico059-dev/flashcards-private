import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/osce_performance_blocs/save_osce_attempt/save_osce_attempt_cubit.dart';
import 'package:flashcards/bloc/osce_performance_blocs/save_osce_attempt/save_osce_attempt_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/data/repositories/osces/osce_performance_repository.dart';
import 'package:flashcards/data/services/local/study_log_store.dart';
import 'package:flashcards/domain/enums/score_status.dart';
import 'package:flashcards/domain/models/progress/study_log.dart';
import 'package:flashcards/domain/models/osce/osce.dart';
import 'package:flashcards/domain/models/osce/question/check/check.dart';
import 'package:flashcards/domain/models/osce/question/question.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/images/image_preview.dart';
import 'package:flashcards/ui/widgets/osce/osce_submit_floating_button.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flashcards/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class OsceSubmitPage extends StatelessWidget {
  final Osce submittedOsce;

  const OsceSubmitPage({super.key, required this.submittedOsce});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SaveOsceAttemptCubit(
        oscePerformanceRepo: context.read<OscePerformanceRepository>(),
      ),
      child: _View(submittedOsce: submittedOsce),
    );
  }
}

class _View extends StatefulWidget {
  final Osce submittedOsce;

  const _View({super.key, required this.submittedOsce});

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  late final Osce osce;
  late final List<Question> questions;
  late final ScoreStatus scoreStatus;
  late final int maxScore;
  late final int achievedScore;

  void _saveOsceAttempt() {
    context.read<SaveOsceAttemptCubit>().saveAttempt(
      simpleOsce: osce.toSimpleOsce(),
      maxScore: maxScore,
      achievedScore: achievedScore,
    );
  }

  /// Remembers which sections and checks were missed, for the Progress tab.
  void _recordOsceDetails() {
    context.read<StudyLogStore>().update(
      (log) => log.recordOsce(
        osceId: osce.id,
        name: osce.name,
        results: [
          for (final question in questions)
            if (question.getMaxScore() > 0)
              OsceQuestionResult(
                text: question.text,
                achieved: question.getAchievedScore(),
                max: question.getMaxScore(),
                missedChecks: [
                  for (final check in question.checks)
                    if (!check.isTitle && !check.isChecked) check.text,
                ],
              ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    osce = widget.submittedOsce;
    questions = osce.questions;
    scoreStatus = osce.getScoreStatus();
    achievedScore = osce.getAchievedScore();
    maxScore = osce.getMaxScore();

    _saveOsceAttempt();
    _recordOsceDetails();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaveOsceAttemptCubit, SaveOsceAttemptState>(
      listenWhen: (previous, current) => current is SaveOsceAttemptError,
      listener: (context, state) {
        switch (state) {
          case SaveOsceAttemptError(:final error):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                action: SnackBarAction(
                  label: "Retry",
                  onPressed: _saveOsceAttempt,
                ),
                content: Text(extractErrorMessage(error)),
                duration: const Duration(seconds: 10),
              ),
            );
            break;
          case SaveOsceAttemptInitial():
          case SaveOsceAttemptLoading():
          case SaveOsceAttemptSuccess():
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text("${osce.name} result")),
        floatingActionButton: OsceSubmitFloatingButton(osceId: osce.id),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (scoreStatus == ScoreStatus.max)
                    ScoreResultView(
                      score: osce.getAchievedScore(),
                      maxScore: osce.getMaxScore(),
                      feedbackText: "Perfect score! You nailed it!",
                      assetImagePath: "assets/images/parrot_fire_eyes.png",
                    ),
                  if (scoreStatus == ScoreStatus.okay)
                    ScoreResultView(
                      score: osce.getAchievedScore(),
                      maxScore: osce.getMaxScore(),
                      feedbackText: "Great job! Keep going strong.",
                      assetImagePath: "assets/images/parrot_like.png",
                    ),
                  if (scoreStatus == ScoreStatus.low)
                    ScoreResultView(
                      score: osce.getAchievedScore(),
                      maxScore: osce.getMaxScore(),
                      feedbackText: "Don’t worry, practice will get you there!",
                      assetImagePath: "assets/images/parrot_sad.png",
                    ),
                  ListView(
                    shrinkWrap: true,
                    primary: false,
                    children: questions
                        .map((question) => QuestionView(question: question))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<SaveOsceAttemptCubit, SaveOsceAttemptState>(
                    builder: (context, state) {
                      if (state is! SaveOsceAttemptError) {
                        return SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Saving failed. Try again.",
                            style: TextTheme.of(context).titleMedium?.copyWith(
                              color: context.colors.error,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: FilledButton(
                              onPressed: _saveOsceAttempt,
                              child: Text("Retry saving this attempt"),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        context.router.replace(HomeRoute());
                      },
                      child: Text(
                        AppLocalizations.of(context)!.osceSubmitPage_back,
                      ),
                    ),
                  ),
                  const SizedBox(height: 65),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuestionView extends StatelessWidget {
  final Question question;

  const QuestionView({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Naslov pitanja
            Text(
              question.text,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Slika
            Center(
              child: ImagePreview(
                downloadUrl: question.imageDownloadUrl,
                showTextWhenEmpty: false,
                height: 150,
              ),
            ),

            if (question.imageDownloadUrl != null) const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: question.checks
                  .map((check) => _CheckView(check: check))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckView extends StatelessWidget {
  final Check check;

  const _CheckView({super.key, required this.check});

  @override
  Widget build(BuildContext context) {
    if (check.isTitle) {
      return Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 9),
        child: Text(
          check.text,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          spacing: 15,
          children: [
            Icon(
              check.isChecked ? Icons.check_circle : Icons.cancel,
              color: check.isChecked
                  ? context.customColors.success
                  : context.colors.error,
            ),
            Expanded(
              child: Text(
                check.text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text("${check.isChecked ? check.score : "0"}/${check.score}"),
          ],
        ),
      );
    }
  }
}

class ScoreResultView extends StatelessWidget {
  final int score;
  final int maxScore;
  final String feedbackText;
  final String assetImagePath;

  const ScoreResultView({
    super.key,
    required this.score,
    required this.maxScore,
    required this.feedbackText,
    required this.assetImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$score / $maxScore",
            style: theme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Image.asset(
            assetImagePath,
            height: MediaQuery.of(context).size.height * 0.25, // adaptivno
            fit: BoxFit.contain,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              feedbackText,
              style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

// FilledButton(
//   onPressed: () async {
//     final pdfService = await PdfExportService.create();
//     final pdfBytes = await pdfService.generateOscePdf(widget.submittedOsce);
//     final file = await pdfService.savePdf(pdfBytes, "osce_${widget.submittedOsce.name}");
//
//     final result = await OpenFile.open(file.path);
//
//     if (result.type != ResultType.done && Platform.isIOS) {
//       await Share.shareXFiles([XFile(file.path)], text: "Here is your OSCE PDF");
//     }
//   },
//   style: FilledButton.styleFrom(
//     minimumSize: Size(
//       MediaQuery.of(context).size.width * 0.3,
//       48,
//     ),
//   ),
//   child: Text(
//     AppLocalizations.of(context)!.osceSubmitPage_download,
//   ),
// ),
