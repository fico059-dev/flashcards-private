import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flashcards/data/services/anki/anki_import_models.dart';
import 'package:flashcards/data/services/anki/anki_text_converter.dart';
import 'package:flashcards/data/services/anki/sqlite_reader.dart';

/// Separator Anki uses between the fields of a note.
const _fieldSeparator = '\x1f';

/// Parses an Anki deck package (.apkg / .colpkg) held in memory. Used on the
/// website, where files can't be extracted to disk and the SQLite library
/// isn't available: the zip is read from [bytes] and the notes with a plain
/// Dart SQLite reader. Images are kept in memory.
AnkiParseResult parseAnkiPackageBytes(Uint8List bytes) {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } on Object {
    throw const AnkiImportException(
      "This file isn't a valid Anki package (.apkg).",
    );
  }
  if (archive.isEmpty) {
    throw const AnkiImportException(
      "This file isn't a valid Anki package (.apkg).",
    );
  }

  final collection =
      archive.findFile('collection.anki21') ??
      (archive.findFile('collection.anki21b') == null
          ? archive.findFile('collection.anki2')
          : null);
  if (collection == null) {
    if (archive.findFile('collection.anki21b') != null) {
      throw const AnkiImportException(
        "This deck was exported in Anki's newest format. In Anki, export it "
        "again and tick \"Support older Anki versions\", then import that "
        "file.",
      );
    }
    throw const AnkiImportException(
      "No Anki collection was found in this file.",
    );
  }

  final List<Map<String, Object?>> rows;
  try {
    rows = SqliteFileReader(
      Uint8List.fromList(collection.content),
    ).readTable('notes');
  } on Object {
    throw const AnkiImportException(
      "The Anki collection in this file couldn't be read.",
    );
  }

  final notes = [
    for (final row in rows)
      AnkiNote(
        fields: (row['flds'] as String? ?? '').split(_fieldSeparator),
        tags: (row['tags'] as String? ?? '')
            .split(' ')
            .where((tag) => tag.isNotEmpty)
            .toList(),
        guid: row['guid'] as String?,
      ),
  ];
  if (notes.isEmpty) {
    throw const AnkiImportException("This deck doesn't contain any cards.");
  }

  final mediaByName = _readMediaIndex(archive);
  final imageCache = <String, AnkiImage?>{};
  AnkiImage? findImage(String name) {
    return imageCache.putIfAbsent(name, () {
      for (final candidate in imageNameCandidates(name)) {
        final entry = archive.findFile(mediaByName[candidate] ?? '');
        if (entry == null || entry.size == 0) continue;
        return AnkiImage(
          name: name,
          bytes: Uint8List.fromList(entry.content),
          names: [name],
        );
      }
      return null;
    });
  }

  return AnkiNoteConverter(findImage: findImage).convert(notes);
}

/// Maps media file names (as used in card HTML) to their zip entry names.
Map<String, String> _readMediaIndex(Archive archive) {
  final mediaFile = archive.findFile('media');
  if (mediaFile == null) return {};
  try {
    final decoded = jsonDecode(utf8.decode(mediaFile.content));
    if (decoded is! Map) return {};
    return {
      for (final entry in decoded.entries)
        entry.value.toString(): entry.key.toString(),
    };
  } on FormatException {
    // Newer, compressed media index. Images can't be read in that case.
    return {};
  }
}
