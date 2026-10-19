import 'package:flashcards/bloc/flashcards/bookmark_review/bookmark_review_event.dart';
import 'package:flashcards/bloc/flashcards/bookmark_review/bookmark_review_state.dart';
import 'package:flashcards/bloc/utils/utils.dart';
import 'package:flashcards/data/repositories/flashcards/fcp_repository.dart';
import 'package:flashcards/data/services/api/dto/flashcards/fcp_data/update_fcp_data/update_fcp_data_dto.dart';
import 'package:flashcards/domain/models/flashcards/bookmark/bookmark.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class BookmarkReviewBloc
    extends Bloc<BookmarkReviewEvent, BookmarkReviewState> {
  final FcpRepository _fcpRepo;
  final _pageSize = 10;

  BookmarkReviewBloc({required FcpRepository fcpRepo})
    : _fcpRepo = fcpRepo,
      super(BookmarkReviewState(pagingState: PagingState())) {
    on<BookmarkReviewPageFetched>(
      _onPageFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<BookmarkReviewAnswerToggled>(_onAnswerToggled);
    on<BookmarkReviewBookmarkRemoved>(_onBookmarkRemoved);
    on<BookmarkReviewBookmarkRemovalUndo>(_onBookmarkRemovalUndo);
    on<BookmarkReviewRefresh>(_onRefresh);
  }

  void _onRefresh(
    BookmarkReviewRefresh event,
    Emitter<BookmarkReviewState> emit,
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
    final result = await _fcpRepo.getBookmarkPage(
      pageSize: _pageSize,
      pageIndex: newKey,
    );
    switch (result) {
      case Error<List<Bookmark>>(:final error):
        event.completer?.completeError(error);
        emit(state.copyWith(error: error));
        return;
      case Ok<List<Bookmark>>():
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
    BookmarkReviewPageFetched event,
    Emitter<BookmarkReviewState> emit,
  ) async {
    final state = this.state;
    if (state.pagingState.isLoading) return;

    emit(
      state.copyWith(
        pagingState: state.pagingState.copyWith(isLoading: true, error: null),
      ),
    );

    final newKey = getNewKey(state.pagingState.keys);

    final bookmarksResult = await _fcpRepo.getBookmarkPage(
      pageIndex: newKey,
      pageSize: _pageSize,
    );
    switch (bookmarksResult) {
      case Error<List<Bookmark>>(:final error):
        emit(
          state.copyWith(pagingState: state.pagingState.copyWith(error: error)),
        );
        return;
      case Ok<List<Bookmark>>():
    }
    final bookmarks = bookmarksResult.value;

    Map<String, bool> visibleMap = {
      for (var el in bookmarks) el.flashcardId: false,
    };
    final isLastPage = calcIsLastPage(bookmarks);
    emit(
      state.copyWith(
        visibleAnswers: visibleMap,
        pagingState: state.pagingState.copyWith(
          isLoading: false,
          pages: [...?state.pagingState.pages, bookmarks],
          keys: [...?state.pagingState.keys, newKey],
          hasNextPage: !isLastPage,
        ),
      ),
    );
  }

  void _onAnswerToggled(
    BookmarkReviewAnswerToggled event,
    Emitter<BookmarkReviewState> emit,
  ) {
    final state = this.state;
    //if (state ) return;
    final bookmark = event.bookmark;
    final updatedMap = Map<String, bool>.from(state.visibleAnswers);
    updatedMap[bookmark.flashcardId] =
        updatedMap[bookmark.flashcardId] != null
            ? !updatedMap[bookmark.flashcardId]!
            : true;

    emit(state.copyWith(visibleAnswers: updatedMap));
  }

  void _onBookmarkRemoved(
    BookmarkReviewBookmarkRemoved event,
    Emitter<BookmarkReviewState> emit,
  ) async {
    final stateRef = state;
    if (stateRef.pagingState.isLoading) return;
    //if (stateRef is! BookmarkReviewSuccess) return;

    final bookmark = event.bookmark;

    // get page index and element index as tuple
    final pages = stateRef.pagingState.pages;
    if (pages == null) throw Exception("Pages is null");
    final indexes = getElementIndexInPages(
      pages,
      (element) => element.flashcardId == event.bookmark.flashcardId,
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

    // then call the db to remove that element from the database
    final removeResult = await _fcpRepo.removeBookmark(
      flashcardId: bookmark.flashcardId,
    );
    // final addResult = Result.error(Exception());
    // await Future.delayed(Duration(milliseconds: 3500));
    switch (removeResult) {
      case Ok<void>():
        final forbidden = stateRef.forbidRemoval;
        if (forbidden[bookmark.flashcardId] == true) {
          emit(
            stateRef.copyWith(
              forbidRemoval: updateMapEntry(
                forbidden,
                bookmark.flashcardId,
                false,
              ),
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
      bookmark,
      indexes,
    );

    // forbid removal of this bookmark, if undo fails as well
    final updatedForbid = state.forbidRemoval;
    emit(
      state.copyWith(
        pagingState: state.pagingState.copyWith(pages: updatedLatestPages),
        forbidRemoval: updateMapEntry(
          updatedForbid,
          bookmark.flashcardId,
          true,
        ),
      ),
    );
  }

  void _onBookmarkRemovalUndo(
    BookmarkReviewBookmarkRemovalUndo event,
    Emitter<BookmarkReviewState> emit,
  ) async {
    final stateRef = state;
    if (stateRef.pagingState.isLoading) return;
    //if (stateRef is! BookmarkReviewSuccess) return;
    final indexes = getMatrixIndexFromFlatIndex(event.index, _pageSize);
    final bookmark = event.bookmark;
    if (stateRef.pagingState.pages != null &&
        stateRef.pagingState.pages![indexes.$1].contains(bookmark)) {
      return;
    }

    emit(
      stateRef.copyWith(
        pagingState: stateRef.pagingState.copyWith(
          pages: insertElementIntoPage(
            stateRef.pagingState.pages ?? [],
            event.bookmark,
            indexes,
          ),
        ),
      ),
    );

    final updateDto = UpdateFcpDataDto(hasBookmark: true);

    final addResult = await _fcpRepo.updateFcpData(
      bookmark.flashcardId,
      updateDto,
    );
    // final addResult = Result.error(Exception());
    // await Future.delayed(Duration(milliseconds: 3500));
    switch (addResult) {
      case Ok<void>():
        return;
      case Error<void>():
    }

    // if remove failed, bookmark was added back, no need to revert
    final forbidden = state.forbidRemoval;
    if (forbidden[bookmark.flashcardId] == true) {
      emit(
        state.copyWith(
          forbidRemoval: updateMapEntry(forbidden, bookmark.flashcardId, false),
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
