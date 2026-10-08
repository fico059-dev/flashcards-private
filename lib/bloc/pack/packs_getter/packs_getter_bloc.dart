import 'package:flashcards/bloc/pack/packs_getter/packs_getter_event.dart';
import 'package:flashcards/bloc/pack/packs_getter/packs_getter_state.dart';
import 'package:flashcards/bloc/utils/utils.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/data/repositories/utils/user_claims.dart';
import 'package:flashcards/domain/models/flashcards/pack/pack.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PacksGetterBloc extends Bloc<PacksGetterEvent, PacksGetterState> {
  final PackRepository _packRepository;
  // Large pages: sub-packs are shown inside their pack, so the whole list
  // is loaded.
  final int _pageSize = 50;

  PacksGetterBloc({required PackRepository packRepository})
    : _packRepository = packRepository,
      super(PacksGetterState(pagingState: PagingState(hasNextPage: false))) {
    on<PacksGetterPageFetched>(
      _onPageFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<PacksGetterCacheRead>(_onCacheRead);
    on<PacksGetterRefresh>(_onRefresh);
    // on<PacksGetterClaimsFetched>(_onClaimsFetched);
  }

  void fetchNextPage() => add(PacksGetterPageFetched());

  // void _onClaimsFetched(
  //   PacksGetterClaimsFetched event,
  //   Emitter<PacksGetterState> emit,
  // ) async {
  //   // // this is loading state for claims :))
  //   // emit(state.copyWith(hasCards: null));
  //
  //   final claims = await UserClaims.current();
  //   emit(state.copyWith(hasCards: claims.hasCards));
  // }

  Future<void> _onRefresh(
    PacksGetterRefresh event,
    Emitter<PacksGetterState> emit,
  ) async {
    final pagingState = state.pagingState;
    if (pagingState.isLoading) {
      event.completer?.completeError(
        Exception(
          "Still loading more content. Please try refreshing again shortly.",
        ),
      );
      return;
    }
    // // we also refresh the claims as well, why not
    // add(PacksGetterClaimsFetched());

    emit(
      state.copyWith(
        pagingState: pagingState.copyWith(isLoading: true, hasNextPage: false),
      ),
    );

    final newKey = getNewKey(null);
    final result = await _packRepository.refreshPacksAndFetchFirstPage(
      pageSize: _pageSize,
      firstPageIndex: newKey,
    );

    switch (result) {
      case Error<List<Pack>>(:final error):
        emit(state.copyWith(pagingState: pagingState.copyWith(error: error)));
        event.completer?.completeError(error);
        return;
      case Ok<List<Pack>>():
    }

    emit(
      state.copyWith(
        pagingState: pagingState.copyWith(
          keys: [newKey],
          pages: [result.value],
          hasNextPage: !calcIsLastPage(result.value),
          isLoading: false,
        ),
      ),
    );
    event.completer?.complete();
  }

  void _onCacheRead(
    PacksGetterCacheRead event,
    Emitter<PacksGetterState> emit,
  ) {
    final pagingState = state.pagingState;
    if (pagingState.isLoading) return;
    emit(state.copyWith(pagingState: pagingState.copyWith(isLoading: true)));

    List<List<Pack>>? pages;
    List<int>? keys;
    List<Pack>? newItems;
    while (true) {
      final newKey = getNewKey(keys);
      newItems = _packRepository.getPackPageFromCache(newKey);
      if (newItems == null) break;

      pages = [...?pages, newItems];
      keys = [...?keys, newKey];
    }

    emit(
      state.copyWith(
        pagingState: pagingState.copyWith(
          hasNextPage: true,
          keys: keys,
          pages: pages,
          isLoading: false,
          error: null,
        ),
      ),
    );
  }

  void _onPageFetched(
    PacksGetterPageFetched event,
    Emitter<PacksGetterState> emit,
  ) async {
    final pagingState = state.pagingState;
    if (pagingState.isLoading) return;

    emit(
      state.copyWith(
        pagingState: pagingState.copyWith(isLoading: true, error: null),
      ),
    );

    if (state.hasCards == null) {
      final claims = await UserClaims.current();
      emit(state.copyWith(hasCards: claims.hasCards));
    }

    final newKey = getNewKey(pagingState.keys);

    var result = await _packRepository.getPackPage(
      pageIndex: newKey,
      pageSize: _pageSize,
    );
    switch (result) {
      case Error<List<Pack>>(:final error):
        emit(
          state.copyWith(
            pagingState: pagingState.copyWith(error: error, isLoading: false),
          ),
        );
        return;
      case Ok<List<Pack>>():
    }
    final newItems = result.value;
    final isLastPage = calcIsLastPage(newItems);

    emit(
      state.copyWith(
        pagingState: pagingState.copyWith(
          pages: [...?pagingState.pages, newItems],
          keys: [...?pagingState.keys, newKey],
          hasNextPage: !isLastPage,
          isLoading: false,
        ),
      ),
    );
  }
}
