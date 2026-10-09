import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flashcards/data/services/anki/anki_import_models.dart';
import 'package:flashcards/data/services/anki/anki_text_converter.dart';
import 'package:sqlite3/sqlite3.dart';

/// Separator Anki uses between the fields of a note.
const _fieldSeparator = '\x1f';

/// Parses an Anki deck package (.apkg / .colpkg). An .apkg is a zip file with:
/// - `collection.anki21` or `collection.anki2`: an SQLite database with notes
/// - `media`: JSON mapping zip entry names ("0", "1", ...) to file names
/// - the media files themselves, named "0", "1", ...
///
/// Since Anki 2.1.50 the default export stores a compressed
/// `collection.anki21b` instead, which can't be read here, so the admin is
/// asked to tick "Support older Anki versions" when exporting.
///
/// Decks with media can be hundreds of MB, so the zip is read from
/// [filePath] on demand and only the database and the images cards use are
/// extracted, into [tempDirPath].
AnkiParseResult parseAnkiPackage(String filePath, String tempDirPath) {
  final InputFileStream input;
  try {
    input = InputFileStream(filePath);
  } on Object {
    throw const AnkiImportException("The chosen file couldn't be opened.");
  }

  try {
    final archive = _decodeZip(input);
    if (archive == null || archive.isEmpty) {
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

    final mediaDir = _freshMediaDirectory(tempDirPath);
    final mediaByName = _readMediaIndex(archive);
    final imageCache = <String, AnkiImage?>{};
    AnkiImage? findImage(String name) {
      return imageCache.putIfAbsent(name, () {
        for (final candidate in imageNameCandidates(name)) {
          final entry = archive.findFile(mediaByName[candidate] ?? '');
          if (entry == null || entry.size == 0) continue;
          final path = '${mediaDir.path}/${imageCache.length}';
          _extract(entry, path);
          return AnkiImage(name: name, path: path);
        }
        return null;
      });
    }

    final notes = _readNotes(collection, tempDirPath);
    if (notes.isEmpty) {
      throw const AnkiImportException("This deck doesn't contain any cards.");
    }
    return AnkiNoteConverter(findImage: findImage).convert(notes);
  } finally {
    input.closeSync();
  }
}

Archive? _decodeZip(InputFileStream input) {
  try {
    return ZipDecoder().decodeStream(input);
  } on Object {
    return null;
  }
}

/// Images from the previous import are removed before extracting new ones.
Directory _freshMediaDirectory(String tempDirPath) {
  final dir = Directory('$tempDirPath/anki_import_media');
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  return dir..createSync(recursive: true);
}

void _extract(ArchiveFile entry, String path) {
  final output = OutputFileStream(path);
  try {
    entry.writeContent(output);
  } finally {
    output.closeSync();
  }
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

List<AnkiNote> _readNotes(ArchiveFile collection, String tempDirPath) {
  final dbPath =
      '$tempDirPath/anki_import_${DateTime.now().microsecondsSinceEpoch}.db';
  _extract(collection, dbPath);

  Database? db;
  try {
    db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
    // Keep the order the cards were created in Anki.
    final rows = db.select('SELECT * FROM notes ORDER BY id');
    return rows
        .map(
          (row) => AnkiNote(
            fields: (row['flds'] as String).split(_fieldSeparator),
            tags: (row['tags'] as String)
                .split(' ')
                .where((tag) => tag.isNotEmpty)
                .toList(),
            guid: row.containsKey('guid') ? row['guid'] as String? : null,
          ),
        )
        .toList();
  } on SqliteException {
    throw const AnkiImportException(
      "The Anki collection in this file couldn't be read.",
    );
  } finally {
    db?.dispose();
    try {
      File(dbPath).deleteSync();
    } on FileSystemException {
      // Temporary file, the OS cleans it up eventually.
    }
  }
}
