import 'package:flashcards/domain/models/flashcards/card_markup/card_markup.dart';
import 'package:flashcards/bloc/flashcards/bookmark_review/bookmark_review_bloc.dart';
import 'package:flashcards/bloc/flashcards/bookmark_review/bookmark_review_event.dart';
import 'package:flashcards/data/mappers/fsrs_mapper.dart';
import 'package:flashcards/domain/models/flashcards/bookmark/bookmark.dart';
import 'package:flashcards/domain/models/flashcards/card_info_item/card_info_item.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/flashcard/fsrs_card_items/card_meta_row_full_width.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:swipeable_tile/swipeable_tile.dart';

class BookmarkCard extends StatefulWidget {
  final int index;
  final bool isAnswerVisible;
  final Bookmark bookmark;
  final void Function({
    required Bookmark bookmark,
    required int index,
    required bool isAnswerVisible,
  })
  onUndo;

  const BookmarkCard({
    super.key,
    required this.index,
    required this.bookmark,
    required this.isAnswerVisible,
    required this.onUndo,
  });

  @override
  State<BookmarkCard> createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<BookmarkCard> {
  double? minHeight;

  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? box =
          _textKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        setState(() {
          minHeight = box.size.height;
        });
      }
    });
  }

  void _toggle() {
    context.read<BookmarkReviewBloc>().add(
      BookmarkReviewAnswerToggled(bookmark: widget.bookmark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.bookmark.fsrsCard;

    void showSuccessSnackBar() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"${widget.bookmark.question}"',
                style: const TextStyle(fontStyle: FontStyle.italic),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Text('removed from bookmarks'),
            ],
          ),
          action: SnackBarAction(
            label: "Undo",
            onPressed: () => widget.onUndo(
              bookmark: widget.bookmark,
              isAnswerVisible: widget.isAnswerVisible,
              index: widget.index,
            ),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }

    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: !widget.isAnswerVisible
          ? context.colors.onPrimaryContainer
          : context.colors.onSecondaryContainer,
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: SwipeableTile.card(
        shadow: BoxShadow(color: context.colors.error),
        borderRadius: 12,
        horizontalPadding: horizontalScreenPadding,
        verticalPadding: 7,
        key: widget.key!,
        color: Colors.transparent,
        swipeThreshold: 0.4,
        direction: SwipeDirection.endToStart,
        onSwiped: (direction) {
          context.read<BookmarkReviewBloc>().add(
            BookmarkReviewBookmarkRemoved(bookmark: widget.bookmark),
          );
          showSuccessSnackBar();
        },
        backgroundBuilder: (context, direction, progress) {
          return Container(
            alignment: Alignment.center,
            color: context.colors.error,
            child: ListTile(
              trailing: Icon(Icons.delete, color: context.colors.onError),
            ),
          );
        },
        child: Material(
          color: !widget.isAnswerVisible
              ? context.colors.primaryContainer
              : context.colors.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _toggle,
            child: Ink(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: minHeight ?? 0,
                  minWidth: double.infinity,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      plainCardText(
                        widget.isAnswerVisible
                            ? widget.bookmark.answer
                            : widget.bookmark.question,
                      ),
                      key: widget.isAnswerVisible ? null : _textKey,
                      style: textStyle,
                    ),
                    if (widget.isAnswerVisible)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Column(
                          children: card
                              .buildCardInfoItems()
                              .map((item) => CardMetaRowFullWidth(item: item))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
