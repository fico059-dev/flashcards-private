import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_event.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/domain/models/flashcards/pack/pack.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/subs_status_icon.dart';
import 'package:flutter/material.dart';

class PackUiCard extends StatelessWidget {
  final Pack pack;
  final VoidCallback? onTap;
  final bool? hasCards;

  /// Shown before the name, e.g. the button that opens the sub-packs.
  final Widget? leading;

  /// Shown under the name, e.g. how many sub-packs there are.
  final String? subtitle;

  const PackUiCard({
    super.key,
    required this.pack,
    this.onTap,
    required this.hasCards,
    this.leading,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:
            onTap ??
            () => context.router.push(
              FlashcardRoute(testType: TestType.regular, pack: pack),
            ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        ?leading,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pack.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              if (subtitle != null)
                                Text(
                                  subtitle!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SubsStatusIcon(isPaid: pack.isPaid, hasAccess: hasCards),
                      const SizedBox(width: 6),
                      Text(
                        '${pack.flashcardsCount} cards',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (hasCards == true || !pack.isPaid) ...[
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (pack.dueCount != -1)
                      _infoBadge(
                        Icons.schedule,
                        'Due: ${pack.dueCount}',
                        context.colors.primary,
                      ),
                    if (pack.learningCount != -1)
                      _infoBadge(
                        Icons.auto_stories,
                        'Learning: ${pack.learningCount}',
                        context.colors.tertiary,
                      ),
                    if (pack.newCount != -1)
                      _infoBadge(
                        Icons.fiber_new,
                        'New: ${pack.newCount}',
                        context.customColors.success,
                      ),
                  ],
                ),
              ],

              if (hasCards == false && pack.isPaid) SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _infoBadge(IconData icon, String label, Color color) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: color)),
    ],
  );
}
