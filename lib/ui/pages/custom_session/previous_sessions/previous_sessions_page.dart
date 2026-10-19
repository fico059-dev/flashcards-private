import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/custom_session/custom_session_getter/custom_session_getter_bloc.dart';
import 'package:flashcards/bloc/custom_session/custom_session_getter/custom_session_getter_event.dart';
import 'package:flashcards/bloc/custom_session/custom_session_getter/custom_session_getter_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/domain/models/flashcards/custom_session_summary/custom_session_summary.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/dialogs/previous_session/prev_sessions_options_bottom_sheet.dart';
import 'package:flashcards/ui/widgets/core/card_factory.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/core/loading_overlay_listener.dart';
import 'package:flashcards/ui/widgets/previous_sessions/previous_session_card.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

@RoutePage()
class PreviousSessionsPage extends StatelessWidget {
  const PreviousSessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _View();
  }
}

class _View extends StatefulWidget {
  const _View({super.key});

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  Future<void> handleRefresh(BuildContext context) {
    final completer = Completer<void>();
    context.read<CustomSessionGetterBloc>().add(
      CustomSessionGetterRefresh(completer: completer),
    );

    return completer.future.catchError((error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(extractErrorMessage(error))));
    });
  }

  void onSessionDelete(String sessionId) {
    context.read<CustomSessionGetterBloc>().add(
      CustomSessionGetterDelete(sessionId: sessionId),
    );
  }

  void onSessionReset(String sessionId) {
    context.read<CustomSessionGetterBloc>().add(
      CustomSessionGetterReset(sessionId: sessionId),
    );
  }

  void onSessionStart(CustomSessionSummary session) async {
    if (session.isPaid) {
      final ok = await ensureCardsAccess(context);
      if (!ok) return;
    }

    context.router.push(CustomSessionTestRoute(sessionSummary: session));
  }

  void onSessionTap(CustomSessionSummary session) {
    showPrevSessionsOptionsBottomSheet(
      context: context,
      session: session,
      onSessionDelete: () => onSessionDelete(session.id),
      onSessionReset: () => onSessionReset(session.id),
      onSessionStart: !session.isFinished
          ? () => onSessionStart(session)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlayListener<
      CustomSessionGetterBloc,
      CustomSessionGetterState
    >(
      isLoading: (state) => state.status.isActionLoading,
      child: BlocListener<CustomSessionGetterBloc, CustomSessionGetterState>(
        listenWhen: (previous, current) =>
            current.status.isResetSuccessful ||
            current.status.isDeleteSuccessful ||
            current.status.isActionError,
        listener: (context, state) {
          switch (state.status) {
            case CustomSessionGetterStatus.deleteSuccessful:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("تم حذف الجلسة")),
              );
              break;
            case CustomSessionGetterStatus.resetSuccessful:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("تم تصفير تقدّم الجلسة")),
              );
              break;
            case CustomSessionGetterStatus.actionError:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(extractErrorMessage(state.error!))),
              );
              break;
            default:
          }
        },
        child: Scaffold(
          body: Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
            child:
                BlocBuilder<CustomSessionGetterBloc, CustomSessionGetterState>(
                  builder: (context, state) {
                    return RefreshIndicator(
                      onRefresh: () => handleRefresh(context),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: CardFactory.info(
                              title: Text("اسحب لليسار"),
                              subtitle: Text(
                                "اسحب الجلسة لليسار للوصول "
                                "السريع لكل الخيارات.",
                              ),
                              closable: true,
                              isThreeLine: true,
                            ),
                          ),

                          SliverToBoxAdapter(child: SizedBox(height: 15)),

                          PagedSliverList(
                            state: state.pagingState,
                            fetchNextPage: context
                                .read<CustomSessionGetterBloc>()
                                .fetchNextPage,
                            builderDelegate: PagedChildBuilderDelegate(
                              firstPageErrorIndicatorBuilder: (context) =>
                                  ErrorScreen(
                                    errorMessage: extractErrorMessage(
                                      state.pagingState.error!,
                                    ),
                                    onReload: context
                                        .read<CustomSessionGetterBloc>()
                                        .fetchNextPage,
                                  ),
                              noItemsFoundIndicatorBuilder: (context) =>
                                  _EmptyListContainer(),
                              firstPageProgressIndicatorBuilder: (context) =>
                                  PreviousSessionsShimmer(),
                              itemBuilder: (context, item, index) {
                                final session = item as CustomSessionSummary;

                                return PreviousSessionCard(
                                  hasCards: state.hasCards,
                                  session: session,
                                  onDeletePressed: () =>
                                      onSessionDelete(session.id),
                                  onStartPressed: !session.isFinished
                                      ? () => onSessionStart(session)
                                      : null,
                                  onResetPressed: () =>
                                      onSessionReset(session.id),
                                  onTap: () => onSessionTap(session),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ),
      ),
    );
  }
}

class _EmptyListContainer extends StatelessWidget {
  const _EmptyListContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 15,
        children: [
          Text("ما أنشأت أي جلسة مخصّصة للحين."),

          FilledButton(
            onPressed: () =>
                context.replaceRoute(const CustomSessionWrapperRoute()),
            child: Text("إنشاء جلسة مخصّصة"),
          ),
        ],
      ),
    );
  }
}
