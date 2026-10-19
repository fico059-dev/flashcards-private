import 'package:flashcards/bloc/reports/user_reports_getter/user_reports_getter_event.dart';
import 'package:flashcards/bloc/reports/user_reports_getter/user_reports_getter_state.dart';
import 'package:flashcards/bloc/utils/utils.dart';
import 'package:flashcards/data/repositories/flashcards/report_repository.dart';
import 'package:flashcards/domain/models/flashcards/reports/user_report/user_report.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class UserReportsGetterBloc
    extends Bloc<UserReportsGetterEvent, UserReportsGetterState> {
  final ReportRepository _reportRepo;
  final _pageSize = 20;

  UserReportsGetterBloc({
    required ReportRepository reportRepo,
    required String flashcardId,
  }) : _reportRepo = reportRepo,
       super(
         UserReportsGetterState(
           pagingState: PagingState(hasNextPage: false),
           flashcardId: flashcardId,
         ),
       ) {
    on<UserReportsGetterRefresh>(_onRefresh);
    on<UserReportsGetterFetched>(_onFetched);
  }

  void fetchNextPage() => add(UserReportsGetterFetched());

  void _onFetched(
    UserReportsGetterFetched event,
    Emitter<UserReportsGetterState> emit,
  ) async {
    if (state.pagingState.isLoading) return;

    emit(
      state.copyWith(
        pagingState: state.pagingState.copyWith(isLoading: true, error: null),
      ),
    );

    final newKey = getNewKey(state.pagingState.keys);

    final getResult = await _reportRepo.getUserReportsPage(
      flashcardId: state.flashcardId,
      pageIndex: newKey,
      pageSize: _pageSize,
    );
    switch (getResult) {
      case Error<List<UserReport>>(:final error):
        emit(
          state.copyWith(pagingState: state.pagingState.copyWith(error: error)),
        );
        return;
      case Ok<List<UserReport>>():
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
    UserReportsGetterRefresh event,
    Emitter<UserReportsGetterState> emit,
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
    final result = await _reportRepo.getUserReportsPage(
      flashcardId: state.flashcardId,
      pageSize: _pageSize,
      pageIndex: newKey,
    );
    switch (result) {
      case Error<List<UserReport>>(:final error):
        event.completer?.completeError(error);
        //emit(state.copyWith(pagingState: pagingState.copyWith(error: error)));
        return;
      case Ok<List<UserReport>>():
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
