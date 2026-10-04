import 'package:auto_route/auto_route.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

@RoutePage()
class PermissionDeniedPage extends StatelessWidget {
  const PermissionDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReadableWidth(
        maxWidth: 820,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(bottom: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      "assets/lottie/error_animation.json",
                      height: 180,
                      width: 180,
                      repeat: false,
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Će uđeš malo mac",
                      style: TextTheme.of(context).headlineSmall,
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () {
                  context.router.pop();
                  context.router.replaceAll([MainTabRoute()]);
                },
                child: Text("Back to home page"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
