import 'package:flashcards/domain/models/flashcards/card_markup/card_markup.dart';
import 'package:flashcards/ui/widgets/notebook/highlightable_text.dart';
import 'package:flutter/material.dart';

/// A card's question or answer. Formatted cards (bold, underline, sizes,
/// tables, several images) are laid out block by block; plain cards are
/// shown exactly as before.
class CardContent extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final HighlightTarget? target;

  const CardContent(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.target,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasCardMarkup(text)) {
      return HighlightableText(
        text,
        style: style,
        textAlign: textAlign,
        target: target,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        for (final block in parseCardMarkup(text))
          switch (block) {
            TextBlock(:final text) => HighlightableText(
              text.plainText,
              runs: text.runs,
              style: style,
              textAlign: textAlign,
              target: target,
            ),
            ImageBlock(:final url) => _CardImage(url: url),
            TableBlock() => _CardTable(
              table: block,
              style: style,
              target: target,
            ),
          },
      ],
    );
  }
}

class _CardImage extends StatelessWidget {
  final String url;

  const _CardImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                InteractiveViewer(
                  maxScale: 5,
                  child: Image.network(url, fit: BoxFit.contain),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    ),
              errorBuilder: (context, error, stack) =>
                  const Icon(Icons.broken_image_outlined, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardTable extends StatelessWidget {
  final TableBlock table;
  final TextStyle? style;
  final HighlightTarget? target;

  const _CardTable({required this.table, this.style, this.target});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final columns = table.rows.first.length;
    final border = BorderSide(color: colors.outline.withValues(alpha: 0.6));
    final cellStyle = (style ?? const TextStyle()).copyWith(
      fontSize: (style?.fontSize ?? 16) - 1,
    );

    final widget = Table(
      border: TableBorder(
        top: border,
        bottom: border,
        left: border,
        right: border,
        horizontalInside: border,
        verticalInside: border,
        borderRadius: BorderRadius.circular(8),
      ),
      defaultColumnWidth: columns > 3
          ? const IntrinsicColumnWidth()
          : const FlexColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (var r = 0; r < table.rows.length; r++)
          TableRow(
            decoration: table.hasHeader && r == 0
                ? BoxDecoration(color: colors.primary.withValues(alpha: 0.10))
                : null,
            children: [
              for (final cell in table.rows[r])
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: HighlightableText(
                    cell.plainText,
                    runs: table.hasHeader && r == 0
                        ? [
                            for (final run in cell.runs)
                              StyledRun(
                                run.text,
                                bold: true,
                                underline: run.underline,
                                size: run.size,
                              ),
                          ]
                        : cell.runs,
                    style: cellStyle,
                    target: target,
                  ),
                ),
            ],
          ),
      ],
    );

    // Wide tables scroll sideways instead of squeezing the text.
    if (columns <= 3) return widget;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.sizeOf(context).width * 0.5,
        ),
        child: widget,
      ),
    );
  }
}
