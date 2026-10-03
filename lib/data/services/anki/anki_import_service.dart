import 'dart:convert';
import 'dart:io';

import 'package:flashcards/data/services/anki/anki_apkg_parser_web.dart'
    if (dart.library.io) 'package:flashcards/data/services/anki/anki_apkg_parser.dart';
import 'package:flashcards/data/services/anki/anki_import_models.dart';
import 'package:flashcards/data/services/anki/anki_txt_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// File extensions accepted by the Anki importer.
const ankiImportExtensions = ['apkg', 'colpkg', 'txt', 'csv', 'tsv'];

/// Reads Anki exports into cards that can be imported into a pack.
class AnkiImportService {
  /// Parses the chosen file. On mobile pass its [path], so large decks are
  /// read from storage instead of memory; on the web pass its [bytes].
  Future<AnkiParseResult> parseFile({
    required String fileName,
    String? path,
    Uint8List? bytes,
  }) async {
    assert(path != null || bytes != null);
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'apkg':
      case 'colpkg':
        if (path == null) {
          // Only happens on the web, where the web parser explains why.
          return parseAnkiPackage('', '');
        }
        final tempDirPath = (await getTemporaryDirectory()).path;
        // Large decks take a while to read, keep the UI responsive.
        return compute((args) => parseAnkiPackage(args.$1, args.$2), (
          path,
          tempDirPath,
        ));
      case 'txt':
      case 'csv':
      case 'tsv':
        return compute((args) {
          final data = args.$2 ?? File(args.$1!).readAsBytesSync();
          final content = utf8
              .decode(data, allowMalformed: true)
              .replaceFirst('﻿', '');
          return parseAnkiTxt(content);
        }, (path, bytes));
      default:
        throw const AnkiImportException(
          "Unsupported file. Choose an Anki .apkg or .txt export.",
        );
    }
  }
}
