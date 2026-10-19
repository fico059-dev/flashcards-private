import 'package:flashcards/bloc/pack/started_packs/started_packs_bloc.dart';
import 'package:flashcards/bloc/pack/started_packs/started_packs_event.dart';
import 'package:flashcards/domain/models/flashcards/pack_progress/pack_progress.dart';
import 'package:flashcards/ui/constants/placeholders.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/dialogs/packs/reset_pack_progress_dialog.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class StartedPackCard extends StatelessWidget {
  final PackProgress packProgress;

  const StartedPackCard({super.key, required this.packProgress});

  @override
  Widget build(BuildContext context) {
    void onDelete() {
      context.read<StartedPacksBloc>().add(
        StartedPacksProgressDeleted(packProgress: packProgress),
      );
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: context.colors.secondaryContainer.withValues(alpha: 0.7),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                packProgress.packName,
                style: TextTheme.of(
                  context,
                ).bodyLarge?.merge(TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              leading: Icon(Icons.lock_open, color: context.colors.onSurfaceVariant),
              title: Text(
                "أول فتح: ${formatSmartDate(packProgress.firstOpenedAt)}",
              ),
              titleTextStyle: TextTheme.of(context).bodyMedium?.merge(
                TextStyle(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              leading: Icon(Icons.update, color: context.colors.onSurfaceVariant),
              title: Text(
                "آخر فتح: ${formatSmartDate(packProgress.lastOpenedAt)}",
              ),
              titleTextStyle: TextTheme.of(context).bodyMedium?.merge(
                TextStyle(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(height: 5),
            OutlinedButton.icon(
              onPressed:
                  () => showResetPackProgressDialog(
                    context,
                    packProgress.packName,
                    onDelete,
                  ),
              icon: Icon(Icons.refresh, color: context.colors.error),
              label: Text(
                "تصفير التقدّم",
                style: TextStyle(color: context.colors.error),
              ),
            ),
            // OutlinedButton.icon(
            //   onPressed: onDelete,
            //   icon: Icon(Icons.refresh, color: Colors.red[700]),
            //   label: Text(
            //     "تصفير التقدّم",
            //     style: TextStyle(color: Colors.red[700]),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class StartedPacksShimmer extends StatelessWidget {
  const StartedPacksShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: shimmerBaseColor(context),
      highlightColor: shimmerHighlightColor(context),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            BannerPlaceholder(height: 220),
            BannerPlaceholder(height: 220),
            BannerPlaceholder(height: 220),
            BannerPlaceholder(height: 220),
            BannerPlaceholder(height: 220),
            BannerPlaceholder(height: 220),
            BannerPlaceholder(height: 220),
            BannerPlaceholder(height: 220),
          ],
        ),
      ),
    );
  }
}
