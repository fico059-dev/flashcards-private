import 'package:auto_route/auto_route.dart';
import 'package:flashcards/domain/models/profile/profile.dart';
import 'package:flashcards/domain/models/profile/streak/streak.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/profile/profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MoreProfileDetails extends StatelessWidget {
  final Profile profile;

  const MoreProfileDetails({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ProfileAvatar(
                size: 72,
                editable: true,
                iconColor: context.colors.onPrimary,
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    "${profile.name} ${profile.surname}",
                    style: Theme.of(context).textTheme.headlineSmall?.merge(
                      TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onPrimary,
                      ),
                    ),
                  ),
                  Text(
                    profile.email,
                    style: Theme.of(context).textTheme.bodySmall?.merge(
                      TextStyle(color: context.colors.onPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),

          StreakWidget(streakCount: profile.streak.count),
        ],
      ),
    );
  }
}

class StreakWidget extends StatelessWidget {
  final int streakCount;

  const StreakWidget({super.key, required this.streakCount});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          "Complete at least 10 flashcards in a day to increase your "
          "streak. Keep going every day to keep the fire alive!",
      preferBelow: false,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: Colors.white),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: context.customColors.warningContainer,
            size: 28,
          ),
          const SizedBox(width: 4),
          Text(
            "$streakCount",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.customColors.warningContainer,
            ),
          ),
        ],
      ),
    );
  }
}
