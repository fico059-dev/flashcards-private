import 'package:flashcards/bloc/theme/theme_cubit.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool asFab;
  final Color? iconColor;

  const ThemeToggleButton({super.key, this.asFab = false, this.iconColor});

  /// Named constructor za FloatingActionButton verziju
  const ThemeToggleButton.asFab({super.key, this.iconColor}) : asFab = true;

  IconData _iconForMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.wb_sunny_rounded;
      case ThemeMode.dark:
        return Icons.nights_stay_rounded;
      case ThemeMode.system:
      default:
        return Icons.brightness_auto_rounded;
    }
  }

  String _labelForMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
      default:
        return 'النظام';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final icon = _iconForMode(mode);
        final label = _labelForMode(mode);
        final color = iconColor ?? context.colors.primary;

        if (asFab) {
          return FloatingActionButton.small(
            tooltip: !kDebugMode ? 'المظهر: $label' : null,
            onPressed: () => context.read<ThemeCubit>().switchTheme(),
            backgroundColor: color,
            child: Icon(icon),
          );
        }

        if (kDebugMode) {
          return IconButton(
            icon: Icon(icon, color: color),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          );
        }

        return Tooltip(
          message: 'المظهر: $label',
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
        );
      },
    );
  }
}
