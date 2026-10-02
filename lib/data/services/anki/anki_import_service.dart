import 'dart:convert';

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
  Future<AnkiParseResult> parseFile({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'apkg':
      case 'colpkg':
        final tempDirPath = kIsWeb ? '' : (await getTemporaryDirectory()).path;
        // Large decks take a while to read, keep the UI responsive.
        return compute((args) => parseAnkiPackage(args.$1, args.$2), (
          bytes,
          tempDirPath,
        ));
      case 'txt':
      case 'csv':
      case 'tsv':
        final content = utf8
            .decode(bytes, allowMalformed: true)
            .replaceFirst('\uFEFF', '');
        return compute(parseAnkiTxt, content);
      default:
        throw const AnkiImportException(
          "Unsupported file. Choose an Anki .apkg or .txt export.",
        );
    }
  }
}
