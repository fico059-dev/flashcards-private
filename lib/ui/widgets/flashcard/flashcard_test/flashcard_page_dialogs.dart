import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_bloc.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_event.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flashcards/l10n/app_localizations.dart';

void showPackFinishedDialog(BuildContext context, String subTextForDialog) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.flashcardPageDialog_packFinishedForNow,
        ),
        content: Text(
          AppLocalizations.of(
            context,
          )!.flashcardPageDialog_packEnded(subTextForDialog),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.router.replaceAll([HomeRoute()]);
            },
            child: Text(
              AppLocalizations.of(context)!.flashcardPageDialog_backHome,
            ),
          ),
        ],
      );
    },
  );
}

void showSessionEndedDialog(BuildContext context, FlashcardBloc bloc) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(
          AppLocalizations.of(
            context,
          )!.flashcardPageDialog_sessionFinishedForNow,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Text(
              AppLocalizations.of(context)!.flashcardPageDialog_sessionEnded,
            ),
            Text(
              AppLocalizations.of(context)!.flashcardPageDialog_closeSession,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.router.replaceAll([HomeRoute()]);
            },
            child: Text(
              AppLocalizations.of(context)!.flashcardPageDialog_backHome,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              bloc.add(FlashcardSessionExtended());
            },
            child: Text(
              AppLocalizations.of(
                context,
              )!.flashcardPageDialog_continueLearning,
            ),
          ),
        ],
      );
    },
  );
}

Future<bool?> showUpdateCardsPerSessionDialog({
  required BuildContext context,
  required int cardDifference,
  required int userCardsPerSession,
}) async {
  final newCardsPerSession = cardDifference + userCardsPerSession;
  return await showDialog<bool>(
    context: context,
    //barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.flashcardPageDialog_endThisSession,
      ),
      content: Text(
        AppLocalizations.of(context)!.flashcardPageDialog_updateCardsPerSession(
          cardDifference,
          userCardsPerSession,
          newCardsPerSession,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            AppLocalizations.of(context)!.flashcardPageDialog_keepCurrent,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            AppLocalizations.of(context)!.flashcardPageDialog_updateTarget,
          ),
        ),
      ],
    ),
  );
}
