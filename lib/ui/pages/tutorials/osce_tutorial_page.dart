import 'package:auto_route/auto_route.dart';
import 'package:flashcards/ui/widgets/tutorial/tutorial_page_template.dart';
import 'package:flutter/material.dart';

@RoutePage()
class OsceTutorialPage extends StatelessWidget {
  final VoidCallback? onFinish;

  const OsceTutorialPage({super.key, this.onFinish});

  final List<TutorialSlide> _slides = const [
    TutorialSlide(
      assetPath: "assets/images/parrot_chest.png",
      title: "What’s an OSCE test?",
      description:
          "OSCE tests are practice simulations! "
          "You’ll go through a list of real-life scenarios and check off"
          " the steps you’d take — just like in an actual OSCE station!",
    ),
    TutorialSlide(
      assetPath: "assets/images/osce_tutorial/osce_preview.jpg",
      title: "Pick Your Test",
      description:
          "Choose the OSCE you want to practice. You’ll see a quick "
          "overview with the test name and scenario. \n\n"
          "When you’re ready — hit Start Test!",
    ),
    TutorialSlide(
      icon: Icons.watch_later,
      title: "10 minutes on the clock!",
      description:
          "You’ve got 10 minutes to complete the test. No pressure "
          "— just do your best and have fun practicing!",
    ),
    TutorialSlide(
      assetPath: "assets/images/osce_tutorial/osce_question.jpg",
      assetPath2: "assets/images/osce_tutorial/osce_reveal_button.jpg",
      title: "Read the question first",
      description:
          "Read each question and answer it as you would in the exam, "
          "then tap Next. After the last question, tap Finish to see "
          "the checklist.",
    ),
    TutorialSlide(
      assetPath: "assets/images/osce_tutorial/osce_question_checks.jpg",
      title: "Tick what you got right",
      description:
          "The checklist of every question appears at the end. Tick each "
          "step you covered, then submit to see your score.",
    ),
    // TutorialSlide(
    //   assetPath: "assets/images/osce_tutorial/osce_next_button.jpg",
    //   title: "Navigate freely",
    //   description:
    //       "You can go back to previous questions anytime. Your checkmarks stay"
    //       " saved, so explore at your own pace!",
    // ),
    TutorialSlide(
      assetPath: "assets/images/osce_tutorial/osce_finished.jpg",
      title: "Finish and see your results",
      description:
          "When you’re done — or when time runs out — you’ll see your score! "
          "Don’t worry, every attempt is saved in your history.",
    ),
    TutorialSlide(
      assetPath: "assets/images/osce_tutorial/osce_attempts.jpg",
      title: "Review your past attempts",
      description:
          "Want to see how you did before? Tap the history button for"
          " this OSCE, or check Previous Results on the home screen!",
    ),
    TutorialSlide(
      assetPath: "assets/images/parrot_weights.png",
      title: "Ready to begin",
      description:
          "That’s it! You’re all set to start your OSCE practice. "
          "Let’s see what you’ve got 💪",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return TutorialPageTemplate(slides: _slides, onFinish: onFinish,);
  }
}
