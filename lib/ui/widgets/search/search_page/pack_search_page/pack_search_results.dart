import 'package:flashcards/bloc/pack/pack_searcher/pack_searcher_bloc.dart';
import 'package:flashcards/bloc/pack/pack_searcher/pack_searcher_event.dart';
import 'package:flashcards/bloc/pack/pack_searcher/pack_searcher_state.dart';
import 'package:flashcards/domain/models/algolia/algolia_pack/algolia_pack.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/search/core_widgets/algolia_pack_card.dart';
import 'package:flashcards/ui/widgets/search/shimmers/pack_shimmer.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PackSearchResults extends StatefulWidget {
  final Function(String packId, bool? hasCards)? onTap;
  final bool showDefaultPremiumIcon;

  const PackSearchResults({
    super.key,
    this.onTap,
    this.showDefaultPremiumIcon = false,
  });

  @override
  State<PackSearchResults> createState() => _PackSearchResultsState();
}

class _PackSearchResultsState extends State<PackSearchResults> {
  @override
  void initState() {
    super.initState();
    // context.read<PackSearcherBloc>().add(PackSearcherClaimsFetched());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PackSearcherBloc, PackSearcherState>(
      builder: (context, state) {
        return PagedSliverList(
          state: state.pagingState,
          fetchNextPage: context.read<PackSearcherBloc>().fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate(
            invisibleItemsThreshold: 3,
            firstPageProgressIndicatorBuilder: (context) => PackShimmer(),
            noItemsFoundIndicatorBuilder: (context) => Center(
              child: Text(
                textAlign: TextAlign.center,
                "No items found, try changing your search parameters",
              ),
            ),
            firstPageErrorIndicatorBuilder: (context) => ErrorScreen(
              errorMessage: state.pagingState.error == null
                  ? "Error loading packs"
                  : "Error loading packs\n"
                        "${extractErrorMessage(state.pagingState.error!)}",
              onReload: () => context.read<PackSearcherBloc>().add(
                PackSearcherRequestSent(query: ''),
              ),
            ),
            itemBuilder: (context, item, index) {
              // return PackShimmer();
              final pack = item as AlgoliaPack;
              debugPrint(
                '[ALGOLIA] objectID=${pack.objectID}, name=${pack.name}',
              );
              return AlgoliaPackCard(
                pack: pack,
                hasCards: widget.showDefaultPremiumIcon
                    ? false
                    : state.hasCards,
                onTap: widget.onTap != null
                    ? () => widget.onTap!(pack.objectID, state.hasCards)
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}
