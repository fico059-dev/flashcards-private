import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/pack/started_packs/started_packs_bloc.dart';
import 'package:flashcards/bloc/pack/started_packs/started_packs_event.dart';
import 'package:flashcards/bloc/pack/started_packs/started_packs_state.dart';
import 'package:flashcards/data/repositories/flashcards/pp_repository.dart';
import 'package:flashcards/domain/models/flashcards/pack_progress/pack_progress.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/core/loading_overlay_with_text.dart';
import 'package:flashcards/ui/widgets/profile/flashcard_settings/started_packs/started_pack_card.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loader_overlay/loader_overlay.dart';

@RoutePage()
class StartedPacksPage extends StatelessWidget {
  const StartedPacksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StartedPacksBloc(ppRepo: context.read<PpRepository>()),
      child: _StartedPacksView(),
    );
  }
}

class _StartedPacksView extends StatefulWidget {
  const _StartedPacksView({super.key});

  @override
  State<_StartedPacksView> createState() => _StartedPacksViewState();
}

class _StartedPacksViewState extends State<_StartedPacksView> {
  void _loadData() {
    context.read<StartedPacksBloc>().add(StartedPacksFetched());
  }

  Future<void> _handleRefresh(BuildContext context) {
    final completer = Completer<void>();
    context.read<StartedPacksBloc>().add(
      StartedPacksRefresh(completer: completer),
    );

    return completer.future.catchError((error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(extractErrorMessage(error))));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Started Packs"),
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: ReadableWidth(
        maxWidth: 820,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
          child: BlocListener<StartedPacksBloc, StartedPacksState>(
            listenWhen: (previous, current) {
              return !current.status.isInitial &&
                  current.status != previous.status;
            },
            listener: (context, state) {
              if (state.status.isResettingProgress) {
                context.loaderOverlay.show(
                  widgetBuilder: (progress) => LoadingOverlayWithText(
                    textString:
                        "Resetting data for pack. This might take a while",
                  ),
                );
              } else {
                context.loaderOverlay.hide();
              }

              if (state.status.isError) {
                final error = state.error!;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error.toString())));
              }

              if (state.status.isResetSuccessful) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Successfully reset pack progress")),
                );
              }
            },
            child: BlocBuilder<StartedPacksBloc, StartedPacksState>(
              builder: (context, state) => RefreshIndicator(
                onRefresh: () => _handleRefresh(context),
                child: PagedListView(
                  state: state.pagingState,
                  fetchNextPage: _loadData,
                  builderDelegate: PagedChildBuilderDelegate(
                    invisibleItemsThreshold: 3,
                    firstPageProgressIndicatorBuilder: (context) =>
                        StartedPacksShimmer(),
                    firstPageErrorIndicatorBuilder: (context) => ErrorScreen(
                      errorMessage: extractErrorMessage(
                        state.pagingState.error!,
                      ),
                      onReload: _loadData,
                    ),
                    noItemsFoundIndicatorBuilder: (context) =>
                        _EmptyListContainer(),
                    itemBuilder: (context, item, index) =>
                        StartedPackCard(packProgress: item as PackProgress),
                  ),
                ),
              ),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/parrot_sad.png", height: 200),
          const SizedBox(height: 10),
          Text(
            "No packs opened — start exploring some cards!",
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
