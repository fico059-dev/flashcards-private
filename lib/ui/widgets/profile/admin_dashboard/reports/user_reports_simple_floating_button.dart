import 'package:auto_route/auto_route.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/reports/resolve_report_dialog.dart';
import 'package:flutter/material.dart';

class UserReportsSimpleFloatingButton extends StatelessWidget {
  final String flashcardId;

  const UserReportsSimpleFloatingButton({super.key, required this.flashcardId});

  @override
  Widget build(BuildContext context) {
    void onResolveReport() async {
      final result = await showResolveReportDialog(
        context: context,
        flashcardId: flashcardId,
      );
      if (result == null || !context.mounted) return;

      context.router.pop(result);
    }

    return FloatingActionButton.extended(
      label: Text("إغلاق البلاغ"),
      icon: Icon(Icons.task_alt),
      onPressed: onResolveReport,
      tooltip: "إغلاق البلاغ",
    );
  }
}
