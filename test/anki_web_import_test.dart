import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flashcards/data/services/anki/anki_apkg_bytes_parser.dart';
import 'package:flashcards/data/services/anki/sqlite_reader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final apkg = File('test/fixtures/sample.apkg').readAsBytesSync();

  test('the SQLite reader reads every note, long ones too', () {
    final archive = ZipDecoder().decodeBytes(apkg);
    final db = Uint8List.fromList(
      archive.findFile('collection.anki2')!.content,
    );
    final rows = SqliteFileReader(db).readTable('notes');
    expect(rows.length, 1504);
    expect(rows.first['guid'], 'g00001');
    expect(rows.first['id'], 1600000000001);
    expect(rows.first['flds'], 'Question 1\x1fAnswer 1');
    expect(rows[1499]['guid'], 'g01500');
    final long = rows.firstWhere((r) => r['guid'] == 'glong');
    expect((long['flds'] as String).length, greaterThan(20000));
    expect((long['flds'] as String).endsWith(' end'), isTrue);
    expect(
      rows.firstWhere((r) => r['guid'] == 'garab')['flds'],
      'ما هو العلاج؟ ﷺ\x1fالجواب ✓',
    );
  });

  test('a whole .apkg is imported on the website', () {
    final result = parseAnkiPackageBytes(apkg);
    // 1503 basic notes + one cloze note with 2 clozes.
    expect(result.cards.length, 1505);
    expect(result.cards.first.question, 'Question 1');
    expect(result.cards.first.answer, 'Answer 1');
    expect(result.cards.first.tags, ['neoreview']);
    expect(result.cards.first.sourceKey, 'anki:g00001');

    final cloze = result.cards.where((c) => c.isCloze).toList();
    expect(cloze.map((c) => c.sourceKey), [
      'anki:gcloze:c1',
      'anki:gcloze:c2',
    ]);

    final withImage = result.cards.firstWhere(
      (c) => c.sourceKey == 'anki:gimg',
    );
    expect(withImage.questionImage?.bytes, isNotNull);
    expect(withImage.answerImage?.count, 2);
    expect(withImage.answerImage?.key, 'pic.png|two.png');
  });
}
