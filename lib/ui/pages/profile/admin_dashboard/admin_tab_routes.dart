import 'package:auto_route/auto_route.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flashcards/l10n/app_localizations.dart';

enum AdminTab { addFlashcards, assignAdmin }

class AdminTabRoutes {
  static final routes = const [
    AdminPackSearchRoute(),
    OsceBuilderRoute(),
    AssignAdminRoute(),
    FlashcardReportsRoute(),
    FlashcardBuilderRoute(),
    AnalyticsRoute(),
  ];

  static String getRouteTitle(BuildContext context, TabsRouter tabsRouter) {
    final l10n = AppLocalizations.of(context)!;
    final routeName = tabsRouter.current.name;

    switch (routeName) {
      case AssignAdminRoute.name:
        return l10n.assignAdminPage_title;
      case AdminPackSearchRoute.name:
      case FlashcardBuilderRoute.name:
        return l10n.flashcardBuilderPage_title;
      case OsceBuilderRoute.name:
        return l10n.osceBuilderPage_title;
      case FlashcardReportsRoute.name:
        return "Reported flashcards";
      case AnalyticsRoute.name:
        return "Analytics";
      default:
        return "";
    }
  }
}
