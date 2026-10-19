import 'package:flashcards/bloc/pack/started_packs/started_packs_event.dart';
import 'package:flashcards/bloc/pack/started_packs/started_packs_state.dart';
import 'package:flashcards/bloc/utils/utils.dart';
import 'package:flashcards/data/repositories/flashcards/pp_repository.dart';
import 'package:flashcards/domain/models/flashcards/pack_progress/pack_progress.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class StartedPacksBloc extends Bloc<StartedPacksEvent, StartedPacksState> {
  final PpRepository _ppRepo;
  final _pageSize = 10;

  StartedPacksBloc({required PpRepository ppRepo})
    : _ppRepo = ppRepo,
      super(StartedPacksState(pagingState: PagingState(hasNextPage: false))) {
    on<StartedPacksFetched>(
      _onStartedPacksFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<StartedPacksProgressDeleted>(_onStartedPacksProgressDeleted);
    on<StartedPacksRefresh>(_onRefresh);
  }

  void _onRefresh(
    StartedPacksRefresh event,
    Emitter<StartedPacksState> emit,
  ) async {
    final state = this.state;
    final pagingState = state.pagingState;
    if (pagingState.isLoading || state.status.isResettingProgress) {
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
    final result = await _ppRepo.getPacksProgressForProfilePagination(
      pageSize: _pageSize,
      pageIndex: newKey,
    );
    switch (result) {
      case Error<List<PackProgress>>(:final error):
        event.completer?.completeError(error);
        emit(state.copyWith(error: error));
        return;
      case Ok<List<PackProgress>>():
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

  void _onStartedPacksProgressDeleted(
    StartedPacksProgressDeleted event,
    Emitter<StartedPacksState> emit,
  ) async {
    final stateRef = state;
    if (stateRef.status.isResettingProgress || stateRef.pagingState.isLoading) {
      return;
    }
    emit(
      stateRef.copyWith(
        status: StartedPacksLoadedStatus.resettingProgress,
        error: null,
      ),
    );

    final deleteResult = await _ppRepo.deletePackProgress(
      event.packProgress.packId,
    );
    switch (deleteResult) {
      case Error<void>(:final error):
        emit(
          stateRef.copyWith(
            status: StartedPacksLoadedStatus.error,
            error: error,
          ),
        );
        return;
      case Ok<void>():
    }

    final pages = stateRef.pagingState.pages;

    emit(
      stateRef.copyWith(
        status: StartedPacksLoadedStatus.resetSuccessful,
        pagingState:
            pages != null
                ? stateRef.pagingState.copyWith(
                  pages: removeElementFromPage(
                    pages,
                    (element) => element.packId == event.packProgress.packId,
                  ),
                )
                : stateRef.pagingState,
      ),
    );
  }

  void _onStartedPacksFetched(
    StartedPacksFetched event,
    Emitter<StartedPacksState> emit,
  ) async {
    if (state.pagingState.isLoading) return;

    emit(
      state.copyWith(
        pagingState: state.pagingState.copyWith(isLoading: true, error: null),
      ),
    );

    final newKey = getNewKey(state.pagingState.keys);

    final getResult = await _ppRepo.getPacksProgressForProfilePagination(
      pageIndex: newKey,
      pageSize: _pageSize,
    );
    switch (getResult) {
      case Error<List<PackProgress>>(:final error):
        emit(
          state.copyWith(pagingState: state.pagingState.copyWith(error: error)),
        );
        return;
      case Ok<List<PackProgress>>():
    }

    final items = getResult.value;

    emit(
      state.copyWith(
        pagingState: state.pagingState.copyWith(
          isLoading: false,
          pages: [...?state.pagingState.pages, items],
          hasNextPage: !calcIsLastPage(items),
          keys: [...?state.pagingState.keys, newKey],
        ),
      ),
    );
  }
}
