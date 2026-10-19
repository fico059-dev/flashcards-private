import 'package:auto_route/auto_route.dart';
import 'package:flashcards/domain/models/profile/profile.dart';
import 'package:flashcards/domain/models/profile/streak/streak.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
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
              Icon(
                CupertinoIcons.profile_circled,
                size: 80,
                color: context.colors.onPrimary,
              ),
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
          "أكمل 10 بطاقات على الأقل في اليوم لزيادة "
          "سلسلة أيامك. واظب كل يوم عشان تبقى الشعلة مشتعلة!",
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
