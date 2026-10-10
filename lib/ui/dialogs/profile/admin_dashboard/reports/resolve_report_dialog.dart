import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/reports/resolve_report/resolve_report_cubit.dart';
import 'package:flashcards/bloc/reports/resolve_report/resolve_report_state.dart';
import 'package:flashcards/data/repositories/flashcards/report_repository.dart';
import 'package:flashcards/ui/widgets/core/loading_overlay_listener.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<bool?> showResolveReportDialog({
  required BuildContext context,
  required String flashcardId,
}) async {
  return await showDialog(
    context: context,
    builder: (context) => BlocProvider(
      create: (context) =>
          ResolveReportCubit(reportRepo: context.read<ReportRepository>()),
      child: _Dialog(flashcardId: flashcardId),
    ),
  );
}

class _Dialog extends StatelessWidget {
  final String flashcardId;

  const _Dialog({super.key, required this.flashcardId});

  @override
  Widget build(BuildContext context) {
    void onResolve() {
      context.read<ResolveReportCubit>().resolveReport(flashcardId);
    }

    return LoadingOverlayListener<ResolveReportCubit, ResolveReportState>(
      isLoading: (state) => state is ResolveReportLoading,
      loadingText: "Resolving flashcard report...",
      child: BlocListener<ResolveReportCubit, ResolveReportState>(
        listenWhen: (previous, current) =>
            current is ResolveReportError || current is ResolveReportSuccess,
        listener: (context, state) {
          switch (state) {
            case ResolveReportError(:final error):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(extractErrorMessage(error))),
              );
              context.router.pop(false);
            case ResolveReportSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Successfully resolved report")),
              );
              context.router.pop(true);
            case ResolveReportLoading():
            case ResolveReportInitial():
              break;
          }
        },
        child: AlertDialog(
          icon: const Icon(Icons.task_alt),
          title: const Text("Are you sure you want to resolve this report?"),
          content: const Text(
            "This will remove all reports associated with this flashcard. "
            "This action cannot be undone.\n\n"
            "⚠️ Before resolving, please make sure to update the flashcard "
            "if it contains incorrect information, or delete it completely "
            "if it is poorly made. \n\n"
            "Resolving should only be done once you are "
            "100% confident that the flashcard is accurate.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(onPressed: onResolve, child: const Text("Resolve")),
          ],
        ),
      ),
    );
  }
}
