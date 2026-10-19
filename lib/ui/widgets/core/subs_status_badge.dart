import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SubsStatusBadge extends StatelessWidget {
  final bool isPaid;
  final bool? hasCards;
  final Widget child;
  final EdgeInsets? badgePadding;
  final double? badgeTextSize;

  const SubsStatusBadge({
    super.key,
    required this.isPaid,
    required this.hasCards,
    required this.child,
    this.badgePadding,
    this.badgeTextSize,
  });

  @override
  Widget build(BuildContext context) {
    if (isPaid && hasCards == null) {
      // Loading state za paid pack
      return Badge(
        label: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(width: 32, height: 16, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        child: child,
      );
    }

    // Odredi label i boju
    String labelText;
    Color labelColor;

    if (!isPaid) {
      labelText = 'مجاني';
      labelColor = Colors.green[600]!;
    } else if (hasCards == true) {
      labelText = 'مدفوع';
      labelColor = Colors.blue;
    } else {
      labelText = 'مدفوع';
      labelColor = Colors.orange[700]!;
    }

    return Badge(
      label: Text(
        labelText,
        style: TextStyle(
          color: Colors.white,
          fontSize: badgeTextSize ?? 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      padding:
          badgePadding ??
          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      backgroundColor: labelColor,
      child: child,
    );
  }
}
