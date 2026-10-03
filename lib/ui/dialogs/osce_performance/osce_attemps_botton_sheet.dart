import 'package:flashcards/bloc/osce_performance_blocs/osce_attempts_getter/osce_attempts_getter_bloc.dart';
import 'package:flashcards/bloc/osce_performance_blocs/osce_attempts_getter/osce_attempts_getter_event.dart';
import 'package:flashcards/bloc/osce_performance_blocs/osce_attempts_getter/osce_attempts_getter_state.dart';
import 'package:flashcards/data/repositories/osces/osce_performance_repository.dart';
import 'package:flashcards/domain/models/osce/osce_performance/osce_attempt/osce_attempt.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/dialogs/osce_performance/delete_osce_attempt_dialog.dart';
import 'package:flashcards/ui/widgets/core/custom_drag_handle.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/osce_performance/osce_attempt_card.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

Future<bool?> showOsceAttemptsBottomSheet({
  required BuildContext context,
  required String osceId,
  VoidCallback? onAttemptDeleted,
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
        create: (context) => OsceAttemptGetterBloc(
          osceId: osceId,
          perfRepo: context.read<OscePerformanceRepository>(),
        ),
        child: _BottomSheetContent(
          osceId: osceId,
          scrollController: scrollController,
          onAttemptDeleted: onAttemptDeleted,
        ),
      ),
    ),
  );
}

class _BottomSheetContent extends StatelessWidget {
  final String osceId;
  final ScrollController scrollController;
  final VoidCallback? onAttemptDeleted;

  const _BottomSheetContent({
    super.key,
    required this.osceId,
    required this.scrollController,
    this.onAttemptDeleted,
  });

  @override
  Widget build(BuildContext context) {
    void onDelete(String attemptId) async {
      final result = await showDeleteOsceAttemptDialog(
        context: context,
        osceId: osceId,
        attemptId: attemptId,
      );

      if (result == null || !result || !context.mounted) return;

      context.read<OsceAttemptGetterBloc>().add(
        OsceAttemptsRemoved(attemptId: attemptId),
      );

      onAttemptDeleted?.call();
    }

    return Padding(
      padding: bottomSheetHorizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          BlocBuilder<OsceAttemptGetterBloc, OsceAttemptsGetterState>(
            builder: (context, state) {
              return Expanded(
                child: PagedListView(
                  scrollController: scrollController,
                  state: state.pagingState,
                  fetchNextPage: context
                      .read<OsceAttemptGetterBloc>()
                      .fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate(
                    noItemsFoundIndicatorBuilder: (context) =>
                        _EmptyListContainer(),
                    firstPageProgressIndicatorBuilder: (context) =>
                        OsceAttemptsShimmer(),
                    firstPageErrorIndicatorBuilder: (context) => ErrorScreen(
                      errorMessage: extractErrorMessage(
                        state.pagingState.error!,
                      ),
                      onReload: () => context.read<OsceAttemptGetterBloc>().add(
                        OsceAttemptsGetterFetched(restart: true),
                      ),
                    ),
                    itemBuilder: (context, item, index) {
                      //return UserReportsShimmer();
                      final attempt = item as OsceAttempt;
                      return OsceAttemptCard(
                        attempt: attempt,
                        onDelete: () => onDelete(attempt.id),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyListContainer extends StatelessWidget {
  const _EmptyListContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset("assets/images/parrot_sad.png", height: 200),
        const SizedBox(height: 20),
        Text(
          "All attempts for this OSCE have been deleted. \n",
          style: TextTheme.of(context).titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          "Your best score and the date of your first attempt are "
          "still recorded, but there are no saved attempt details.",
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDragHandle(),
        Text(
          "OSCE attempts",
          style: TextTheme.of(
            context,
          ).titleLarge?.merge(TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
