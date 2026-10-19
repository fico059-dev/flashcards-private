import 'package:flashcards/bloc/flashcards/flashcards_searcher/flashcards_searcher_bloc.dart';
import 'package:flashcards/bloc/flashcards/flashcards_searcher/flashcards_searcher_event.dart';
import 'package:flashcards/bloc/flashcards/flashcards_searcher/flashcards_searcher_state.dart';
import 'package:flashcards/domain/models/algolia/algolia_flashcard/algolia_flashcard.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/search/core_widgets/flashcard_pack_card.dart';
import 'package:flashcards/ui/widgets/search/shimmers/pack_shimmer.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class FlashcardsSearchResults extends StatefulWidget {
  final void Function(AlgoliaFlashcard flashscard, bool hasCards)? onTap;

  const FlashcardsSearchResults({super.key, this.onTap});

  @override
  State<FlashcardsSearchResults> createState() =>
      _FlashcardsSearchResultsState();
}

class _FlashcardsSearchResultsState extends State<FlashcardsSearchResults> {
  @override
  void initState() {
    super.initState();
    // context.read<FlashcardsSearcherBloc>().add(
    //   FlashcardsSearcherClaimsFetched(),
    // );
  }

  void _onTapHandler(AlgoliaFlashcard fc, bool? hasCards) {
    if (hasCards == null) {
      debugPrint(
        "User tried to open flashcard preview but the claims were not fetched",
      );
      return;
    }
    widget.onTap!(fc, hasCards);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlashcardsSearcherBloc, FlashcardsSearcherState>(
      builder: (context, state) {
        return PagedSliverList(
          state: state.pagingState,
          fetchNextPage: context.read<FlashcardsSearcherBloc>().fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate(
            invisibleItemsThreshold: 1,
            firstPageProgressIndicatorBuilder: (context) => PackShimmer(),
            noItemsFoundIndicatorBuilder:
                (context) => Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    "ما لقينا نتائج، جرّب تغيير البحث",
                  ),
                ),
            firstPageErrorIndicatorBuilder:
                (context) => ErrorScreen(
                  errorMessage: extractErrorMessage(state.pagingState.error!),
                  onReload:
                      context.read<FlashcardsSearcherBloc>().fetchNextPage,
                ),
            itemBuilder: (context, item, index) {
              final fc = item as AlgoliaFlashcard;

              return FlashcardPackCard(
                flashcard: fc,
                hasCards: state.hasCards,
                onTap:
                    widget.onTap != null
                        ? () => _onTapHandler(fc, state.hasCards)
                        : null,
              );
            },
          ),
        );
      },
    );
  }
}
