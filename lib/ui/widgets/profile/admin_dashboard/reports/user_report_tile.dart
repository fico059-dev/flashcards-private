import 'package:flashcards/domain/models/flashcards/reports/user_report/user_report.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserReportTile extends StatelessWidget {
  final UserReport report;

  const UserReportTile({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = formatSmartDate(report.reportTime);

    return Card(
      color: context.colors.surfaceContainerHigh,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag, color: context.colors.primary, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      report.reason.toLocalizedString(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  dateFormatted,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Message ako postoji
            if (report.message != null &&
                report.message!.trim().isNotEmpty) ...[
              Text(report.message!, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
            ],

            // // User ID
            Text(
              "User: ${report.userId}",
              style: TextStyle(fontSize: 12, color: context.colors.outline),
            ),
          ],
        ),
      ),
    );
  }
}
