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

// Formatting kept from Anki, turned into the card formatting codes
// (**bold**, __underline__, | tables |). Private-use characters stand in
// for the codes while the rest of the HTML is removed.
const _boldMark = '';
const _underlineMark = '';
const _keptNewline = '';
final _boldRegex = RegExp(
  r'<(b|strong)\b[^>]*>([\s\S]*?)</\1\s*>',
  caseSensitive: false,
);
final _underlineRegex = RegExp(
  r'<u\b[^>]*>([\s\S]*?)</u\s*>',
  caseSensitive: false,
);
final _tableRegex = RegExp(
  r'<table\b[^>]*>([\s\S]*?)</table\s*>',
  caseSensitive: false,
);
final _rowRegex = RegExp(
  r'<tr\b[^>]*>([\s\S]*?)</tr\s*>',
  caseSensitive: false,
);
final _cellRegex = RegExp(
  r'<(td|th)\b[^>]*>([\s\S]*?)</\1\s*>',
  caseSensitive: false,
);

/// Some decks store HTML escaped (`&lt;br&gt;`), which used to show up as
/// text. Common tags written that way are turned back into real tags.
final _escapedTagRegex = RegExp(
  r'&lt;(/?)(br|b|strong|u|i|em|div|p|span|ul|ol|li|table|thead|tbody|tr|td|th)\b((?:(?!&gt;)[^<>])*)&gt;',
  caseSensitive: false,
);

/// Wraps [inner] in [mark] with spaces kept outside, so "<b> word </b>"
/// becomes " **word** ". Empty formatting is dropped.
String _wrapFormatted(String inner, String mark) {
  final trimmed = inner.trim();
  if (trimmed.isEmpty || RegExp(r'^(<[^>]+>|\s)*$').hasMatch(trimmed)) {
    return inner;
  }
  final lead = inner.substring(0, inner.indexOf(trimmed));
  final trail = inner.substring(inner.indexOf(trimmed) + trimmed.length);
  return '$lead$mark$trimmed$mark$trail';
}

/// An HTML table as card table lines.
String _tableToLines(String tableHtml) {
  final rows = <String>[];
  var headerRows = 0;
  for (final row in _rowRegex.allMatches(tableHtml)) {
    final cells = _cellRegex.allMatches(row.group(1)!).toList();
    if (cells.isEmpty) continue;
    if (rows.isEmpty && cells.every((c) => c.group(1)!.toLowerCase() == 'th')) {
      headerRows = 1;
    }
    final texts = cells.map((cell) {
      final text = _decodeEntities(
        cell
            .group(2)!
            .replaceAll(_lineBreakTagRegex, ' ')
            .replaceAll(_tagRegex, ''),
      ).replaceAll('|', '/').replaceAll(RegExp(r'\s+'), ' ').trim();
      return text.isEmpty ? ' ' : text;
    });
    rows.add('| ${texts.join(' | ')} |');
  }
  if (rows.isEmpty) return '';
  // The card table needs a header line; use the first row.
  final columns = '|'.allMatches(rows.first).length - 1;
  final separator = '|${List.filled(columns, '---').join('|')}|';
  final lines = [rows.first, separator, ...rows.skip(1)];
  if (headerRows == 0 && rows.length == 1) lines.removeAt(1);
  return '$_keptNewline${lines.join(_keptNewline)}$_keptNewline';
}

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
      .map((name) => _decodeEntities(name.trim()))
      .where((name) => name.isNotEmpty)
      .toList();
}

/// Image names in card HTML may be URL encoded (`my%20image.png`) while the
/// deck's media list has the plain name, so both are tried. Names containing
/// a literal `%` are not valid encodings and are only tried as they are.
List<String> imageNameCandidates(String name) {
  try {
    final decoded = Uri.decodeFull(name);
    return decoded == name ? [name] : [name, decoded];
  } on ArgumentError {
    return [name];
  }
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
      .replaceAllMapped(
        _escapedTagRegex,
        (m) => '<${m[1]}${m[2]}${m[3] ?? ''}>',
      )
      .replaceAll('\r\n', '\n')
      .replaceAll(_styleOrScriptRegex, '')
      .replaceAll(_soundRegex, '')
      // Anki stores line breaks as HTML, raw newlines are not meaningful.
      .replaceAll('\n', ' ')
      .replaceAllMapped(_tableRegex, (m) => _tableToLines(m[0]!))
      .replaceAllMapped(_boldRegex, (m) => _wrapFormatted(m[2]!, _boldMark))
      .replaceAllMapped(
        _underlineRegex,
        (m) => _wrapFormatted(m[1]!, _underlineMark),
      )
      .replaceAll(_listItemRegex, '\n• ')
      .replaceAll(_lineBreakTagRegex, '\n')
      .replaceAll(_imgRegex, '')
      .replaceAll(_tagRegex, '')
      // A list item already starts on its own line.
      .replaceAll(RegExp(r'\n\s*\n• '), '\n• ');
  text = _decodeEntities(text);
  text = text.replaceAll('{', '(').replaceAll('}', ')');
  text = text
      .replaceAll(_boldMark, '**')
      .replaceAll(_underlineMark, '__')
      .replaceAll(_keptNewline, '\n');
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
