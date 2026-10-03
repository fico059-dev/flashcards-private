import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/bookmark_review/bookmark_review_bloc.dart';
import 'package:flashcards/bloc/flashcards/bookmark_review/bookmark_review_event.dart';
import 'package:flashcards/bloc/flashcards/bookmark_review/bookmark_review_state.dart';
import 'package:flashcards/data/repositories/flashcards/fcp_repository.dart';
import 'package:flashcards/domain/models/flashcards/bookmark/bookmark.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/core/card_factory.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/flashcard/bookmarks/bookmark_card.dart';
import 'package:flashcards/ui/widgets/flashcard/bookmarks/bookmarks_shimmer.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

@RoutePage()
class ReviewBookmarkPage extends StatelessWidget {
  const ReviewBookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BookmarkReviewBloc(fcpRepo: context.read<FcpRepository>()),
      child: _BookmarkReviewView(),
    );
  }
}

/// The bookmarks list without its own app bar, for the Notebook tab.
class BookmarksList extends StatelessWidget {
  const BookmarksList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BookmarkReviewBloc(fcpRepo: context.read<FcpRepository>()),
      child: const _BookmarkReviewView(showAppBar: false),
    );
  }
}

class _BookmarkReviewView extends StatefulWidget {
  final bool showAppBar;

  const _BookmarkReviewView({this.showAppBar = true});

  @override
  State<_BookmarkReviewView> createState() => _BookmarkReviewViewState();
}

class _BookmarkReviewViewState extends State<_BookmarkReviewView> {
  void _fetchNextPage() {
    context.read<BookmarkReviewBloc>().add(BookmarkReviewPageFetched());
  }

  Future<void> _handleRefresh(BuildContext context) {
    final completer = Completer<void>();
    context.read<BookmarkReviewBloc>().add(
      BookmarkReviewRefresh(completer: completer),
    );

    return completer.future.catchError((error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(extractErrorMessage(error))));
    });
  }

  @override
  Widget build(BuildContext context) {
    void onUndo({
      required Bookmark bookmark,
      required int index,
      required bool isAnswerVisible,
    }) {
      context.read<BookmarkReviewBloc>().add(
        BookmarkReviewBookmarkRemovalUndo(
          bookmark: bookmark,
          index: index,
          isAnswerVisible: isAnswerVisible,
        ),
      );
    }

    return Scaffold(
      appBar: !widget.showAppBar
          ? null
          : AppBar(
              title: Text(
                AppLocalizations.of(context)!.reviewBookmarkPage_review,
              ),
              leading: IconButton(
                onPressed: () => context.router.pop(),
                icon: Icon(Icons.arrow_back),
              ),
            ),
      body: BlocBuilder<BookmarkReviewBloc, BookmarkReviewState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => _handleRefresh(context),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalScreenPadding,
                    ),
                    child: Column(
                      children: [
                        CardFactory.info(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!.reviewBookmarkPage_remove,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!.reviewBookmarkPage_swipe,
                          ),
                          closable: true,
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),

                PagedSliverList(
                  state: state.pagingState,
                  fetchNextPage: _fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate(
                    firstPageProgressIndicatorBuilder: (context) =>
                        BookmarksShimmer(),
                    noItemsFoundIndicatorBuilder: (context) =>
                        _EmptyListContainer(),
                    firstPageErrorIndicatorBuilder: (context) => ErrorScreen(
                      errorMessage: extractErrorMessage(
                        state.pagingState.error!,
                      ),
                      onReload: _fetchNextPage,
                    ),
                    itemBuilder: (context, item, index) {
                      //return BookmarksShimmer();
                      final bookmark = item as Bookmark;
                      final isVisible =
                          state.visibleAnswers[bookmark.flashcardId] ?? false;
                      return BookmarkCard(
                        key: ValueKey(bookmark.flashcardId),
                        index: index,
                        bookmark: bookmark,
                        isAnswerVisible: isVisible,
                        onUndo: onUndo,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyListContainer extends StatelessWidget {
  const _EmptyListContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/parrot_sad.png", height: 200),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.reviewBookmarkPage_noBookmarks,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
