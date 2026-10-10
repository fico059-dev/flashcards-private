import 'package:flashcards/data/repositories/notebook/highlight_repository.dart';
import 'package:flashcards/domain/models/flashcards/card_markup/card_markup.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/domain/models/flashcards/highlight/highlight.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Colour of highlighted text, readable in light and dark mode.
const highlightBackground = Color(0xFFFFE27A);
const highlightForeground = Color(0xFF2B2300);

/// Which card side a [HighlightableText] shows.
class HighlightTarget {
  final String flashcardId;
  final String packId;
  final HighlightSide side;

  /// The card's question, kept with the highlight for the notebook.
  final String question;

  const HighlightTarget({
    required this.flashcardId,
    required this.packId,
    required this.side,
    required this.question,
  });

  /// Null for placeholder cards, which can't be highlighted.
  static HighlightTarget? of(Flashcard flashcard, HighlightSide side) {
    if (flashcard.id.isEmpty || flashcard.id == '-1') return null;
    return HighlightTarget(
      flashcardId: flashcard.id,
      packId: flashcard.packId,
      side: side,
      question: flashcard.question,
    );
  }
}

/// Selectable card text. With a [target], selected text can be highlighted
/// (and highlights removed) from the selection menu, and highlights are
/// shown in yellow.
class HighlightableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final HighlightTarget? target;

  /// Bold, underline and size of parts of [text] (formatted cards). Their
  /// texts joined must equal [text].
  final List<StyledRun>? runs;

  const HighlightableText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.target,
    this.runs,
  });

  @override
  State<HighlightableText> createState() => _HighlightableTextState();
}

class _HighlightableTextState extends State<HighlightableText> {
  HighlightRepository? _repo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Missing outside the app (e.g. in admin previews or tests).
    try {
      _repo = context.read<HighlightRepository>();
    } on ProviderNotFoundException {
      _repo = null;
    }
    if (widget.target != null) _repo?.load();
  }

  @override
  Widget build(BuildContext context) {
    final repo = _repo;
    final target = widget.target;
    if (repo == null || target == null) {
      if (widget.runs == null) {
        return SelectableText(
          widget.text,
          style: widget.style,
          textAlign: widget.textAlign,
        );
      }
      return SelectableText.rich(
        _spans(const []),
        style: widget.style,
        textAlign: widget.textAlign,
      );
    }
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final ranges = highlightRanges(
          widget.text,
          repo.forCard(target.flashcardId, target.side),
        );
        return SelectableText.rich(
          _spans(ranges),
          style: widget.style,
          textAlign: widget.textAlign,
          contextMenuBuilder: (context, editableTextState) =>
              _menu(context, editableTextState, repo, target),
        );
      },
    );
  }

  TextSpan _spans(List<(int, int, Highlight)> ranges) {
    final text = widget.text;
    final runs = widget.runs ?? [StyledRun(text)];

    // Cut the text wherever a style or a highlight starts or ends.
    final cuts = <int>{0, text.length};
    var offset = 0;
    final runStarts = <int>[];
    for (final run in runs) {
      runStarts.add(offset);
      cuts.add(offset);
      offset += run.text.length;
      cuts.add(offset);
    }
    for (final (start, end, _) in ranges) {
      cuts
        ..add(start)
        ..add(end);
    }
    final points = cuts.where((c) => c >= 0 && c <= text.length).toList()
      ..sort();

    final children = <TextSpan>[];
    var runIndex = 0;
    for (var i = 0; i + 1 < points.length; i++) {
      final start = points[i];
      final end = points[i + 1];
      if (start == end) continue;
      while (runIndex + 1 < runs.length && runStarts[runIndex + 1] <= start) {
        runIndex++;
      }
      final run = runs[runIndex];
      final highlighted = ranges.any((r) => r.$1 <= start && r.$2 >= end);
      children.add(
        TextSpan(
          text: text.substring(start, end),
          style: TextStyle(
            fontWeight: run.bold ? FontWeight.w700 : null,
            decoration: run.underline ? TextDecoration.underline : null,
            fontSize: run.size,
            backgroundColor: highlighted ? highlightBackground : null,
            color: highlighted ? highlightForeground : null,
          ),
        ),
      );
    }
    return TextSpan(children: children);
  }

  Widget _menu(
    BuildContext context,
    EditableTextState editableTextState,
    HighlightRepository repo,
    HighlightTarget target,
  ) {
    final value = editableTextState.textEditingValue;
    final selection = value.selection;
    final buttons = [...editableTextState.contextMenuButtonItems];

    void closeMenu() {
      editableTextState.userUpdateTextEditingValue(
        value.copyWith(
          selection: TextSelection.collapsed(offset: selection.end),
        ),
        SelectionChangedCause.toolbar,
      );
      editableTextState.hideToolbar();
    }

    void showError(Object error) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't save the highlight: ${extractErrorMessage(error)}",
          ),
        ),
      );
    }

    if (selection.isValid && !selection.isCollapsed) {
      // Highlights touching the selected text.
      final toRemove = [
        for (final highlight in repo.forCard(target.flashcardId, target.side))
          if (highlightRanges(widget.text, [
            highlight,
          ]).any((r) => r.$1 < selection.end && r.$2 > selection.start))
            highlight,
      ];

      if (toRemove.isNotEmpty) {
        buttons.insert(
          0,
          ContextMenuButtonItem(
            label: 'Remove highlight',
            onPressed: () {
              repo.remove(toRemove, onError: showError);
              closeMenu();
            },
          ),
        );
      } else {
        final selected = selection.textInside(value.text).trim();
        if (selected.isNotEmpty) {
          final leading = selection.textInside(value.text).indexOf(selected);
          buttons.insert(
            0,
            ContextMenuButtonItem(
              label: 'Highlight',
              onPressed: () {
                repo.add(
                  flashcardId: target.flashcardId,
                  packId: target.packId,
                  side: target.side,
                  text: selected,
                  start: selection.start + leading,
                  question: target.question,
                  onError: showError,
                );
                closeMenu();
              },
            ),
          );
        }
      }
    }

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: buttons,
    );
  }
}
