import 'package:flashcards/bloc/reports/fc_reports_getter/fc_reports_getter_event.dart';
import 'package:flashcards/bloc/reports/fc_reports_getter/fc_reports_getter_state.dart';
import 'package:flashcards/bloc/utils/utils.dart';
import 'package:flashcards/data/repositories/flashcards/report_repository.dart';
import 'package:flashcards/domain/models/flashcards/reports/flashcard_report/flashcard_report.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class FcReportsGetterBloc
    extends Bloc<FcReportsGetterEvent, FcReportsGetterState> {
  final ReportRepository _reportRepo;
  final _pageSize = 20;

  FcReportsGetterBloc({required ReportRepository reportRepo})
    : _reportRepo = reportRepo,
      super(
        FcReportsGetterState(pagingState: PagingState(hasNextPage: false)),
      ) {
    on<FcReportsGetterRefresh>(_onRefresh);
    on<FcReportsGetterFetched>(_onFetched);
  }

  void fetchNextPage() => add(FcReportsGetterFetched());

  void _onFetched(
    FcReportsGetterFetched event,
    Emitter<FcReportsGetterState> emit,
  ) async {
    if (state.pagingState.isLoading) return;

    if (!event.restart) {
      emit(
        state.copyWith(
          pagingState: state.pagingState.copyWith(isLoading: true, error: null),
        ),
      );
    } else {
      emit(
        state.copyWith(
          pagingState: PagingState(
            hasNextPage: false,
            isLoading: true,
            error: null,
          ),
        ),
      );
    }

    final newKey = getNewKey(event.restart ? null : state.pagingState.keys);

    final getResult = await _reportRepo.getFlashcardReportsPage(
      pageIndex: newKey,
      pageSize: _pageSize,
    );
    switch (getResult) {
      case Error<List<FlashcardReport>>(:final error):
        emit(
          state.copyWith(pagingState: state.pagingState.copyWith(error: error)),
        );
        return;
      case Ok<List<FlashcardReport>>():
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

  void _onRefresh(
    FcReportsGetterRefresh event,
    Emitter<FcReportsGetterState> emit,
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
    final result = await _reportRepo.getFlashcardReportsPage(
      pageSize: _pageSize,
      pageIndex: newKey,
    );
    switch (result) {
      case Error<List<FlashcardReport>>(:final error):
        event.completer?.completeError(error);
        //emit(state.copyWith(pagingState: pagingState.copyWith(error: error)));
        return;
      case Ok<List<FlashcardReport>>():
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
}
