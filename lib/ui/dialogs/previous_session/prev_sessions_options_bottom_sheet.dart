import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/custom_session/custom_session_getter/custom_session_getter_bloc.dart';
import 'package:flashcards/bloc/custom_session/custom_session_getter/custom_session_getter_state.dart';
import 'package:flashcards/domain/models/flashcards/custom_session_summary/custom_session_summary.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showPrevSessionsOptionsBottomSheet({
  required BuildContext context,
  required CustomSessionSummary session,
  required VoidCallback onSessionDelete,
  required VoidCallback onSessionReset,
  required VoidCallback onSessionRename,
  required VoidCallback? onSessionStart,
}) {
  final bloc = context.read<CustomSessionGetterBloc>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: scrollableSheet((context) {
      return BlocProvider.value(
        value: bloc,
        child: BlocListener<CustomSessionGetterBloc, CustomSessionGetterState>(
          listenWhen: (previous, current) =>
              current.status.isResetSuccessful ||
              current.status.isDeleteSuccessful ||
              current.status.isActionError,
          listener: (context, state) {
            switch (state.status) {
              case CustomSessionGetterStatus.deleteSuccessful:
              case CustomSessionGetterStatus.resetSuccessful:
              case CustomSessionGetterStatus.actionError:
                context.router.pop();
              default:
            }
          },
          child: Padding(
            padding: bottomSheetPadding,
            child: Wrap(
              children: [
                Column(
                  children: [
                    ListTile(
                      isThreeLine: true,
                      leading: CircleAvatar(
                        backgroundColor: context.colors.primaryContainer,
                        foregroundColor: context.colors.onPrimaryContainer,
                        child: Icon(Icons.folder),
                      ),
                      title: Text(
                        session.displayName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        children: [
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: session.isFinished
                                    ? context.customColors.success
                                    : context.colors.primaryContainer,
                              ),
                              const SizedBox(width: 6),
                              if (session.isFinished)
                                Text('Progress: Finished')
                              else
                                Text(
                                  'Progress: ${(session.currentIndex + 1)}/${session.cardCount}',
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: context.colors.primaryContainer,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Created: ${formatSmartDate(session.createdAt)}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Divider(),

                    ListTile(
                      leading: Icon(
                        Icons.play_arrow,
                        color: onSessionStart != null
                            ? context.colors.primary
                            : context.colors.outline,
                      ),
                      title: Text(
                        "Start session test",
                        style: TextStyle(
                          color: onSessionStart != null
                              ? context.colors.onSurface
                              : context.colors.outline,
                        ),
                      ),
                      onTap: onSessionStart != null
                          ? () {
                              context.router.pop();
                              onSessionStart();
                            }
                          : null,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.drive_file_rename_outline,
                        color: context.colors.primary,
                      ),
                      title: Text("Rename session"),
                      onTap: () {
                        context.router.pop();
                        onSessionRename();
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.refresh,
                        color: context.colors.primary,
                      ),
                      title: Text("Reset session progress"),
                      onTap: onSessionReset,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever,
                        color: context.colors.error,
                      ),
                      title: Text("Delete session"),
                      onTap: onSessionDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }),
  );
}
