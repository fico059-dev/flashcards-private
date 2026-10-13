import 'dart:async';

import 'package:flashcards/bloc/profile/profile_reader/profile_reader_cubit.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_state.dart';
import 'package:flashcards/data/services/local/daily_target.dart';
import 'package:flashcards/data/services/local/study_rewards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

/// Picture and words for each [DailyMood].
({String image, String text, bool clock}) moodLook(
  DailyMood mood,
  DailyStatus status,
) {
  final count = '${status.done}/${status.target} cards today';
  return switch (mood) {
    DailyMood.happy => (
      image: 'assets/images/happy_parrot.png',
      text: "Today's target done! ($count)",
      clock: false,
    ),
    DailyMood.excited => (
      image: 'assets/images/parrot_fire_eyes.png',
      text: 'Over halfway, keep going! ($count)',
      clock: false,
    ),
    DailyMood.anxious => (
      image: 'assets/images/parrot_sad.png',
      text: 'Less than 4 hours left today! ($count)',
      clock: true,
    ),
    DailyMood.sad => (
      image: 'assets/images/parrot_sad.png',
      text: "Yesterday's target was missed. Let's make today count! ($count)",
      clock: false,
    ),
    DailyMood.calm => (
      image: 'assets/images/parrot_like.png',
      text: "Let's study! ($count)",
      clock: false,
    ),
  };
}

/// The day streak and a parrot showing how today's target is going, for the
/// top bar of the main screens.
class AppBarStreak extends StatefulWidget {
  const AppBarStreak({super.key});

  @override
  State<AppBarStreak> createState() => _AppBarStreakState();
}

class _AppBarStreakState extends State<AppBarStreak> {
  static const _color = Color(0xFFFF7A00);

  DailyStatus? _status;
  Timer? _timer;
  StudyRewards? _rewards;
  int? _cardsPerSession;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_rewards == null) {
      try {
        _rewards = context.read<StudyRewards>()
          ..sessionListenable.addListener(_refresh);
      } on ProviderNotFoundException {
        _rewards = null;
      }
      // The mood changes with the time of day too.
      _timer = Timer.periodic(const Duration(minutes: 10), (_) => _refresh());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rewards?.sessionListenable.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _refresh() async {
    final cardsPerSession = _cardsPerSession;
    if (cardsPerSession == null || !mounted) return;
    DailyTargetService service;
    try {
      service = context.read<DailyTargetService>();
    } on ProviderNotFoundException {
      return;
    }
    final status = await service.status(cardsPerSession);
    if (mounted) setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileReaderCubit, ProfileReaderState>(
      builder: (context, state) {
        if (state is! ProfileReaderIsLoaded) return const SizedBox.shrink();
        final cardsPerSession = state.profile.profileSettings.cardsPerSession;
        if (cardsPerSession != _cardsPerSession) {
          _cardsPerSession = cardsPerSession;
          WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
        }
        final count = state.profile.streak.count;
        final status = _status;
        final look = status == null ? null : moodLook(status.mood, status);
        return Tooltip(
          message: [
            '$count-day streak. Study at least 10 cards a day to keep it going!',
            ?look?.text,
          ].join('\n'),
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(seconds: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (look != null) ...[
                  _MoodParrot(image: look.image, clock: look.clock),
                  const SizedBox(width: 6),
                ],
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

class _MoodParrot extends StatelessWidget {
  final String image;
  final bool clock;

  const _MoodParrot({required this.image, required this.clock});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: Image.asset(image, fit: BoxFit.contain)),
          if (clock)
            const Positioned(
              right: -4,
              bottom: -2,
              child: Icon(Icons.alarm, size: 16, color: Color(0xFFE53935)),
            ),
        ],
      ),
    );
  }
}
