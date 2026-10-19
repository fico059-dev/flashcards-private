import 'package:auto_route/auto_route.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flutter/cupertino.dart';

enum MainTab { home, verbal, quant, sessions, learningProgress }

class MainTabRoutes {
  static final mainTabPages = const [
    HomeRoute(),
    VerbalPacksRoute(),
    QuantPacksRoute(),
    PreviousSessionsRoute(),
    LearningProgressRoute(),
  ];

  static int mainTabToIndex(MainTab tab) => tab.index;

  static String getRouteTitle(BuildContext context, TabsRouter tabsRouter) {
    switch (tabsRouter.current.name) {
      case HomeRoute.name:
        return "تقدر";
      case VerbalPacksRoute.name:
        return "القسم اللفظي";
      case QuantPacksRoute.name:
        return "القسم الكمي";
      case PreviousSessionsRoute.name:
        return "جلساتي";
      case LearningProgressRoute.name:
        return "تقدّمي";
      default:
        return "";
    }
  }
}
