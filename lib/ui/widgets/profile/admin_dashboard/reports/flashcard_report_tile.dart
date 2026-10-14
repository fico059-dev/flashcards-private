import 'package:flashcards/domain/models/flashcards/card_markup/card_markup.dart';
import 'package:flashcards/bloc/reports/fc_reports_getter/fc_reports_getter_bloc.dart';
import 'package:flashcards/bloc/reports/fc_reports_getter/fc_reports_getter_event.dart';
import 'package:flashcards/domain/models/flashcards/reports/flashcard_report/flashcard_report.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/reports/user_reports_bottom_sheet.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/tag_chip.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FlashcardReportTile extends StatelessWidget {
  final FlashcardReport report;

  const FlashcardReportTile({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = formatSmartDate(report.firstReportTime);

    void onShowUserReports() async {
      final result = await showUserReportsBottomSheet(
        context: context,
        flashcard: report.flashcard,
      );
      if (result == null || result == false || !context.mounted) return;

      context.read<FcReportsGetterBloc>().add(
        FcReportsGetterFetched(restart: true),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onShowUserReports,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    report.packName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${report.reportsCount}x",
                      style: TextStyle(
                        color: context.colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                plainCardText(report.flashcard.question),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                plainCardText(report.flashcard.answer),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "First report: $dateFormatted",
                style: TextStyle(fontSize: 12, color: context.colors.outline),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 6,
                runSpacing: -8,
                children: report.flashcard.tags.map((tag) {
                  return TagChip(
                    label: tag.name,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
