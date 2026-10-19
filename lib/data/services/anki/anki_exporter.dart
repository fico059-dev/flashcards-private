import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';

/// Builds an Anki "Notes in Plain Text" file for [cards].
///
/// In Anki use File → Import and choose the file: the notes go into a deck
/// named after the pack, cloze cards use the Cloze note type and the rest
/// Basic. The app's own Anki import reads it back too.
///
/// Images are linked by their URL, so Anki shows them while online.
String buildAnkiExport({
  required String packName,
  required List<Flashcard> cards,
}) {
  final buffer = StringBuffer()
    ..writeln('#separator:tab')
    ..writeln('#html:true')
    ..writeln('#notetype column:1')
    ..writeln('#tags column:4')
    ..writeln('#deck:${_singleLine(packName)}');

  for (final card in cards) {
    final isCloze = _appCloze.hasMatch(card.question);
    final front = isCloze
        ? _textToHtml(
            card.question,
          ).replaceAllMapped(_appCloze, (match) => '{{c1::${match[1]}}}')
        : _textToHtml(card.question);
    final back = isCloze && _withoutBraces(card.question) == card.answer
        ? ''
        : _textToHtml(card.answer);

    buffer.writeln(
      [
        isCloze ? 'Cloze' : 'Basic',
        front + _image(card.questionImageUrl),
        back + _image(card.answerImageUrl),
        card.tags.map((tag) => tag.id.replaceAll('__', '_')).join(' '),
      ].map(_field).join('\t'),
    );
  }
  return buffer.toString();
}

/// A file name for the export that is safe on every platform.
String ankiExportFileName(String packName) {
  final safe = packName
      .replaceAll(RegExp(r'[^\w\- ]+'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '_');
  return '${safe.isEmpty ? 'pack' : safe}.txt';
}

/// The app marks a cloze deletion as `{text}`.
final _appCloze = RegExp(r'\{([^{}]*)\}');

String _withoutBraces(String text) =>
    text.replaceAllMapped(_appCloze, (match) => match[1]!);

String _textToHtml(String text) => text
    .trim()
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('\t', ' ')
    .replaceAll(RegExp(r'\r?\n'), '<br>');

String _image(String? url) {
  if (url == null || url.isEmpty) return '';
  return '<br><img src="${url.replaceAll('"', '%22')}">';
}

String _singleLine(String text) => text.replaceAll(RegExp(r'[\r\n\t]+'), ' ');

/// Quotes a field when it contains a character that would break the row.
String _field(String value) {
  if (!value.contains('"') && !value.contains('\t') && !value.contains('\n')) {
    return value;
  }
  return '"${value.replaceAll('"', '""')}"';
}
