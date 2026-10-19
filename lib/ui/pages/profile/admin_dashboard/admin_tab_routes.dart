import 'package:auto_route/auto_route.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flashcards/l10n/app_localizations.dart';

enum AdminTab { addFlashcards, assignAdmin }

class AdminTabRoutes {
  static final routes = const [
    AdminPackSearchRoute(),
    AssignAdminRoute(),
    FlashcardReportsRoute(),
    FlashcardBuilderRoute(),
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
      case FlashcardReportsRoute.name:
        return "البطاقات المبلّغ عنها";
      default:
        return "";
    }
  }
}
