import 'package:flashcards/bloc/custom_session/custom_session_getter/custom_session_getter_event.dart';
import 'package:flashcards/bloc/custom_session/custom_session_getter/custom_session_getter_state.dart';
import 'package:flashcards/bloc/utils/utils.dart';
import 'package:flashcards/data/repositories/flashcards/custom_session_repository.dart';
import 'package:flashcards/data/repositories/utils/user_claims.dart';
import 'package:flashcards/domain/models/flashcards/custom_session_summary/custom_session_summary.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CustomSessionGetterBloc
    extends Bloc<CustomSessionGetterEvent, CustomSessionGetterState> {
  final CustomSessionRepository _sessionRepo;
  final int _pageSize = 15;

  CustomSessionGetterBloc({required CustomSessionRepository sessionRepo})
    : _sessionRepo = sessionRepo,
      super(
        CustomSessionGetterState(pagingState: PagingState(hasNextPage: false)),
      ) {
    on<CustomSessionGetterStateReset>(_onStateReset);
    on<CustomSessionGetterRefresh>(_onRefresh);
    on<CustomSessionGetterPageFetched>(
      _onPageFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<CustomSessionGetterDelete>(_onDelete);
    on<CustomSessionGetterReset>(_onReset);
    on<CustomSessionGetterRename>(_onRename);
  }

  void _onStateReset(
    CustomSessionGetterStateReset event,
    Emitter<CustomSessionGetterState> emit,
  ) {
    emit(
      CustomSessionGetterState(pagingState: PagingState(hasNextPage: false)),
    );
  }

  void _onDelete(
    CustomSessionGetterDelete event,
    Emitter<CustomSessionGetterState> emit,
  ) async {
    final pagingState = state.pagingState;
    if (state.status.isActionLoading || pagingState.isLoading) return;

    emit(
      state.copyWith(
        status: CustomSessionGetterStatus.actionLoading,
        error: null,
      ),
    );

    final result = await _sessionRepo.deleteSession(event.sessionId);
    switch (result) {
      case Error<void>(:final error):
        emit(
          state.copyWith(
            status: CustomSessionGetterStatus.actionError,
            error: error,
          ),
        );
        return;
      case Ok<void>():
    }

    final pages = pagingState.pages;
    var newPages = pages;
    if (pages != null) {
      newPages = removeElementFromPage(
        pages,
        (element) => element.id == event.sessionId,
      );
    }

    emit(
      state.copyWith(
        status: CustomSessionGetterStatus.deleteSuccessful,
        pagingState: pagingState.copyWith(pages: newPages),
      ),
    );
  }

  void _onReset(
    CustomSessionGetterReset event,
    Emitter<CustomSessionGetterState> emit,
  ) async {
    if (state.status.isActionLoading || state.pagingState.isLoading) return;

    emit(
      state.copyWith(
        status: CustomSessionGetterStatus.actionLoading,
        error: null,
      ),
    );

    final result = await _sessionRepo.resetSessionProgress(event.sessionId);
    switch (result) {
      case Error<void>(:final error):
        emit(
          state.copyWith(
            status: CustomSessionGetterStatus.actionError,
            error: error,
          ),
        );
        return;
      case Ok<void>():
    }

    final pages = state.pagingState.pages;
    var newPages = pages;
    if (pages != null) {
      newPages = updateElementInPage(
        pages,
        (element) => element.id == event.sessionId,
        (element) => element.copyWith(currentIndex: 0, correctCount: 0),
      );
    }

    emit(
      state.copyWith(
        status: CustomSessionGetterStatus.resetSuccessful,
        pagingState: state.pagingState.copyWith(pages: newPages),
      ),
    );
  }

  void _onRename(
    CustomSessionGetterRename event,
    Emitter<CustomSessionGetterState> emit,
  ) async {
    if (state.status.isActionLoading || state.pagingState.isLoading) return;

    emit(
      state.copyWith(
        status: CustomSessionGetterStatus.actionLoading,
        error: null,
      ),
    );

    final result = await _sessionRepo.renameSession(
      event.sessionId,
      event.name,
    );
    switch (result) {
      case Error<String>(:final error):
        emit(
          state.copyWith(
            status: CustomSessionGetterStatus.actionError,
            error: error,
          ),
        );
        return;
      case Ok<String>():
    }

    final pages = state.pagingState.pages;
    var newPages = pages;
    if (pages != null) {
      newPages = updateElementInPage(
        pages,
        (element) => element.id == event.sessionId,
        (element) => element.copyWith(name: result.value),
      );
    }

    emit(
      state.copyWith(
        status: CustomSessionGetterStatus.renameSuccessful,
        pagingState: state.pagingState.copyWith(pages: newPages),
      ),
    );
  }

  void fetchNextPage() {
    add(CustomSessionGetterPageFetched());
  }

  void _onRefresh(
    CustomSessionGetterRefresh event,
    Emitter<CustomSessionGetterState> emit,
  ) async {
    final pagingState = state.pagingState;
    if (state.status.isActionLoading || pagingState.isLoading) {
      event.completer?.completeError(
        Exception(
          "Still loading more content. Please try refreshing again shortly.",
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: CustomSessionGetterStatus.initial,
        pagingState: pagingState.copyWith(
          isLoading: true,
          hasNextPage: false,
          error: null,
        ),
        error: null,
      ),
    );

    final newKey = getNewKey(null);
    final result = await _sessionRepo.getCustomSessionPage(
      pageSize: _pageSize,
      pageIndex: newKey,
    );
    switch (result) {
      case Error<List<CustomSessionSummary>>(:final error):
        event.completer?.completeError(error);
        emit(state.copyWith(pagingState: pagingState.copyWith(error: error)));
        return;
      case Ok<List<CustomSessionSummary>>():
    }
    final newItems = result.value;

    emit(
      state.copyWith(
        status: CustomSessionGetterStatus.initial,
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
    CustomSessionGetterPageFetched event,
    Emitter<CustomSessionGetterState> emit,
  ) async {
    final pagingState = state.pagingState;
    if (state.status.isActionLoading || pagingState.isLoading) return;

    if (state.hasCards == null) {
      final claims = await UserClaims.current();
      emit(state.copyWith(hasCards: claims.hasCards));
    }

    emit(
      state.copyWith(
        status: CustomSessionGetterStatus.initial,
        pagingState: pagingState.copyWith(isLoading: true, error: null),
        error: null,
      ),
    );

    final newKey = getNewKey(pagingState.keys);
    final result = await _sessionRepo.getCustomSessionPage(
      pageIndex: newKey,
      pageSize: _pageSize,
    );
    switch (result) {
      case Error<List<CustomSessionSummary>>(:final error):
        emit(state.copyWith(pagingState: pagingState.copyWith(error: error)));
        return;
      case Ok<List<CustomSessionSummary>>():
    }
    final items = result.value;

    emit(
      state.copyWith(
        status: CustomSessionGetterStatus.initial,
        pagingState: pagingState.copyWith(
          keys: [...?pagingState.keys, newKey],
          isLoading: false,
          pages: [...?pagingState.pages, items],
          hasNextPage: !calcIsLastPage(items),
        ),
      ),
    );
  }
}
