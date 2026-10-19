import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

import 'color_extensions/color_pallet.dart';

const Color taqdirGold = Color(0xFFC9A227);
const Color taqdirGoldDark = Color(0xFF8A6D0F);

final ColorScheme lightScheme = ColorScheme.fromSeed(
  seedColor: taqdirGold,
  brightness: Brightness.light,
).copyWith(
  primary: const Color(0xFF9C7A0C),
  onPrimary: Colors.white,
  primaryContainer: const Color(0xFFF6E7B0),
  onPrimaryContainer: const Color(0xFF3A2C04),
  secondary: taqdirGold,
  onSecondary: Colors.white,
  surface: Colors.white,
  surfaceTint: Colors.transparent,
  surfaceContainer: const Color(0xFFFBF6E4),
  surfaceContainerHigh: const Color(0xFFF6EFD2),
  outline: const Color(0xFFD9C27A),
);

final darkScheme = ColorScheme.fromSeed(
  seedColor: taqdirGold,
  brightness: Brightness.dark,
).copyWith(
  primary: const Color(0xFFE3C766),
  onPrimary: const Color(0xFF3A2C04),
  primaryContainer: const Color(0xFF5B4508),
  onPrimaryContainer: const Color(0xFFF6E7B0),
  secondary: taqdirGold,
);

final lightThemeData = ThemeData(
  colorScheme: lightScheme,
  fontFamily: 'Tajawal',
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    foregroundColor: Color(0xFF3A2C04),
  ),
  navigationBarTheme: navigationBarTheme(lightScheme),
  inputDecorationTheme: inputDecorationTheme(lightScheme),
  bottomSheetTheme: bottomSheetThemeData(lightScheme),
  cardTheme: cardThemeData(lightScheme),
  snackBarTheme: snackBarThemeData(
    lightScheme,
  ).copyWith(backgroundColor: Colors.black),
  floatingActionButtonTheme: floatingActionButtonThemeData(lightScheme),
  dividerTheme: dividerThemeData(lightScheme),
  extensions: [lightCustomColors],
);

final darkThemeData = ThemeData(
  colorScheme: darkScheme,
  fontFamily: 'Tajawal',
  navigationBarTheme: navigationBarTheme(darkScheme),
  inputDecorationTheme: inputDecorationTheme(darkScheme),
  bottomSheetTheme: bottomSheetThemeData(darkScheme),
  cardTheme: cardThemeData(darkScheme),
  dividerTheme: dividerThemeData(darkScheme),
  floatingActionButtonTheme: floatingActionButtonThemeData(darkScheme),
  extensions: [darkCustomColors],
);

FloatingActionButtonThemeData floatingActionButtonThemeData(ColorScheme scheme) =>
  FloatingActionButtonThemeData(backgroundColor: scheme.primary);

DividerThemeData dividerThemeData(ColorScheme scheme) =>
    DividerThemeData(color: scheme.outline);

CardThemeData cardThemeData(ColorScheme scheme) =>
    CardThemeData(elevation: 2, color: scheme.surfaceContainer);

BottomSheetThemeData bottomSheetThemeData(ColorScheme scheme) =>
    BottomSheetThemeData(
      shape: bottomSheetShape,
      //backgroundColor: scheme.surface,
    );

SnackBarThemeData snackBarThemeData(ColorScheme scheme) =>
    SnackBarThemeData(backgroundColor: scheme.surfaceContainerHigh);

NavigationBarThemeData navigationBarTheme(ColorScheme scheme) =>
    NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      surfaceTintColor: scheme.surfaceTint,
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: scheme.onPrimaryContainer);
        }
        return IconThemeData(color: scheme.onSurfaceVariant);
      }),
    );

InputDecorationTheme inputDecorationTheme(ColorScheme scheme) =>
    InputDecorationTheme(
      filled: true,
      //fillColor: scheme.surfaceContainer,
      //floatingLabelStyle: TextStyle(color: scheme.primary),
      // labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      // hintStyle: TextStyle(color: scheme.onSurfaceVariant.withOpacity(0.7)),
      errorStyle: TextStyle(color: scheme.error),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.outline, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.primary, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.error, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.error, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
    );

// Old theme data, more vibrant but not so great with dark mode
final ThemeData lightThemeDataOld = ThemeData(
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.grey[200],
    indicatorColor: Colors.indigo[600],
    surfaceTintColor: Colors.indigo[200],
    iconTheme: WidgetStateProperty<IconThemeData>.fromMap(
      <WidgetStatesConstraint, IconThemeData>{
        WidgetState.selected: IconThemeData(color: Colors.indigo.shade50),
        WidgetState.any: IconThemeData(color: Colors.indigo.shade900),
      },
    ),
  ),

  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Colors.indigo,
    linearTrackColor: Colors.indigo.shade100,
  ),
  scaffoldBackgroundColor: Colors.grey[100],
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: _inputDecorationThemeOld,
  ),
  inputDecorationTheme: _inputDecorationThemeOld,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.indigo,
    backgroundColor: Colors.grey[200],
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.grey.shade600, width: 1),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[100],
    surfaceTintColor: Colors.grey[100],
  ),
);

final InputDecorationTheme _inputDecorationThemeOld = InputDecorationTheme(
  focusColor: Colors.indigo,
  fillColor: Colors.grey[200],
  filled: true,
  floatingLabelStyle: TextStyle(color: Colors.indigo),
  labelStyle: TextStyle(color: Colors.grey[500]),
  hintStyle: TextStyle(color: Colors.grey[500]),
  errorStyle: TextStyle(color: Colors.red.shade700),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.indigo, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red.shade700, width: 1),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red.shade700, width: 2),
  ),
  disabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
  ),
);

ButtonStyle tonalButtonStyle(BuildContext context) {
  final scheme = context.colors;

  return FilledButton.styleFrom(
    backgroundColor: scheme.secondaryContainer,
    foregroundColor: scheme.onSecondaryContainer,
    textStyle: TextStyle(color: scheme.onSecondaryContainer),
  );
}
