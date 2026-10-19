import 'package:flashcards/bloc/pack/admin_packs_getter/admin_packs_getter_event.dart';
import 'package:flashcards/bloc/utils/utils.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class AdminPacksGetterBloc
    extends Bloc<AdminPacksGetterEvent, PagingState<int, AdminPack>> {
  final PackRepository _packRepo;
  final int _pageSize = 15;
  bool _isFirstLoad = true;

  AdminPacksGetterBloc({required PackRepository packRepo})
    : _packRepo = packRepo,
      super(PagingState(hasNextPage: false)) {
    on<AdminPacksGetterPageFetched>(
      _onPageFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<AdminPacksGetterCacheRead>(_onCacheRead);
    on<AdminPacksGetterRefresh>(_onRefresh);
  }

  void _onRefresh(
    AdminPacksGetterRefresh event,
    Emitter<PagingState<int, AdminPack>> emit,
  ) async {
    if (state.isLoading) {
      event.completer?.completeError(
        Exception(
          "جارٍ تحميل المزيد. حاول التحديث بعد قليل.",
        ),
      );
      return;
    }
    emit(state.copyWith(isLoading: true, hasNextPage: false, error: null));

    final newKey = getNewKey(null);
    final result = await _packRepo.refreshAdminPacksAndFetchFirstPage(
      pageSize: _pageSize,
      firstPageIndex: newKey,
    );
    switch (result) {
      case Error<List<AdminPack>>(:final error):
        event.completer?.completeError(error);
        emit(state.copyWith(error: error));
        return;
      case Ok<List<AdminPack>>():
    }
    final newItems = result.value;

    emit(
      state.copyWith(
        isLoading: false,
        hasNextPage: !calcIsLastPage(newItems),
        pages: [newItems],
        keys: [newKey],
      ),
    );
    event.completer?.complete();
  }

  void fetchNextPage() {
    if (_isFirstLoad) {
      add(AdminPacksGetterCacheRead());
      _isFirstLoad = false;
    } else {
      add(AdminPacksGetterPageFetched());
    }
  }

  void _onCacheRead(
    AdminPacksGetterCacheRead event,
    Emitter<PagingState<int, AdminPack>> emit,
  ) {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true));

    List<List<AdminPack>>? pages;
    List<int>? keys;
    List<AdminPack>? newItems;
    while (true) {
      final newKey = getNewKey(keys);
      newItems = _packRepo.getAdminPackPageFromCache(newKey);
      if (newItems == null) break;

      pages = [...?pages, newItems];
      keys = [...?keys, newKey];
    }

    emit(
      state.copyWith(
        hasNextPage: true,
        keys: keys,
        pages: pages,
        isLoading: false,
        error: null,
      ),
    );
  }

  void _onPageFetched(
    AdminPacksGetterPageFetched event,
    Emitter<PagingState<int, AdminPack>> emit,
  ) async {
    final state = this.state;
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, error: null));

    final newKey = getNewKey(state.keys);
    final result = await _packRepo.getAdminPackPage(
      pageIndex: newKey,
      pageSize: _pageSize,
    );
    switch (result) {
      case Error<List<AdminPack>>(:final error):
        emit(state.copyWith(error: error));
        return;
      case Ok<List<AdminPack>>():
    }
    final items = result.value;

    emit(
      state.copyWith(
        keys: [...?state.keys, newKey],
        isLoading: false,
        pages: [...?state.pages, items],
        hasNextPage: !calcIsLastPage(items),
      ),
    );
  }
}
