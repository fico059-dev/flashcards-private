import 'package:flashcards/domain/models/progress/card_progress.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class ProgressSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const ProgressSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.colors.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: context.colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle!,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class StatTileData {
  final String label;
  final String value;
  final String? caption;
  final IconData icon;
  final Color? color;

  const StatTileData({
    required this.label,
    required this.value,
    required this.icon,
    this.caption,
    this.color,
  });
}

/// Two columns of key numbers.
class StatGrid extends StatelessWidget {
  final List<StatTileData> tiles;

  const StatGrid({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final tile in tiles)
              SizedBox(width: width, child: _StatTile(tile)),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final StatTileData data;

  const _StatTile(this.data);

  @override
  Widget build(BuildContext context) {
    final color = data.color ?? context.colors.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.label,
                  style: context.text.labelMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value,
              style: context.text.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          if (data.caption != null)
            Text(
              data.caption!,
              style: context.text.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

/// "What to study next" list.
class AdviceList extends StatelessWidget {
  final List<StudyAdvice> advice;

  const AdviceList({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in advice)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _color(
                    context,
                    item.kind,
                  ).withValues(alpha: 0.15),
                  child: Icon(
                    _icon(item.kind),
                    size: 18,
                    color: _color(context, item.kind),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.detail,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static IconData _icon(AdviceKind kind) => switch (kind) {
    AdviceKind.review => Icons.replay,
    AdviceKind.newCards => Icons.fiber_new_outlined,
    AdviceKind.weakTopic => Icons.track_changes,
    AdviceKind.pack => Icons.folder_open,
    AdviceKind.goal => Icons.flag_outlined,
    AdviceKind.praise => Icons.emoji_events_outlined,
  };

  static Color _color(BuildContext context, AdviceKind kind) => switch (kind) {
    AdviceKind.review => context.colors.primary,
    AdviceKind.newCards => Colors.teal,
    AdviceKind.weakTopic => Colors.deepOrange,
    AdviceKind.pack => Colors.indigo,
    AdviceKind.goal => Colors.green.shade700,
    AdviceKind.praise => Colors.amber.shade800,
  };
}

/// A labelled bar, e.g. a pack's coverage or a topic's weakness.
class ProgressBarRow extends StatelessWidget {
  final String title;
  final String trailing;
  final String? subtitle;
  final List<(double, Color)> segments;

  const ProgressBarRow({
    super.key,
    required this.title,
    required this.trailing,
    required this.segments,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                trailing,
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(
                    color: context.colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                  Row(
                    children: [
                      for (final (share, color) in segments)
                        if (share > 0)
                          Expanded(
                            flex: (share.clamp(0, 1) * 1000).round(),
                            child: Container(color: color),
                          ),
                      if (segments.fold(0.0, (sum, s) => sum + s.$1) < 1)
                        Expanded(
                          flex:
                              ((1 - segments.fold(0.0, (sum, s) => sum + s.$1))
                                          .clamp(0, 1) *
                                      1000)
                                  .round(),
                          child: const SizedBox(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle!,
                style: context.text.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProgressMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ProgressMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          Icon(icon, size: 48, color: context.colors.outline),
          const SizedBox(height: 12),
          Text(
            title,
            style: context.text.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }
}
