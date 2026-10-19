import 'package:flashcards/domain/models/flashcards/custom_session_summary/custom_session_summary.dart';
import 'package:flashcards/ui/constants/placeholders.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/subs_status_icon.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';

class PreviousSessionCard extends StatelessWidget {
  final CustomSessionSummary session;
  final VoidCallback? onStartPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onResetPressed;
  final VoidCallback? onRenamePressed;
  final bool? hasCards;
  final VoidCallback? onTap;

  const PreviousSessionCard({
    super.key,
    required this.session,
    required this.hasCards,
    this.onStartPressed,
    this.onDeletePressed,
    this.onResetPressed,
    this.onRenamePressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = context.colors.surfaceContainerHigh;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Slidable(
        key: ValueKey(session.id),
        endActionPane: ActionPane(
          extentRatio: 0.8,
          // closeThreshold: 0.7,
          // openThreshold: 0.3,
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onStartPressed?.call(),
              backgroundColor: onStartPressed != null
                  ? context.customColors.success
                  : context.colors.outlineVariant,
              foregroundColor: onStartPressed != null
                  ? context.customColors.onSuccess
                  : context.colors.onSurface,
              icon: Icons.play_arrow,
              label: 'Start',
            ),
            SlidableAction(
              onPressed: (_) => onResetPressed?.call(),
              backgroundColor: context.customColors.info,
              foregroundColor: context.customColors.onInfo,
              icon: Icons.refresh,
              label: 'Reset',
            ),
            SlidableAction(
              onPressed: (_) => onDeletePressed?.call(),
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onError,
              icon: Icons.delete_forever,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.all(0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  // Top-right card count
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Row(
                      spacing: 6,
                      children: [
                        SubsStatusIcon(
                          isPaid: session.isPaid,
                          hasAccess: hasCards,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${session.cardCount} cards',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: context.colors.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leaves room for the card count in the corner.
                      Padding(
                        padding: const EdgeInsets.only(right: 110),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                session.displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (onRenamePressed != null)
                              IconButton(
                                tooltip: 'Rename session',
                                visualDensity: VisualDensity.compact,
                                iconSize: 18,
                                onPressed: onRenamePressed,
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: context.colors.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: session.isFinished
                                ? context.customColors.success
                                : context.colors.primary,
                          ),
                          const SizedBox(width: 6),
                          if (session.isFinished)
                            Text('Progress: Finished')
                          else
                            Text(
                              'Progress: ${(session.currentIndex + 1)}/${session.cardCount}',
                              style: theme.textTheme.bodyMedium,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Created: ${formatSmartDate(session.createdAt)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
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

class PreviousSessionsShimmer extends StatelessWidget {
  const PreviousSessionsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          _Card(),
          _Card(),
          _Card(),
          _Card(),
          _Card(),
          _Card(),
          _Card(),
          _Card(),
          _Card(),
          _Card(),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: context.colors.surfaceContainerHigh,
      child: Shimmer.fromColors(
        baseColor: shimmerBaseColor(context),
        highlightColor: shimmerHighlightColor(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TitlePlaceholder(width: 100, isTwoLine: false),
                  RoundedPlaceholder(fullyRounded: false, width: 40),
                ],
              ),

              const SizedBox(height: 45),

              ContentNoBannerPlaceholder(lineType: ContentLineType.twoLines),
            ],
          ),
        ),
      ),
    );
  }
}
