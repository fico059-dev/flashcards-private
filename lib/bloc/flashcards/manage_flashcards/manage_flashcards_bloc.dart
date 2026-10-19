import 'package:flashcards/bloc/flashcards/manage_flashcards/manage_flashcards_event.dart';
import 'package:flashcards/bloc/flashcards/manage_flashcards/manage_flashcards_state.dart';
import 'package:flashcards/bloc/utils/utils.dart';
import 'package:flashcards/data/repositories/flashcards/flashcard_repository.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ManageFlashcardsBloc
    extends Bloc<ManageFlashcardsEvent, ManageFlashcardsState> {
  final FlashcardRepository _flashcardRepo;
  final int _pageSize = 10;
  var _isFirstLoad = true;

  ManageFlashcardsBloc({required FlashcardRepository flashcardRepo})
    : _flashcardRepo = flashcardRepo,
      super(
        ManageFlashcardsState(pagingState: PagingState(hasNextPage: false)),
      ) {
    on<ManageFlashcardPageFetched>(
      _onPageFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ManageFlashcardCacheRead>(_onCacheRead);
    on<ManageFlashcardRefresh>(_onRefresh);
  }

  void fetchNextPage(String packId) {
    if (_isFirstLoad) {
      add(ManageFlashcardCacheRead(packId: packId));
      _isFirstLoad = false;
    } else {
      add(ManageFlashcardPageFetched(packId: packId));
    }
  }

  void _onRefresh(
    ManageFlashcardRefresh event,
    Emitter<ManageFlashcardsState> emit,
  ) async {
    final state = this.state;
    final pagingState = state.pagingState;
    if (pagingState.isLoading || state.status.isLoading) {
      event.completer?.completeError(
        Exception(
          "جارٍ تحميل المزيد. حاول التحديث بعد قليل.",
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: ManageFlashcardsLoadedStatus.initial,
        pagingState: pagingState.copyWith(
          isLoading: true,
          hasNextPage: false,
          error: null,
        ),
      ),
    );

    final newKey = getNewKey(null);
    final result = await _flashcardRepo.refreshFlashcardAndFetchFirstPage(
      packId: event.packId,
      pageSize: _pageSize,
      firstPageIndex: newKey,
    );
    switch (result) {
      case Error<List<Flashcard>>(:final error):
        event.completer?.completeError(error);
        emit(state.copyWith(error: error));
        return;
      case Ok<List<Flashcard>>():
    }
    final newItems = result.value;

    emit(
      state.copyWith(
        pagingState: pagingState.copyWith(
          isLoading: false,
          hasNextPage: !calcIsLastPage(newItems),
          pages: [newItems],
          keys: [newKey],
        ),
      ),
    );
    event.completer?.complete();
  }

  void _onCacheRead(
    ManageFlashcardCacheRead event,
    Emitter<ManageFlashcardsState> emit,
  ) {
    final state = this.state;
    final pagingState = state.pagingState;
    if (pagingState.isLoading) return;

    emit(
      state.copyWith(
        status: ManageFlashcardsLoadedStatus.initial,
        pagingState: pagingState.copyWith(isLoading: true, error: null),
      ),
    );

    List<List<Flashcard>>? pages;
    List<int>? keys;
    List<Flashcard>? newItems;
    while (true) {
      final newKey = getNewKey(keys);
      newItems = _flashcardRepo.getFlashcardPageFromCache(
        packId: event.packId,
        pageIndex: newKey,
      );
      if (newItems == null) break;
      pages = [...?pages, newItems];
      keys = [...?keys, newKey];
    }

    emit(
      state.copyWith(
        status: ManageFlashcardsLoadedStatus.initial,
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
    ManageFlashcardPageFetched event,
    Emitter<ManageFlashcardsState> emit,
  ) async {
    final state = this.state;
    final pagingState = state.pagingState;
    if (pagingState.isLoading) return;

    emit(
      state.copyWith(
        status: ManageFlashcardsLoadedStatus.initial,
        pagingState: pagingState.copyWith(isLoading: true, error: null),
      ),
    );

    final newKey = getNewKey(pagingState.keys);
    final result = await _flashcardRepo.getFlashcardPage(
      packId: event.packId,
      pageIndex: newKey,
      pageSize: _pageSize,
    );
    switch (result) {
      case Error<List<Flashcard>>(:final error):
        emit(state.copyWith(pagingState: pagingState.copyWith(error: error)));
        return;
      case Ok<List<Flashcard>>():
    }
    final newItems = result.value;
    final isLastPage = calcIsLastPage(newItems);

    emit(
      state.copyWith(
        pagingState: pagingState.copyWith(
          keys: [...?pagingState.keys, newKey],
          pages: [...?pagingState.pages, newItems],
          hasNextPage: !isLastPage,
          isLoading: false,
        ),
      ),
    );
  }
}
