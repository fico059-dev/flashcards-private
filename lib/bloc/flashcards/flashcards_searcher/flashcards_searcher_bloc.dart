import 'dart:async';

import 'package:flashcards/bloc/flashcards/flashcards_searcher/flashcards_searcher_event.dart';
import 'package:flashcards/bloc/flashcards/flashcards_searcher/flashcards_searcher_state.dart';
import 'package:flashcards/bloc/utils/utils.dart';
import 'package:flashcards/data/repositories/algolia_search/flashcards_searcher_repository.dart';
import 'package:flashcards/data/repositories/utils/user_claims.dart';
import 'package:flashcards/domain/models/algolia/algolia_flashcard/algolia_flashcard.dart';
import 'package:flashcards/domain/models/algolia/pack_search_result/search_result_with_tags.dart';
import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class FlashcardsSearcherBloc
    extends Bloc<FlashcardsSearcherEvent, FlashcardsSearcherState> {
  final FlashcardsSearcherRepository _flashcardsSearcherRepository;

  FlashcardsSearcherBloc({
    required FlashcardsSearcherRepository flashcardsSearcherRepository,
  }) : _flashcardsSearcherRepository = flashcardsSearcherRepository,
       super(
         FlashcardsSearcherState(pagingState: PagingState(hasNextPage: false)),
       ) {
    on<FlashcardsSearcherRequestSent>(
      _onRequestSent,
      transformer: debounce(debounceDuration),
    );
    on<FlashcardsSearcherNextPageRequested>(
      _onNextPageRequested,
      transformer: throttleDroppable(throttleDuration),
    );
    on<FlashcardsSearcherTagToggled>(_onTagToggled);
    on<FlashcardsSearcherPackAddedToState>(_onAdded);
    on<FlashcardsSearcherPackUpdatedInState>(_onUpdate);
    on<FlashcardsSearcherPackRemovedFromState>(_onRemove);
    // on<FlashcardsSearcherClaimsFetched>(_onClaimsFetched);
  }

  // void _onClaimsFetched(FlashcardsSearcherClaimsFetched event, Emitter<FlashcardsSearcherState> emit) async {
  //   final claims = await UserClaims.current();
  //   emit(state.copyWith(hasCards: claims.hasCards));
  // }

  void _onRemove(
    FlashcardsSearcherPackRemovedFromState event,
    Emitter<FlashcardsSearcherState> emit,
  ) {
    final pagingState = state.pagingState;
    if (state.status.isFetching || pagingState.isLoading) return;

    final pages = pagingState.pages;
    if (pages == null) return;

    final newPages = removeElementFromPage(
      pages,
      (element) => element.objectID == event.flashcardId,
    );

    emit(state.copyWith(pagingState: pagingState.copyWith(pages: newPages)));
  }

  void _onUpdate(
    FlashcardsSearcherPackUpdatedInState event,
    Emitter<FlashcardsSearcherState> emit,
  ) {
    final pagingState = state.pagingState;
    if (state.status.isFetching || pagingState.isLoading) return;

    final pages = pagingState.pages;
    if (pages == null) return;

    final newPages = updateElementInPage(
      pages,
      (element) => element.objectID == event.flashcardId,
      event.copyWith,
    );

    emit(state.copyWith(pagingState: pagingState.copyWith(pages: newPages)));
  }

  void _onAdded(
    FlashcardsSearcherPackAddedToState event,
    Emitter<FlashcardsSearcherState> emit,
  ) {
    final pagingState = state.pagingState;
    if (state.status.isFetching || pagingState.isLoading) return;

    final pages = pagingState.pages;
    late final List<List<AlgoliaFlashcard>> newPages;
    int? newKey;
    if (pages == null) {
      newKey = getNewKey(null, startFrom: 0);
      newPages = [
        [event.flashcard],
      ];
    } else {
      newPages = insertElementIntoPage(pagingState.pages!, event.flashcard, (
        0,
        0,
      ));
    }

    emit(
      state.copyWith(
        pagingState: pagingState.copyWith(
          pages: newPages,
          keys: newKey != null ? [newKey] : pagingState.keys,
        ),
      ),
    );
  }

  void fetchNextPage() => add(FlashcardsSearcherNextPageRequested());

  void _onNextPageRequested(
    FlashcardsSearcherNextPageRequested event,
    Emitter<FlashcardsSearcherState> emit,
  ) async {
    final pagingState = state.pagingState;
    if (pagingState.isLoading || state.status.isFetching) return;

    if (state.hasCards == null) {
      final claims = await UserClaims.current();
      emit(state.copyWith(hasCards: claims.hasCards));
    }

    emit(
      state.copyWith(
        status: FlashcardsSearcherStatus.fetching,
        pagingState: pagingState.copyWith(isLoading: true, error: null),
      ),
    );

    final newKey = getNewKey(pagingState.keys, startFrom: 0);

    //print("Fetching next page for key: $newKey");
    var result = await _flashcardsSearcherRepository.searchFlashcards(
      page: newKey,
      query: state.lastQuerySent,
      tags: state.selectedTagsList,
    );
    switch (result) {
      case Error<SearchResultWithTags<AlgoliaFlashcard>>(:final error):
        emit(
          state.copyWith(
            pagingState: pagingState.copyWith(error: error, isLoading: false),
          ),
        );
        return;
      case Ok<SearchResultWithTags<AlgoliaFlashcard>>():
    }
    final page = result.value;

    emit(
      state.copyWith(
        status: FlashcardsSearcherStatus.initial,
        hitsCount: page.hitCount,
        tagCounts: result.value.tagCounts,
        pagingState: updatePagingState(
          oldState: state.pagingState,
          newItems: page.hits,
          pageKey: page.pageKey,
          isLastPage: page.isLastPage,
        ),
      ),
    );
  }

  Future<void> _onRequestSent(
    FlashcardsSearcherRequestSent event,
    Emitter<FlashcardsSearcherState> emit,
  ) async {
    if (!state.status.isInitial) {
      event.completer?.completeError(
        Exception(
          "جارٍ تحميل المزيد. حاول التحديث بعد قليل.",
        ),
      );
      return;
    }

    if (state.hasCards == null) {
      final claims = await UserClaims.current();
      emit(state.copyWith(hasCards: claims.hasCards));
    }

    await _sendSearchRequestAndEmit(query: event.query, emit: emit);
  }

  void _onTagToggled(
    FlashcardsSearcherTagToggled event,
    Emitter<FlashcardsSearcherState> emit,
  ) async {
    if (!state.status.isInitial) {
      return;
    }

    final isSelected = _isSelected(event.tag);
    final newMap = Map.of(state.selectedTags);
    if (isSelected) {
      newMap.remove(event.tag);
    } else {
      newMap[event.tag] = !isSelected;
    }

    emit(state.copyWith(selectedTags: newMap));

    await _sendSearchRequestAndEmit(query: state.lastQuerySent, emit: emit);
  }

  /// I use this method because onTagToggled and onRequestSent need to send
  /// search request. The only difference is that onRequestSent uses debounce and
  /// that is why I can't call that event handler inside another event handler
  /// because it will debounce the request
  Future<void> _sendSearchRequestAndEmit({
    required String query,
    required Emitter<FlashcardsSearcherState> emit,
    Completer<void>? completer,
  }) async {
    final newKey = getNewKey(null, startFrom: 0);
    //print("Send new search query for key: $newKey");
    final result = await _flashcardsSearcherRepository.searchFlashcards(
      query: query,
      tags: state.selectedTagsList,
      page: newKey,
    );
    switch (result) {
      case Error<SearchResultWithTags<AlgoliaFlashcard>>(:final error):
        emit(
          state.copyWith(status: FlashcardsSearcherStatus.error, error: error),
        );
        return;
      case Ok<SearchResultWithTags<AlgoliaFlashcard>>():
    }
    //final newItems = result.value.packs;
    final page = result.value;
    emit(
      state.copyWith(
        status: FlashcardsSearcherStatus.initial,
        hitsCount: page.hitCount,
        lastQuerySent: query,
        tagCounts: result.value.tagCounts,
        pagingState: updatePagingState(
          oldState: state.pagingState,
          newItems: page.hits,
          pageKey: page.pageKey,
          isLastPage: page.isLastPage,
        ),
      ),
    );
    completer?.complete();
  }

  PagingState<int, T> updatePagingState<T>({
    required PagingState<int, T> oldState,
    required List<T> newItems,
    required int pageKey,
    required bool isLastPage,
  }) {
    final newPages = pageKey == 0 ? [newItems] : [...?oldState.pages, newItems];
    final newKeys = pageKey == 0 ? [pageKey] : [...?oldState.keys, pageKey];

    return oldState.copyWith(
      pages: newPages,
      keys: newKeys,
      hasNextPage: !isLastPage,
      isLoading: false,
      error: null,
    );
  }

  bool _isSelected(Tag tag) => state.selectedTags[tag] == true;
}
