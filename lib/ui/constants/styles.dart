import 'package:flutter/material.dart';

/// ✨ Shimmer colors
Color shimmerBaseColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? Colors.grey.shade800
    : Colors.grey.shade300;

Color shimmerHighlightColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? Colors.grey.shade700
    : Colors.grey.shade100;

final double horizontalScreenPadding = 25;
final double bottomSpacingOnFloatingButtons = 70;

final double bottomSheetHorizontalPaddingValue = 20;
final bottomSheetHorizontalPadding = EdgeInsets.symmetric(
  horizontal: bottomSheetHorizontalPaddingValue,
);
final bottomSheetPadding = EdgeInsets.only(
  bottom: 70,
  left: bottomSheetHorizontalPaddingValue,
  right: bottomSheetHorizontalPaddingValue,
);
final bottomSheetPaddingNoBot = EdgeInsets.only(
  bottom: 10,
  left: bottomSheetHorizontalPaddingValue,
  right: bottomSheetHorizontalPaddingValue,
);
final bottomSheetPaddingWithTop = EdgeInsets.only(
  bottom: 70,
  left: bottomSheetHorizontalPaddingValue,
  right: bottomSheetHorizontalPaddingValue,
  top: 15,
);
final bottomSheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
);

final flashcardPagePadding = EdgeInsets.only(
  left: horizontalScreenPadding,
  right: horizontalScreenPadding,
  bottom: 40,
  top: 15,
);

/// Wraps a bottom sheet builder so the sheet's content scrolls when it is
/// taller than the sheet (e.g. menus with many options on small phones).
/// Use with `isScrollControlled: true`.
WidgetBuilder scrollableSheet(WidgetBuilder builder) =>
    (context) => SingleChildScrollView(child: builder(context));

/// Lifts a bottom sheet's content above the on-screen keyboard, so text
/// fields and buttons near the bottom stay reachable while typing.
class KeyboardAwareSheet extends StatelessWidget {
  final Widget child;

  const KeyboardAwareSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: child,
    );
  }
}
