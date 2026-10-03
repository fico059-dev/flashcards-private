import 'package:flashcards/data/services/anki/anki_import_models.dart';

/// Web fallback: reading the SQLite database inside an .apkg isn't supported
/// in the browser.
AnkiParseResult parseAnkiPackage(String filePath, String tempDirPath) {
  throw const AnkiImportException(
    "Importing .apkg files isn't available on the web. Use the mobile app, "
    "or export the deck from Anki as \"Notes in Plain Text (.txt)\".",
  );
}
