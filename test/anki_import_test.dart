import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flashcards/data/services/anki/anki_apkg_parser.dart';
import 'package:flashcards/data/services/anki/anki_import_models.dart';
import 'package:flashcards/data/services/anki/anki_tags.dart';
import 'package:flashcards/data/services/anki/anki_text_converter.dart';
import 'package:flashcards/data/services/anki/anki_txt_parser.dart';
import 'package:flashcards/data/utils/image_compression.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('htmlToPlainText', () {
    test('converts line breaks, lists and entities', () {
      expect(
        htmlToPlainText(
          '<div>Causes of <b>AKI</b>:</div><ul><li>Pre&nbsp;renal</li>'
          '<li>Renal &amp; post</li></ul><br>K&gt;5.5',
        ),
        'Causes of **AKI**:\n• Pre renal\n• Renal & post\n\nK>5.5',
      );
    });

    test('removes images and sounds, replaces braces', () {
      expect(
        htmlToPlainText('Set {a} <img src="x.png"> [sound:a.mp3]'),
        'Set (a)',
      );
    });
  });

  test('extractImageNames reads all quote styles', () {
    expect(
      extractImageNames(
        '<img src="a b.png"><IMG class=x src=\'c.jpg\'><img src=d.gif />',
      ),
      ['a b.png', 'c.jpg', 'd.gif'],
    );
  });

  group('cloze', () {
    const text =
        'The {{c1::heart}} has {{c2::four::number}} chambers, {{c1::really}}';

    test('builds one question per cloze number', () {
      expect(findClozeNumbers(text), [1, 2]);
      expect(
        buildClozeQuestion(text, 1),
        'The {heart} has four chambers, {really}',
      );
      expect(
        buildClozeQuestion(text, 2),
        'The heart has {four} chambers, really',
      );
    });

    test('works with the app cloze redaction', () {
      // Same pattern as redactClozeQuestion in util_functions.dart, which can't
      // be imported here because it depends on the Firebase config.
      String redactClozeQuestion(String question) =>
          question.replaceAll(RegExp(r'\{[^}]*\}'), '[...]');
      expect(
        redactClozeQuestion(buildClozeQuestion(text, 2)),
        'The heart has [...] chambers, really',
      );
    });

    test('handles nested clozes', () {
      const nested = '{{c1::a {{c2::b}} c}}';
      expect(buildClozeQuestion(nested, 1), '{a b c}');
      expect(buildClozeQuestion(nested, 2), 'a {b} c');
    });
  });

  group('parseAnkiTxt', () {
    test('reads Anki headers, quoted fields and tags', () {
      final result = parseAnkiTxt(
        '#separator:tab\n#html:true\n#tags column:3\n'
        'Front 1\tBack <b>1</b>\tcardio Step1::Renal_Physiology\n'
        '"Multi\tline\n""quoted"""\tBack 2\t\n'
        '{{c1::Aspirin}} inhibits {{c2::COX}}\tExtra info\t\n',
      );
      expect(result.cards, hasLength(4));
      expect(result.cards[0].question, 'Front 1');
      expect(result.cards[0].answer, 'Back **1**');
      expect(result.cards[0].tags, ['cardio', 'Step1::Renal_Physiology']);
      expect(result.cards[1].question, 'Multi line "quoted"');
      expect(result.cards[2].question, '{Aspirin} inhibits COX');
      expect(result.cards[2].answer, 'Extra info');
      expect(result.cards[3].question, 'Aspirin inhibits {COX}');
      expect(result.cards[3].isCloze, isTrue);
    });

    test('reads plain CSV without headers', () {
      final result = parseAnkiTxt('Q1,A1\nQ2,A2\n,\n');
      expect(result.cards.map((c) => c.question), ['Q1', 'Q2']);
    });

    test('skips notes without an answer', () {
      final result = parseAnkiTxt('Q1\tA1\nQ2\t\n');
      expect(result.cards, hasLength(1));
      expect(result.skippedNotes, 1);
    });

    test('rejects empty files', () {
      expect(() => parseAnkiTxt(''), throwsA(isA<AnkiImportException>()));
    });
  });

  test('joins images top to bottom on white', () {
    Uint8List png(int width, int height, img.Color color) {
      final image = img.Image(width: width, height: height);
      img.fill(image, color: color);
      return img.encodePng(image);
    }

    final red = img.ColorRgb8(255, 0, 0);
    final blue = img.ColorRgb8(0, 0, 255);
    final bytes = stackImageBytes([
      png(400, 100, red),
      png(200, 50, blue),
      Uint8List.fromList([1, 2, 3]), // not an image, skipped
    ], gap: 10)!;

    final joined = img.decodeJpg(bytes)!;
    expect(joined.width, 400);
    expect(joined.height, 160);
    final top = joined.getPixel(200, 50);
    expect(top.r, greaterThan(200));
    expect(top.b, lessThan(60));
    final bottom = joined.getPixel(200, 135);
    expect(bottom.b, greaterThan(200));
    // The narrower image is centred, with white beside it.
    final side = joined.getPixel(20, 135);
    expect([side.r, side.g, side.b].every((c) => c > 230), isTrue);
  });

  test('very wide or tall images are scaled down', () {
    final image = img.Image(width: 3000, height: 2000);
    final bytes = img.encodePng(image);
    final joined = img.decodeJpg(
      stackImageBytes([bytes, bytes, bytes, bytes, bytes])!,
    )!;
    expect(joined.width, lessThanOrEqualTo(1200));
    expect(joined.height, lessThanOrEqualTo(6000));
  });

  test('ankiTagsToTags keeps the last level and ignores system tags', () {
    final tags = ankiTagsToTags([
      '#AK_Step1::Cardio::Heart_Failure',
      'leech',
      'a/b',
    ]);
    expect(tags.map((t) => t.id), ['heart__failure', 'a__b']);
  });

  group('parseAnkiPackage', () {
    late Directory tempDir;

    setUp(() => tempDir = Directory.systemTemp.createTempSync('anki_test'));
    tearDown(() => tempDir.deleteSync(recursive: true));

    test('reads notes and images from a legacy .apkg', () {
      final image = Uint8List.fromList([1, 2, 3, 4]);
      final apkg = _buildApkg(
        tempDir,
        notes: [
          ['What is this? <img src="ecg.png">', 'Atrial fibrillation'],
          ['{{c1::Furosemide}} is a {{c2::loop}} diuretic', ''],
          ['<img src="missing.png">', 'Answer'],
          ['', ''],
          ['Spot diagnosis <img src="50%_rash.jpg">', 'Measles'],
          ['Encoded <img src="my%20scan.png">', 'Yes'],
        ],
        media: {'0': 'ecg.png', '1': '50%_rash.jpg', '2': 'my scan.png'},
        files: {
          '0': image,
          '1': Uint8List.fromList([5]),
          '2': Uint8List.fromList([6]),
        },
      );

      final result = parseAnkiPackage(apkg, tempDir.path);

      expect(result.cards, hasLength(5));
      expect(result.cards[0].question, 'What is this?');
      expect(
        File(result.cards[0].questionImage!.path).readAsBytesSync(),
        image,
      );
      // A literal % in a file name isn't URL encoding and must not crash.
      expect(File(result.cards[3].questionImage!.path).readAsBytesSync(), [5]);
      expect(File(result.cards[4].questionImage!.path).readAsBytesSync(), [6]);
      expect(result.cards[1].question, '{Furosemide} is a loop diuretic');
      expect(result.cards[1].answer, 'Furosemide is a loop diuretic');
      expect(result.cards[2].question, 'Furosemide is a {loop} diuretic');
      expect(result.skippedNotes, 2);
      expect(result.missingImages, 1);
    });

    test('keeps every image of a side, in order', () {
      final apkg = _buildApkg(
        tempDir,
        notes: [
          [
            'Compare <img src="a.png"><img src="b.png"> and <img src="c.png">',
            'Answer <img src="missing.png"><img src="a.png">',
          ],
        ],
        media: {'0': 'a.png', '1': 'b.png', '2': 'c.png'},
        files: {
          '0': Uint8List.fromList([1]),
          '1': Uint8List.fromList([2]),
          '2': Uint8List.fromList([3]),
        },
      );

      final result = parseAnkiPackage(apkg, tempDir.path);
      final card = result.cards.single;
      expect(card.questionImage!.count, 3);
      expect(
        card.questionImage!.paths.map((p) => File(p).readAsBytesSync().first),
        [1, 2, 3],
      );
      expect(card.answerImage!.count, 1);
      expect(result.extraImagesDropped, 1);
      expect(result.missingImages, 1);
    });

    test('explains how to export when only the new format is present', () {
      final archive = Archive()
        ..addFile(ArchiveFile.bytes('collection.anki21b', [1, 2, 3]))
        ..addFile(ArchiveFile.bytes('collection.anki2', [1, 2, 3]));
      final path = '${tempDir.path}/new.apkg';
      File(path).writeAsBytesSync(ZipEncoder().encode(archive));

      expect(
        () => parseAnkiPackage(path, tempDir.path),
        throwsA(
          isA<AnkiImportException>().having(
            (e) => e.message,
            'message',
            contains('Support older Anki versions'),
          ),
        ),
      );
    });

    test('rejects files that are not zip archives', () {
      expect(
        () => parseAnkiPackage(
          (File('${tempDir.path}/bad.apkg')..writeAsBytesSync([1, 2, 3])).path,
          tempDir.path,
        ),
        throwsA(isA<AnkiImportException>()),
      );
    });
  });
}

/// Writes an .apkg to [dir] and returns its path.
String _buildApkg(
  Directory dir, {
  required List<List<String>> notes,
  required Map<String, String> media,
  required Map<String, Uint8List> files,
}) {
  final dbPath = '${dir.path}/collection.anki21';
  final db = sqlite3.open(dbPath);
  db.execute(
    'CREATE TABLE notes (id INTEGER PRIMARY KEY, flds TEXT NOT NULL, '
    'tags TEXT NOT NULL)',
  );
  for (var i = 0; i < notes.length; i++) {
    db.execute('INSERT INTO notes (id, flds, tags) VALUES (?, ?, ?)', [
      i + 1,
      notes[i].join('\x1f'),
      ' tag$i ',
    ]);
  }
  db.dispose();

  final archive = Archive()
    ..addFile(
      ArchiveFile.bytes('collection.anki21', File(dbPath).readAsBytesSync()),
    )
    ..addFile(ArchiveFile.string('media', jsonEncode(media)));
  files.forEach(
    (name, bytes) => archive.addFile(ArchiveFile.bytes(name, bytes)),
  );
  final path = '${dir.path}/deck.apkg';
  File(path).writeAsBytesSync(ZipEncoder().encode(archive));
  return path;
}
