import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class ScoreSegmentedButton<T> extends StatelessWidget {
  final T? selectedValue;
  final List<ScoreSegment<T>> segments;
  final ValueChanged<T> onChanged;

  const ScoreSegmentedButton({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 5,
      children: segments.map((segment) {
        return ScoreButton(
          disabled: selectedValue != null,
          onTap: () => onChanged(segment.value),
          isActive: selectedValue == null
              ? false
              : selectedValue == segment.value,
          label: segment.label,
          time: segment.time,
          tooltip: segment.tooltip,
        );
      }).toList(),
    );
  }
}

class ScoreSegment<T> {
  final T value;
  final String label;
  final String? time;
  final String tooltip;

  const ScoreSegment({
    required this.value,
    required this.label,
    required this.tooltip,
    this.time,
  });
}

class ScoreButton extends StatelessWidget {
  final bool isActive;
  final String label;
  final VoidCallback onTap;
  final bool disabled;
  final String? time;
  final String tooltip;

  const ScoreButton({
    super.key,
    required this.isActive,
    required this.label,
    required this.onTap,
    required this.tooltip,
    this.disabled = false,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      triggerMode: TooltipTriggerMode.longPress,
      child: Column(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: isActive
                ? context.colors.primary
                : context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(80),
            child: InkWell(
              borderRadius: BorderRadius.circular(80),
              onTap: disabled ? () {} : onTap,
              child: Ink(
                height: 65,
                width: 65,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isActive
                        ? context.colors.primaryContainer
                        : context.colors.onSurfaceVariant,
                  ),
                  borderRadius: BorderRadius.circular(80),
                ),
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextTheme.of(context).titleMedium?.copyWith(
                      color: isActive
                          ? context.colors.surface
                          : context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (time != null)
            Text(
              time!,
              style: TextTheme.of(
                context,
              ).labelMedium?.copyWith(color: context.colors.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
