import 'dart:ui' as ui;

import 'package:flashcards/data/repositories/notebook/highlight_repository.dart';
import 'package:flashcards/domain/models/flashcards/card_markup/card_markup.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/domain/models/flashcards/highlight/highlight.dart';
import 'package:flashcards/ui/widgets/flashcard/card_content.dart';
import 'package:flashcards/ui/widgets/notebook/highlightable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

/// Shows the card as it will be shared, asks whether to include the
/// student's highlights, then shares it as a picture or as text.
Future<void> showShareCardDialog(BuildContext context, Flashcard flashcard) {
  return showDialog<void>(
    context: context,
    builder: (context) => ShareCardDialog(flashcard: flashcard),
  );
}

/// The card text to share as plain text.
String shareCardText(Flashcard card) =>
    'Question:\n${plainCardText(card.question)}\n\n'
    'Answer:\n${plainCardText(card.answer)}\n\n'
    'Shared from FlashPedz';

class ShareCardDialog extends StatefulWidget {
  final Flashcard flashcard;

  const ShareCardDialog({super.key, required this.flashcard});

  @override
  State<ShareCardDialog> createState() => _ShareCardDialogState();
}

class _ShareCardDialogState extends State<ShareCardDialog> {
  final _cardKey = GlobalKey();
  final _shareButtonKey = GlobalKey();
  bool _withHighlights = true;
  bool _sharing = false;

  int get _highlightCount {
    try {
      final repo = context.read<HighlightRepository>();
      return [
        ...repo.forCard(widget.flashcard.id, HighlightSide.question),
        ...repo.forCard(widget.flashcard.id, HighlightSide.answer),
      ].length;
    } on ProviderNotFoundException {
      return 0;
    }
  }

  Rect? _origin() {
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _shareImage() async {
    setState(() => _sharing = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = data!.buffer.asUint8List();
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'image/png',
              name: 'flashpedz-card.png',
            ),
          ],
          fileNameOverrides: const ['flashpedz-card.png'],
          text: 'Shared from FlashPedz',
          sharePositionOrigin: _origin(),
        ),
      );
      navigator.pop();
    } catch (error) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't share the card. Try again.")),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _shareText() async {
    final navigator = Navigator.of(context);
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: shareCardText(widget.flashcard),
          sharePositionOrigin: _origin(),
        ),
      );
      navigator.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't share the card. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlights = _highlightCount;
    return AlertDialog(
      title: const Text('Share card'),
      insetPadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.border_color_outlined),
                    label: Text('With highlights'),
                  ),
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.format_color_reset_outlined),
                    label: Text('Without'),
                  ),
                ],
                selected: {_withHighlights},
                onSelectionChanged: (value) =>
                    setState(() => _withHighlights = value.first),
              ),
              if (highlights == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'You have no highlights on this card yet.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 12),
              RepaintBoundary(
                key: _cardKey,
                child: SharedCardView(
                  flashcard: widget.flashcard,
                  withHighlights: _withHighlights,
                  showLegend: _withHighlights && highlights > 0,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton.icon(
          onPressed: _sharing ? null : _shareText,
          icon: const Icon(Icons.notes),
          label: const Text('As text'),
        ),
        FilledButton.icon(
          key: _shareButtonKey,
          onPressed: _sharing ? null : _shareImage,
          icon: _sharing
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.ios_share),
          label: const Text('Share'),
        ),
      ],
    );
  }
}

/// The card as a picture: light, with the question, the answer and their
/// images, and the student's highlights when [withHighlights].
class SharedCardView extends StatelessWidget {
  final Flashcard flashcard;
  final bool withHighlights;

  /// Explains the yellow, when the card has highlights.
  final bool showLegend;

  const SharedCardView({
    super.key,
    required this.flashcard,
    required this.withHighlights,
    this.showLegend = false,
  });

  @override
  Widget build(BuildContext context) {
    // Always light, so the picture looks the same for whoever receives it.
    return Theme(
      data: ThemeData(
        colorSchemeSeed: const Color(0xFF233999),
        brightness: Brightness.light,
      ),
      child: Builder(
        builder: (context) {
          final text = Theme.of(context).textTheme;
          HighlightTarget? target(HighlightSide side) =>
              withHighlights ? HighlightTarget.of(flashcard, side) : null;
          Widget label(String value) => Text(
            value.toUpperCase(),
            style: text.labelMedium?.copyWith(
              color: const Color(0xFF233999),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          );
          Widget image(String? url) => url == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      height: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                );

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E4F0)),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label('Question'),
                const SizedBox(height: 6),
                DefaultTextStyle(
                  style: text.titleMedium!.copyWith(color: Colors.black87),
                  child: CardContent(
                    flashcard.question,
                    style: text.titleMedium?.copyWith(color: Colors.black87),
                    target: target(HighlightSide.question),
                  ),
                ),
                image(flashcard.questionImageUrl),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: Color(0xFFE2E4F0)),
                ),
                label('Answer'),
                const SizedBox(height: 6),
                CardContent(
                  flashcard.answer,
                  style: text.bodyLarge?.copyWith(color: Colors.black87),
                  target: target(HighlightSide.answer),
                ),
                image(flashcard.answerImageUrl),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Image.asset('assets/images/happy_parrot.png', height: 26),
                    const SizedBox(width: 6),
                    Text(
                      'FlashPedz',
                      style: text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF233999),
                      ),
                    ),
                    if (showLegend) ...[
                      const Spacer(),
                      Container(
                        width: 10,
                        height: 10,
                        color: highlightBackground,
                      ),
                      const SizedBox(width: 4),
                      Text('my highlights', style: text.labelSmall),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
