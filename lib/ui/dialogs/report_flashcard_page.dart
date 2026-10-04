import 'package:auto_route/annotations.dart';
import 'package:flashcards/bloc/reports/report/report_cubit.dart';
import 'package:flashcards/bloc/reports/report/report_state.dart';
import 'package:flashcards/data/repositories/flashcards/report_repository.dart';
import 'package:flashcards/domain/enums/report_reason.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/ui/widgets/core/bloc_buttons/bloc_button_text.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class ReportFlashcardPage extends StatelessWidget {
  final Flashcard flashcard;
  final String packId;
  final String? packName;

  const ReportFlashcardPage({
    super.key,
    required this.flashcard,
    required this.packId,
    this.packName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ReportCubit(reportRepo: context.read<ReportRepository>()),
      child: _ReportFlashcardView(
        flashcard: flashcard,
        packId: packId,
        packName: packName,
      ),
    );
  }
}

class _ReportFlashcardView extends StatefulWidget {
  final Flashcard flashcard;
  final String packId;
  final String? packName;

  const _ReportFlashcardView({
    super.key,
    required this.flashcard,
    required this.packId,
    this.packName,
  });

  @override
  State<_ReportFlashcardView> createState() => _ReportFlashcardViewState();
}

class _ReportFlashcardViewState extends State<_ReportFlashcardView> {
  ReportReason? selectedReason;
  late final TextEditingController _messageController;

  bool get isSubmitEnabled => selectedReason != null;

  void submitReport() {
    context.read<ReportCubit>().sendReport(
      packName: widget.packName,
      packId: widget.packId,
      flashcard: widget.flashcard,
      reportReason: selectedReason!,
      message: _messageController.text.trim(),
    );
  }

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportCubit, ReportState>(
      listenWhen: (previous, current) =>
          current is ReportSuccess || current is ReportError,
      listener: (context, state) {
        switch (state) {
          case ReportSuccess():
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.reportFlashcardPage_success,
                ),
              ),
            );
            break;
          case ReportError(:final error):
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(extractErrorMessage(error))));
            break;
          case ReportInitial():
          case ReportLoading():
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.reportFlashcardPage_report),
          actions: [
            BlocButtonText<ReportCubit, ReportState>(
              isLoadingState: (state) => state is ReportLoading,
              onPressed: isSubmitEnabled ? submitReport : null,
              textString: AppLocalizations.of(
                context,
              )!.reportFlashcardPage_submitReport,
            ),
          ],
        ),
        body: ReadableWidth(
          maxWidth: 820,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.reportFlashcardPage_whyReporting,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...ReportReason.values.map(
                    (reason) => RadioListTile<ReportReason>(
                      title: Text(reason.toLocalizedString(context)),
                      value: reason,
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      )!.reportFlashcardPage_additionalDetails,
                      hintText: AppLocalizations.of(
                        context,
                      )!.reportFlashcardPage_explain,
                      border: OutlineInputBorder(),
                    ),
                    minLines: 2,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
