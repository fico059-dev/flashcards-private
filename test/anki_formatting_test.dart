import 'package:flashcards/data/services/anki/anki_text_converter.dart';
import 'package:flashcards/domain/models/flashcards/card_markup/card_markup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('escaped <br> from the deck becomes a real new line', () {
    expect(
      htmlToPlainText(
        'Cortisol supports tone.&lt;br&gt;Low cortisol is linked.&lt;br /&gt;End',
      ),
      'Cortisol supports tone.\nLow cortisol is linked.\nEnd',
    );
  });

  test('bold and underline are kept as card formatting', () {
    final text = htmlToPlainText(
      'Correct answer: <b>B. Cortisol</b> and <u>steroid</u> <strong> x </strong>',
    );
    expect(text, 'Correct answer: **B. Cortisol** and __steroid__ **x**');
    expect(plainCardText(text), 'Correct answer: B. Cortisol and steroid x');
  });

  test('escaped bold works too', () {
    expect(htmlToPlainText('&lt;b&gt;Key&lt;/b&gt; clue'), '**Key** clue');
  });

  test('a less-than sign in text is not mistaken for a tag', () {
    expect(htmlToPlainText('Glucose &lt; 2.6 mmol/L'), 'Glucose < 2.6 mmol/L');
  });

  test('Anki tables become card tables', () {
    final text = htmlToPlainText(
      'Doses:<table><tr><th>Drug</th><th>Dose</th></tr>'
      '<tr><td>Amox</td><td>50 <b>mg</b>/kg</td></tr></table>After',
    );
    expect(
      text,
      'Doses:\n| Drug | Dose |\n|---|---|\n| Amox | 50 mg/kg |\nAfter',
    );
    final table = parseCardMarkup(text).whereType<TableBlock>().single;
    expect(table.rows.length, 2);
    expect(table.hasHeader, isTrue);
  });
}
