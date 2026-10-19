import 'package:auto_route/auto_route.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/profile/profile_menu_widget.dart';
import 'package:flutter/material.dart';

@RoutePage()
class FlashcardSettingsPage extends StatelessWidget {
  const FlashcardSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إعدادات المذاكرة"),
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 25),
        padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
        child: Column(
          children: [
            ProfileMenuWidget(
              title: "عدد البطاقات في الجلسة",
              icon: Icons.flag,
              onPress:
                  () => context.router.push(const UpdateCardsPerSessionRoute()),
            ),
            ProfileMenuWidget(
              title: "إدارة البطاقات المتجاهَلة",
              icon: Icons.visibility_off,
              onPress:
                  () =>
                      context.router.push(const ManageIgnoredFlashcardsRoute()),
            ),
          ],
        ),
      ),
    );
  }
}
