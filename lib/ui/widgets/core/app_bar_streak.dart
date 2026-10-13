import 'package:flashcards/bloc/profile/profile_reader/profile_reader_cubit.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The day streak, for the top bar of the main screens.
class AppBarStreak extends StatelessWidget {
  const AppBarStreak({super.key});

  static const _color = Color(0xFFFF7A00);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileReaderCubit, ProfileReaderState>(
      builder: (context, state) {
        if (state is! ProfileReaderIsLoaded) return const SizedBox.shrink();
        final count = state.profile.streak.count;
        return Tooltip(
          message:
              '$count-day streak. Study at least 10 cards a day to keep it '
              'going!',
          triggerMode: TooltipTriggerMode.tap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: count > 0 ? _color : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 2),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: count > 0 ? _color : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
