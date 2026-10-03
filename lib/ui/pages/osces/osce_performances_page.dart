import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/osce_performance_blocs/osce_perf_getter/osce_perf_getter_bloc.dart';
import 'package:flashcards/bloc/osce_performance_blocs/osce_perf_getter/osce_perf_getter_event.dart';
import 'package:flashcards/bloc/osce_performance_blocs/osce_perf_getter/osce_perf_getter_state.dart';
import 'package:flashcards/data/repositories/osces/osce_performance_repository.dart';
import 'package:flashcards/domain/models/osce/osce_performance/osce_performance.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/osce_performance/osce_performance_card.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

@RoutePage()
class OscePerformancesPage extends StatelessWidget {
  const OscePerformancesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OscePerfGetterBloc(
        perfRepo: context.read<OscePerformanceRepository>(),
      ),
      child: _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> handleRefresh(BuildContext context) {
      final completer = Completer<void>();
      context.read<OscePerfGetterBloc>().add(
        OscePerfGetterRefresh(completer: completer),
      );

      return completer.future.catchError((error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(extractErrorMessage(error))));
      });
    }

    void decreaseAttemptCountOnDeleted(String osceId) {
      context.read<OscePerfGetterBloc>().add(
        OscePerfGetterIncreaseCount(osceId: osceId),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("OSCE Performances"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
        child: BlocBuilder<OscePerfGetterBloc, OscePerfGetterState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => handleRefresh(context),
              child: PagedListView(
                state: state.pagingState,
                fetchNextPage: context.read<OscePerfGetterBloc>().fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate(
                  noItemsFoundIndicatorBuilder: (context) =>
                      _EmptyListContainer(),
                  firstPageProgressIndicatorBuilder: (context) =>
                      OscePerformancesShimmer(),
                  firstPageErrorIndicatorBuilder: (context) => ErrorScreen(
                    errorMessage: extractErrorMessage(state.pagingState.error!),
                    onReload: () => context.read<OscePerfGetterBloc>().add(
                      OscePerfGetterFetched(restart: true),
                    ),
                  ),
                  itemBuilder: (context, item, index) {
                    //return OscePerformancesShimmer();
                    final perf = item as OscePerformance;
                    return OscePerformanceCard(
                      performance: perf,
                      onAttemptDeleted: () =>
                          decreaseAttemptCountOnDeleted(perf.simpleOsce.id),
                    );
                  },
                ),
                //separatorBuilder: (context, index) => SizedBox(height: 10),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyListContainer extends StatelessWidget {
  const _EmptyListContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/parrot_sad.png", height: 200),
          const SizedBox(height: 10),
          Text(
            "No results yet...",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Text(
            "Start your first OSCE test and see your progress here!",
            style: TextTheme.of(context).titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
