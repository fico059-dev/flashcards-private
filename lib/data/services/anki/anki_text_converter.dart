// Converts Anki note fields (HTML with Anki-specific markup) into the plain
// text format used by Flashpedz flashcards.
//
// Flashpedz marks a cloze deletion by wrapping text with `{}` (see
// `redactClozeQuestion` in util_functions.dart), so any literal braces coming
// from Anki are replaced with parentheses to avoid accidental clozes.

/// Private-use characters used as temporary cloze markers while the HTML is
/// being converted, so they survive brace sanitization.
const _clozeOpen = '';
const _clozeClose = '';

final _clozeRegex = RegExp(
  // Innermost cloze first: the content may not contain another cloze opener.
  r'\{\{c(\d+)::((?:(?!\{\{c\d+::)[\s\S])*?)\}\}',
);
final _clozeNumberRegex = RegExp(r'\{\{c(\d+)::');
final _imgRegex = RegExp(
  r'''<img\b[^>]*?\bsrc\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))[^>]*>''',
  caseSensitive: false,
);
final _soundRegex = RegExp(r'\[sound:[^\]]*\]');
final _styleOrScriptRegex = RegExp(
  r'<(style|script)\b[^>]*>[\s\S]*?</\1>',
  caseSensitive: false,
);
final _lineBreakTagRegex = RegExp(
  r'<br\s*/?>|</(div|p|li|tr|h[1-6])>',
  caseSensitive: false,
);
final _listItemRegex = RegExp(r'<li\b[^>]*>', caseSensitive: false);
final _tagRegex = RegExp(r'<[^>]+>');
final _entityRegex = RegExp(r'&(#x[0-9a-fA-F]+|#\d+|[a-zA-Z]+);');

const _namedEntities = {
  'nbsp': ' ',
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'ndash': '–',
  'mdash': '—',
  'hellip': '…',
  'rarr': '→',
  'larr': '←',
  'uarr': '↑',
  'darr': '↓',
  'harr': '↔',
  'times': '×',
  'divide': '÷',
  'plusmn': '±',
  'le': '≤',
  'ge': '≥',
  'ne': '≠',
  'deg': '°',
  'micro': 'µ',
  'middot': '·',
  'bull': '•',
  'lsquo': '‘',
  'rsquo': '’',
  'ldquo': '“',
  'rdquo': '”',
  'alpha': 'α',
  'beta': 'β',
  'gamma': 'γ',
  'delta': 'δ',
  'Delta': 'Δ',
};

/// Plain text extracted from an Anki field plus the images it referenced.
class AnkiFieldContent {
  final String text;
  final List<String> imageNames;

  const AnkiFieldContent({required this.text, required this.imageNames});
}

/// Returns the image file names referenced by `<img src="...">` in [html], in
/// order of appearance.
List<String> extractImageNames(String html) {
  return _imgRegex
      .allMatches(html)
      .map((m) => m.group(1) ?? m.group(2) ?? m.group(3) ?? '')
      .map((name) => _decodeEntities(Uri.decodeFull(name.trim())))
      .where((name) => name.isNotEmpty)
      .toList();
}

/// Converts an Anki field (HTML) into plain text and collects its images.
AnkiFieldContent convertAnkiField(String html) {
  final imageNames = extractImageNames(html);
  return AnkiFieldContent(text: htmlToPlainText(html), imageNames: imageNames);
}

/// Converts Anki HTML into readable plain text. Literal braces are replaced by
/// parentheses so they are not mistaken for Flashpedz clozes.
String htmlToPlainText(String html) {
  var text = html
      .replaceAll('\r\n', '\n')
      .replaceAll(_styleOrScriptRegex, '')
      .replaceAll(_soundRegex, '')
      // Anki stores line breaks as HTML, raw newlines are not meaningful.
      .replaceAll('\n', ' ')
      .replaceAll(_listItemRegex, '\n• ')
      .replaceAll(_lineBreakTagRegex, '\n')
      .replaceAll(_imgRegex, '')
      .replaceAll(_tagRegex, '')
      // A list item already starts on its own line.
      .replaceAll(RegExp(r'\n\s*\n• '), '\n• ');
  text = _decodeEntities(text);
  text = text.replaceAll('{', '(').replaceAll('}', ')');
  text = text.replaceAll(_clozeOpen, '{').replaceAll(_clozeClose, '}');

  final lines = text
      .split('\n')
      .map((line) => line.replaceAll(RegExp(r'[ \t ]+'), ' ').trim())
      .toList();
  return lines.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}

/// Returns the sorted cloze numbers (`c1`, `c2`, ...) used in [text].
List<int> findClozeNumbers(String text) {
  final numbers =
      _clozeNumberRegex
          .allMatches(text)
          .map((m) => int.parse(m.group(1)!))
          .toSet()
          .toList()
        ..sort();
  return numbers;
}

bool hasCloze(String text) => _clozeNumberRegex.hasMatch(text);

/// Builds the question for the card of cloze [number]: that cloze becomes a
/// Flashpedz cloze (`{answer}`), every other cloze is shown as plain text.
/// Anki hints (`{{c1::answer::hint}}`) are dropped.
String buildClozeQuestion(String html, int number) {
  var result = html;
  while (true) {
    var replaced = false;
    result = result.replaceAllMapped(_clozeRegex, (match) {
      replaced = true;
      final clozeNumber = int.parse(match.group(1)!);
      final content = match.group(2)!;
      final hintIndex = content.indexOf('::');
      final answer = hintIndex == -1
          ? content
          : content.substring(0, hintIndex);
      if (clozeNumber == number) {
        return '$_clozeOpen$answer$_clozeClose';
      }
      return answer;
    });
    if (!replaced) break;
  }
  return htmlToPlainText(result);
}

/// Removes cloze markers, leaving every answer visible.
String revealAllClozes(String html) {
  var result = html;
  while (_clozeRegex.hasMatch(result)) {
    result = result.replaceAllMapped(_clozeRegex, (match) {
      final content = match.group(2)!;
      final hintIndex = content.indexOf('::');
      return hintIndex == -1 ? content : content.substring(0, hintIndex);
    });
  }
  return result;
}

String _decodeEntities(String text) {
  return text.replaceAllMapped(_entityRegex, (match) {
    final entity = match.group(1)!;
    if (entity.startsWith('#x') || entity.startsWith('#X')) {
      final code = int.tryParse(entity.substring(2), radix: 16);
      return code == null ? match.group(0)! : String.fromCharCode(code);
    }
    if (entity.startsWith('#')) {
      final code = int.tryParse(entity.substring(1));
      return code == null ? match.group(0)! : String.fromCharCode(code);
    }
    return _namedEntities[entity] ?? match.group(0)!;
  });
}
