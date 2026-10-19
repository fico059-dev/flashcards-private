import 'package:auto_route/auto_route.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/domain/enums/score_status.dart';
import 'package:flutter/material.dart';

@RoutePage()
class CustomSessionResultPage extends StatelessWidget {
  final ScoreStatus scoreStatus;
  final int correctCount;
  final int allCount;

  const CustomSessionResultPage({
    super.key,
    required this.scoreStatus,
    required this.correctCount,
    required this.allCount,
  });

  String _getTitle() {
    switch (scoreStatus) {
      case ScoreStatus.low:
        return "اكتملت الجلسة";
      case ScoreStatus.okay:
        return "اكتملت الجلسة 🎉";
      case ScoreStatus.max:
        return "علامة كاملة! 🌟";
    }
  }

  String _getMessage() {
    switch (scoreStatus) {
      case ScoreStatus.low:
        return "جهد جيد! أنهيت جلستك المخصّصة.\n"
            "لا تشيل هم إذا كانت النتيجة مو عالية هالمرة — كل محاولة تفيدك.";
      case ScoreStatus.okay:
        return "عمل ممتاز! ركّزت وتقدّمت.\n"
            "استمر في التدرّب وبتتحسن أكثر.";
      case ScoreStatus.max:
        return "مبروك! أجبت على كل الأسئلة صح في هذه الجلسة.\n"
            "تركيز رائع، أحسنت!";
    }
  }

  String _getImagePath() {
    switch (scoreStatus) {
      case ScoreStatus.low:
        return "assets/images/parrot_sad.png";
      case ScoreStatus.okay:
        return "assets/images/parrot_like.png";
      case ScoreStatus.max:
        return "assets/images/parrot_fire.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$correctCount / $allCount",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Image.asset(_getImagePath(), height: 200),
                const SizedBox(height: 24),
                Text(
                  _getTitle(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _getMessage(),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () {
                      context.router.pop();
                    },
                    child: const Text("العودة للرئيسية"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
