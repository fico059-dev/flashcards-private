import 'package:flashcards/domain/models/flashcards/card_markup/card_markup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('plain cards are untouched, including blanks and cloze', () {
    for (final text in [
      'Most common cause of ______ in neonates?',
      'Give {vitamin K} at birth',
      'Dose: 5 * 2 mg',
      '__ is __',
    ]) {
      expect(hasCardMarkup(text), isFalse, reason: text);
      expect(plainCardText(text), text);
    }
  });

  test('bold, underline and size, also nested', () {
    final line = parseInline(
      'A **bold** and __under__ [size=24]big **both**[/size] end',
    );
    expect(line.plainText, 'A bold and under big both end');
    expect(line.runs, [
      const StyledRun('A '),
      const StyledRun('bold', bold: true),
      const StyledRun(' and '),
      const StyledRun('under', underline: true),
      const StyledRun(' '),
      const StyledRun('big ', size: 24),
      const StyledRun('both', bold: true, size: 24),
      const StyledRun(' end'),
    ]);
  });

  test('cloze inside formatting keeps its braces', () {
    expect(parseInline('**{answer}**').runs, [
      const StyledRun('{answer}', bold: true),
    ]);
  });

  test('several images between text', () {
    final blocks = parseCardMarkup(
      'Look:\n![x](https://a.com/1.jpg)\nand\n![y](https://a.com/2.jpg)',
    );
    expect(blocks.map((b) => b.runtimeType.toString()), [
      'TextBlock',
      'ImageBlock',
      'TextBlock',
      'ImageBlock',
    ]);
    expect((blocks[3] as ImageBlock).url, 'https://a.com/2.jpg');
  });

  test('tables with a header row', () {
    final blocks = parseCardMarkup(
      'Compare:\n| Drug | Dose |\n|---|---|\n| **Amox** | 50 |\n| Gent | 5 |\nDone',
    );
    expect(blocks.length, 3);
    final table = blocks[1] as TableBlock;
    expect(table.hasHeader, isTrue);
    expect(table.rows.length, 3);
    expect(table.rows[1][0].runs, [const StyledRun('Amox', bold: true)]);
    expect(plainCardText(blocks.isEmpty ? '' : '| a | b |'), 'a | b');
  });

  test('the table template is a valid table', () {
    final template = tableTemplate(3, 2);
    final table = parseCardMarkup(template).single as TableBlock;
    expect(table.hasHeader, isTrue);
    expect(table.rows.length, 3);
    expect(table.rows.first.map((c) => c.plainText), ['Header 1', 'Header 2']);
  });

  test('plain text for lists drops the codes', () {
    expect(
      plainCardText('**Bold** q\n![i](https://a.com/x.jpg)'),
      'Bold q\n[image]',
    );
  });
}
