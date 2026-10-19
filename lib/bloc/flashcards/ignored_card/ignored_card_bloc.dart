import 'package:flashcards/bloc/flashcards/ignored_card/ignored_card_event.dart';
import 'package:flashcards/bloc/flashcards/ignored_card/ignored_card_state.dart';
import 'package:flashcards/bloc/utils/utils.dart';
import 'package:flashcards/data/repositories/flashcards/fcp_repository.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/data/services/api/dto/flashcards/fcp_data/update_fcp_data/update_fcp_data_dto.dart';
import 'package:flashcards/domain/models/flashcards/ignored_flashcard/ignored_flashcard.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class IgnoredCardBloc extends Bloc<IgnoredCardEvent, IgnoredCardState> {
  final FcpRepository _fcpRepo;
  final PackRepository _packRepo;
  final int _pageSize = 10;

  IgnoredCardBloc({
    required FcpRepository fcpRepo,
    required PackRepository packRepo,
  }) : _fcpRepo = fcpRepo,
       _packRepo = packRepo,
       super(IgnoredCardState(pagingState: PagingState())) {
    on<IgnoredCardPageFetched>(
      _onPageFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<IgnoredCardUnignored>(_onUnignored);
    on<IgnoredCardUnignoreUndo>(_onUnignoreUndo);
    on<IgnoredCardRefresh>(_onRefresh);
  }

  void _onRefresh(
    IgnoredCardRefresh event,
    Emitter<IgnoredCardState> emit,
  ) async {
    final state = this.state;
    final pagingState = state.pagingState;
    if (pagingState.isLoading) {
      event.completer?.completeError(
        Exception(
          "جارٍ تحميل المزيد. حاول التحديث بعد قليل.",
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        pagingState: pagingState.copyWith(
          isLoading: true,
          hasNextPage: false,
          error: null,
        ),
      ),
    );

    final newKey = getNewKey(null);
    final result = await _fcpRepo.getIgnoredFlashcardsPage(
      pageSize: _pageSize,
      pageIndex: newKey,
    );
    switch (result) {
      case Error<List<IgnoredFlashcard>>(:final error):
        event.completer?.completeError(error);
        emit(state.copyWith(error: error));
        return;
      case Ok<List<IgnoredFlashcard>>():
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

  void _onPageFetched(
    IgnoredCardPageFetched event,
    Emitter<IgnoredCardState> emit,
  ) async {
    if (state.pagingState.isLoading) return;

    emit(
      state.copyWith(
        pagingState: state.pagingState.copyWith(isLoading: true, error: null),
      ),
    );

    final newKey = getNewKey(state.pagingState.keys);

    final loadResult = await _fcpRepo.getIgnoredFlashcardsPage(
      pageIndex: newKey,
      pageSize: _pageSize,
    );
    switch (loadResult) {
      case Error<List<IgnoredFlashcard>>(:final error):
        emit(
          state.copyWith(pagingState: state.pagingState.copyWith(error: error)),
        );
        return;
      case Ok<List<IgnoredFlashcard>>():
    }
    final ignoredCards = loadResult.value;
    final isLastPage = calcIsLastPage(ignoredCards);

    emit(
      state.copyWith(
        pagingState: state.pagingState.copyWith(
          isLoading: false,
          pages: [...?state.pagingState.pages, ignoredCards],
          keys: [...?state.pagingState.keys, newKey],
          hasNextPage: !isLastPage,
        ),
      ),
    );
  }

  void _onUnignored(
    IgnoredCardUnignored event,
    Emitter<IgnoredCardState> emit,
  ) async {
    final stateRef = state;
    if (state.pagingState.isLoading) return;

    //if (stateRef is! IgnoredCardSuccess) return;
    final card = event.ignoredCard;

    final pages = stateRef.pagingState.pages;
    if (pages == null) throw Exception("Pages is null");

    // get page index and element index as tuple
    final indexes = getElementIndexInPages(
      pages,
      (element) => element.flashcardId == card.flashcardId,
    );
    if (indexes == null) throw Exception("Element not found");

    // optimistic UI update -> emit state as if the element is removed
    // successfully
    emit(
      stateRef.copyWith(
        pagingState: stateRef.pagingState.copyWith(
          pages: removeElementFromPagesAt(pages, indexes),
        ),
      ),
    );

    final removeResult = await _fcpRepo.unignoreFlashcard(
      flashcardId: card.flashcardId,
    );
    switch (removeResult) {
      case Ok<void>():
        final forbidden = state.forbidRemoval;
        if (forbidden[card.flashcardId] == true) {
          emit(
            state.copyWith(
              forbidRemoval: updateMapEntry(forbidden, card.flashcardId, false),
            ),
          );
        }
        return;
      case Error<void>():
    }

    // revert if error
    final latestPages = state.pagingState.pages ?? [];
    final updatedLatestPages = insertElementIntoPage(
      latestPages,
      card,
      indexes,
    );

    // forbid removal of this card, if undo fails as well
    final updatedForbid = state.forbidRemoval;
    emit(
      state.copyWith(
        pagingState: state.pagingState.copyWith(pages: updatedLatestPages),
        forbidRemoval: updateMapEntry(updatedForbid, card.flashcardId, true),
      ),
    );
  }

  void _onUnignoreUndo(
    IgnoredCardUnignoreUndo event,
    Emitter<IgnoredCardState> emit,
  ) async {
    final stateRef = state;
    if (state.pagingState.isLoading) return;

    //if (stateRef is! IgnoredCardSuccess) return;
    final indexes = getMatrixIndexFromFlatIndex(event.index, _pageSize);
    final card = event.ignoredCard;
    if (stateRef.pagingState.pages != null &&
        stateRef.pagingState.pages![indexes.$1].contains(card)) {
      return;
    }

    emit(
      stateRef.copyWith(
        pagingState: stateRef.pagingState.copyWith(
          pages: insertElementIntoPage(
            stateRef.pagingState.pages ?? [],
            card,
            indexes,
          ),
        ),
      ),
    );

    final updateDto = UpdateFcpDataDto(ignored: true);
    final addResult = await _fcpRepo.updateFcpData(card.flashcardId, updateDto);
    switch (addResult) {
      case Ok<void>():
        return;
      case Error<void>():
    }

    // if remove failed, card was added back, no need to revert
    final forbidden = state.forbidRemoval;
    if (forbidden[card.flashcardId] == true) {
      emit(
        state.copyWith(
          forbidRemoval: updateMapEntry(forbidden, card.flashcardId, false),
        ),
      );
      return;
    }

    // revert changes
    final latestPages = state.pagingState.pages;
    if (latestPages == null) return;

    final updatedLatestPages = removeElementFromPagesAt(latestPages, indexes);
    emit(
      state.copyWith(
        pagingState: state.pagingState.copyWith(pages: updatedLatestPages),
      ),
    );
  }
}
