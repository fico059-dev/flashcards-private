import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flashcards/data/services/anki/anki_import_models.dart';
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
/// [tempDirPath] is a writable directory used to open the database, since
/// SQLite needs a file on disk.
AnkiParseResult parseAnkiPackage(Uint8List bytes, String tempDirPath) {
  final archive = _decodeZip(bytes);
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
        "again and tick \"Support older Anki versions\", then import that file.",
      );
    }
    throw const AnkiImportException(
      "No Anki collection was found in this file.",
    );
  }

  final mediaByName = _readMediaIndex(archive);
  final imageCache = <String, AnkiImage?>{};
  AnkiImage? findImage(String name) {
    return imageCache.putIfAbsent(name, () {
      final entryName = mediaByName[name];
      if (entryName == null) return null;
      final data = archive.findFile(entryName)?.readBytes();
      if (data == null || data.isEmpty) return null;
      return AnkiImage(name: name, bytes: data);
    });
  }

  final notes = _readNotes(collection.content, tempDirPath);
  if (notes.isEmpty) {
    throw const AnkiImportException("This deck doesn't contain any cards.");
  }
  return AnkiNoteConverter(findImage: findImage).convert(notes);
}

Archive? _decodeZip(Uint8List bytes) {
  try {
    return ZipDecoder().decodeBytes(bytes);
  } on Object {
    return null;
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

List<AnkiNote> _readNotes(Uint8List collectionBytes, String tempDirPath) {
  final dbFile = File(
    '$tempDirPath/anki_import_${DateTime.now().microsecondsSinceEpoch}.db',
  );
  dbFile.writeAsBytesSync(collectionBytes, flush: true);

  Database? db;
  try {
    db = sqlite3.open(dbFile.path, mode: OpenMode.readOnly);
    // Keep the order the cards were created in Anki.
    final rows = db.select('SELECT flds, tags FROM notes ORDER BY id');
    return rows
        .map(
          (row) => AnkiNote(
            fields: (row['flds'] as String).split(_fieldSeparator),
            tags: (row['tags'] as String)
                .split(' ')
                .where((tag) => tag.isNotEmpty)
                .toList(),
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
      dbFile.deleteSync();
    } on FileSystemException {
      // Temporary file, the OS cleans it up eventually.
    }
  }
}
