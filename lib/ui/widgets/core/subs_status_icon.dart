import 'package:flashcards/ui/constants/placeholders.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SubsStatusIcon extends StatelessWidget {
  final bool isPaid;
  final bool? hasAccess;
  final double size;
  final bool showLabel;

  /// disables the "free" icon
  final bool disableFreeIcon;

  /// Paid packs have 2 icons:
  /// "locked" -> if you don't have sub
  ///
  /// "مفتوح" -> if you have a sub
  /// This flag disabled the 'unlocked' icon
  final bool disabledUnlockedIcon;

  const SubsStatusIcon({
    super.key,
    required this.isPaid,
    required this.hasAccess,
    this.showLabel = false,
    this.size = 16,
    this.disableFreeIcon = false,
    this.disabledUnlockedIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget? icon;
    String? label;

    if (isPaid) {
      if (hasAccess == null) {
        icon = Shimmer.fromColors(
          baseColor: shimmerBaseColor(context),
          highlightColor: shimmerHighlightColor(context),
          child: RoundedPlaceholder(width: size, height: size),
        );
      } else if (hasAccess!) {
        if (!disabledUnlockedIcon) {
          icon = Icon(Icons.diamond_outlined, size: size, color: context.customColors.info);
          label = "مفتوح";
        }
      } else {
        icon = Icon(Icons.lock, size: size, color: context.colors.onSurfaceVariant);
        label = "مدفوع";
      }
    } else {
      if (!disableFreeIcon) {
        icon = Icon(Icons.check_circle, size: size, color: context.customColors.success);
        label = "مجاني";
      }
    }

    if (showLabel && label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon ?? SizedBox.shrink(),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: size * 0.8)),
        ],
      );
    }

    return icon ?? SizedBox.shrink();
  }
}
