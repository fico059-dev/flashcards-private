import 'package:auto_route/auto_route.dart';
import 'package:flashcards/ui/widgets/tutorial/tutorial_page_template.dart';
import 'package:flutter/material.dart';

@RoutePage()
class FlashcardsTutorialPage extends StatelessWidget {
  final VoidCallback? onFinish;

  const FlashcardsTutorialPage({super.key, this.onFinish});

  final List<TutorialSlide> _slides = const [
    TutorialSlide(
      icon: Icons.style,
      title: "المذاكرة بالبطاقات",
      description:
          "البطاقات تعتمد التكرار المتباعد لحساب أفضل وقت "
          "للمراجعة. كل حزمة تعرض عدد البطاقات المستحقة، فتعرف دائماً "
          "وش تذاكر بعده.",
    ),
    TutorialSlide(
      icon: Icons.layers,
      title: "بدء جلسة اختبار",
      description:
          "اضغط على الحزمة اللي تبي تذاكرها.\n"
          "كل جلسة تجمع 80% بطاقات مراجعة و20% بطاقات جديدة. "
          "وهذا يثبّت معلوماتك القديمة وفي نفس الوقت "
          "يضيف مادة جديدة تدريجياً.",
    ),
    TutorialSlide(
      assetPath: "assets/images/flashcards_tutorial/question_demo.jpg",
      title: "السؤال أولاً",
      description:
          "كل بطاقة تبدأ بسؤال. خذ لحظة لتتذكر الإجابة "
          "— في ذهنك أو بصوت عالٍ.",
    ),
    TutorialSlide(
      assetPath: "assets/images/flashcards_tutorial/answer_demo.jpg",
      title: "أظهر الإجابة",
      description: "اضغط «إظهار الإجابة» لتشوف الإجابة الصحيحة مع الشرح. ",
    ),
    TutorialSlide(
      assetPath: "assets/images/flashcards_tutorial/actions_demo.jpg",
      title: "قيّم تذكّرك",
      description:
          "بعد ما تشوف الإجابة، قيّم قد إيش تذكّرتها. "
          "كن صريحاً — اختيارك يحدد متى تظهر لك البطاقة من جديد. \n\n"
          "نصيحة — اضغط مطولاً على زر التقييم لتعرف معناه.",
    ),
    TutorialSlide(
      assetPath: "assets/images/parrot_chest.png",
      title: "جدولة ذكية",
      description:
          "إجاباتك تُعالَج بخوارزمية FSRS التي تحسب "
          "أفضل وقت لمراجعة كل بطاقة. وبهذا تشوف المعلومة "
          "من جديد في الوقت اللي أنت فيه أقرب لنسيانها.",
    ),
    TutorialSlide(
      assetPath: "assets/images/parrot_fire.png",
      title: "إنهاء الجلسة",
      description:
          "كل جلسة فيها عدد ثابت من البطاقات (تقدر تغيّره من الإعدادات). "
          "إذا خلصت كل البطاقات تنتهي الجلسة، وتكون جاهز "
          "للمراجعة التالية.",
    ),
    TutorialSlide(
      assetPath: "assets/images/parrot_weights.png",
      title: "يلا نبدأ!",
      description: "ممتاز! حان وقت تطبيق معلوماتك.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return TutorialPageTemplate(slides: _slides, onFinish: onFinish,);
  }
}
