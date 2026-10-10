import 'package:flashcards/data/services/anki/anki_import_models.dart';

/// Parses Anki's "Notes in Plain Text" export (.txt), or any tab/comma
/// separated file where the first column is the front and the second the back.
///
/// Newer Anki versions start the file with header lines such as:
/// ```
/// #separator:tab
/// #html:true
/// #tags column:3
/// ```
/// Plain text exports can't contain images, so image references are ignored.
AnkiParseResult parseAnkiTxt(String content) {
  final lines = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final headers = <String, String>{};

  // Read the "#key:value" header lines.
  var bodyStart = 0;
  while (bodyStart < lines.length && lines.startsWith('#', bodyStart)) {
    var lineEnd = lines.indexOf('\n', bodyStart);
    if (lineEnd == -1) lineEnd = lines.length;
    final line = lines.substring(bodyStart + 1, lineEnd);
    final colon = line.indexOf(':');
    if (colon == -1) break;
    headers[line.substring(0, colon).trim().toLowerCase()] = line.substring(
      colon + 1,
    );
    bodyStart = lineEnd + 1;
  }
  final body = bodyStart >= lines.length ? '' : lines.substring(bodyStart);

  final separator = _resolveSeparator(headers['separator'], body);
  final isHtml = (headers['html']?.trim().toLowerCase() ?? 'true') != 'false';

  int? columnIndex(String key) {
    final value = int.tryParse(headers['$key column']?.trim() ?? '');
    return value == null ? null : value - 1;
  }

  final tagsColumn = columnIndex('tags');
  final guidColumn = columnIndex('guid');
  final ignoredColumns = {
    columnIndex('guid'),
    columnIndex('notetype'),
    columnIndex('deck'),
    tagsColumn,
  }.whereType<int>().toSet();

  final notes = <AnkiNote>[];
  for (final row in _splitRows(body, separator)) {
    if (row.every((cell) => cell.trim().isEmpty)) continue;

    final fields = <String>[];
    for (var i = 0; i < row.length; i++) {
      if (ignoredColumns.contains(i)) continue;
      fields.add(isHtml ? row[i] : _plainToHtml(row[i]));
    }
    final tags = tagsColumn != null && tagsColumn < row.length
        ? row[tagsColumn].split(' ').where((t) => t.isNotEmpty).toList()
        : <String>[];
    final guid = guidColumn != null && guidColumn < row.length
        ? row[guidColumn].trim()
        : '';
    notes.add(
      AnkiNote(fields: fields, tags: tags, guid: guid.isEmpty ? null : guid),
    );
  }

  if (notes.isEmpty) {
    throw const AnkiImportException(
      "No cards were found in this file. Export from Anki with "
      "\"Notes in Plain Text (.txt)\" and try again.",
    );
  }

  return AnkiNoteConverter(findImage: (_) => null).convert(notes);
}

String _resolveSeparator(String? header, String body) {
  switch (header?.trim().toLowerCase()) {
    case 'tab':
      return '\t';
    case 'comma':
      return ',';
    case 'semicolon':
      return ';';
    case 'pipe':
      return '|';
    case 'colon':
      return ':';
    case 'space':
      return ' ';
    case final String value when value.length == 1:
      return value;
  }

  // No header: guess from the first line.
  final firstLine = body.split('\n').first;
  for (final candidate in ['\t', ';', ',']) {
    if (firstLine.contains(candidate)) return candidate;
  }
  return '\t';
}

/// Splits CSV-like content into rows. Fields may be wrapped in double quotes,
/// in which case they can contain separators and new lines, and `""` stands
/// for a literal quote.
List<List<String>> _splitRows(String body, String separator) {
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;
  var fieldStart = true;

  void endField() {
    row.add(field.toString());
    field.clear();
    fieldStart = true;
  }

  void endRow() {
    endField();
    rows.add(row);
    row = <String>[];
  }

  for (var i = 0; i < body.length; i++) {
    final char = body[i];
    if (inQuotes) {
      if (char == '"') {
        if (i + 1 < body.length && body[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(char);
      }
      continue;
    }

    if (char == '"' && fieldStart) {
      inQuotes = true;
      fieldStart = false;
    } else if (char == separator) {
      endField();
    } else if (char == '\n') {
      endRow();
    } else {
      field.write(char);
      fieldStart = false;
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}

String _plainToHtml(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('\n', '<br>');
