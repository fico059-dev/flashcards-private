import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/reports/user_reports_getter/user_reports_getter_bloc.dart';
import 'package:flashcards/bloc/reports/user_reports_getter/user_reports_getter_event.dart';
import 'package:flashcards/bloc/reports/user_reports_getter/user_reports_getter_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/data/repositories/flashcards/report_repository.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/domain/models/flashcards/reports/user_report/user_report.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/custom_drag_handle.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/reports/user_report_tile.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/reports/user_reports_floating_button.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/reports/user_reports_shimmer.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/reports/user_reports_simple_floating_button.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

Future<bool?> showUserReportsBottomSheet({
  required BuildContext context,
  required Flashcard flashcard,
  bool simpleFloatingButton = false,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.97,
      expand: false,
      builder: (context, scrollController) => BlocProvider(
        create: (context) => UserReportsGetterBloc(
          reportRepo: context.read<ReportRepository>(),
          flashcardId: flashcard.id,
        ),
        child: _BottomSheetContent(
          simpleFloatingButton: simpleFloatingButton,
          flashcard: flashcard,
          scrollController: scrollController,
        ),
      ),
    ),
  );
}

class _BottomSheetContent extends StatelessWidget {
  final Flashcard flashcard;
  final ScrollController scrollController;
  final bool simpleFloatingButton;

  const _BottomSheetContent({
    super.key,
    required this.flashcard,
    required this.scrollController,
    required this.simpleFloatingButton,
  });

  @override
  Widget build(BuildContext context) {
    void onPreview() {
      context.router.push(FlashcardPreviewRoute(flashcard: flashcard));
    }

    return Padding(
      padding: bottomSheetHorizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(onPreview: onPreview),
          BlocBuilder<UserReportsGetterBloc, UserReportsGetterState>(
            builder: (context, state) {
              final bool isEmpty = state.pagingState.items?.isEmpty ?? true;

              return Expanded(
                child: Scaffold(
                  backgroundColor:
                      context.theme.bottomSheetTheme.backgroundColor ??
                      context.colors.surfaceContainerLow,
                  body: PagedListView(
                    scrollController: scrollController,
                    state: state.pagingState,
                    fetchNextPage: context
                        .read<UserReportsGetterBloc>()
                        .fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate(
                      noItemsFoundIndicatorBuilder: (context) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalScreenPadding,
                          ),
                          child: Center(
                            child: Text(
                              "ما فيه بلاغات على هذه البطاقة 😊",
                              style: TextTheme.of(context).headlineSmall,
                            ),
                          ),
                        );
                      },
                      firstPageProgressIndicatorBuilder: (context) =>
                          UserReportsShimmer(),
                      firstPageErrorIndicatorBuilder: (context) => ErrorScreen(
                        errorMessage: extractErrorMessage(
                          state.pagingState.error!,
                        ),
                        onReload: () => context
                            .read<UserReportsGetterBloc>()
                            .add(UserReportsGetterRefresh()),
                      ),
                      itemBuilder: (context, item, index) {
                        //return UserReportsShimmer();
                        final report = item as UserReport;
                        return UserReportTile(report: report);
                      },
                    ),
                  ),
                  floatingActionButton: !isEmpty
                      ? simpleFloatingButton
                            ? UserReportsSimpleFloatingButton(
                                flashcardId: flashcard.id,
                              )
                            : UserReportsFloatingButton(flashcard: flashcard)
                      : SizedBox.shrink(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onPreview;

  const _Header({super.key, required this.onPreview});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomDragHandle(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "بلاغات البطاقة",
              style: TextTheme.of(
                context,
              ).titleLarge?.merge(TextStyle(fontWeight: FontWeight.w600)),
            ),

            Row(
              spacing: 5,
              children: [
                Tooltip(
                  message: "معاينة البطاقة",
                  child: IconButton(
                    onPressed: onPreview,
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
