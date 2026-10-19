import 'package:auto_route/auto_route.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/profile/profile_menu_widget.dart';
import 'package:flutter/material.dart';

@RoutePage()
class LearningProgressPage extends StatelessWidget {
  const LearningProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
        child: Column(
          children: [
            ProfileMenuWidget(
              title: "الحزم التي بدأتها",
              subtitle: "صفّر تقدّمك لكل حزمة من هنا",
              icon: Icons.folder_open,
              onPress: () => context.router.push(const StartedPacksRoute()),
            ),
            ProfileMenuWidget(
              title: "تقدّم البطاقات",
              subtitle: "تصفّح البطاقات وتابع تقدّمك",
              icon: Icons.question_answer_outlined,
              onPress: () => context.router.push(const FlashcardsSearcherRoute()),
            ),
          ],
        ),
      ),
    );
  }
}
