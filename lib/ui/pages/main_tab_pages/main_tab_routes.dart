import 'package:auto_route/auto_route.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/domain/models/flashcards/custom_session_summary/custom_session_summary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flashcards/l10n/app_localizations.dart';

enum MainTab { home, osce, packs, learningProgress }

class MainTabRoutes {
  static final mainTabPages = const [
    HomeRoute(),
    OsceListRoute(),
    //PacksRoute(),
    PacksTabRoute(),
    LearningProgressRoute(),
  ];

  static int mainTabToIndex(MainTab tab) {
    switch (tab) {
      case MainTab.home:
        return 0;
      case MainTab.osce:
        return 1;
      case MainTab.packs:
        return 2;
      case MainTab.learningProgress:
        return 3;
    }
  }

  static String getRouteTitle(BuildContext context, TabsRouter tabsRouter) {
    final l10n = AppLocalizations.of(context)!;
    final routeName = tabsRouter.current.name;

    switch (routeName) {
      case HomeRoute.name:
        return l10n.homePage_title;
      case OsceListRoute.name:
        return l10n.osceListPage_title;
      case LearningProgressRoute.name:
        return "Progress";
      case PacksRoute.name:
      case PreviousSessionsRoute.name:
        return l10n.packsPage_title;
      case PacksTabRoute.name:
        return "Packs";
      default:
        return "";
    }
  }
}
