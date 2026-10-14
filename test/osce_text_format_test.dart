import 'package:flashcards/domain/models/osce/osce_text_format.dart';
import 'package:flashcards/domain/models/osce/question/check/check.dart';
import 'package:flashcards/domain/models/osce/question/question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a pasted checklist becomes titles and checks with marks', () {
    expect(
      parseChecklist('''
History:
- Asks about fever (2)
• Asks about feeding
3) Asks about vaccines [3 marks]

# Examination
Checks fontanelle
'''),
      const [
        ParsedCheck(text: 'History', isTitle: true),
        ParsedCheck(text: 'Asks about fever', score: 2),
        ParsedCheck(text: 'Asks about feeding'),
        ParsedCheck(text: 'Asks about vaccines', score: 3),
        ParsedCheck(text: 'Examination', isTitle: true),
        ParsedCheck(text: 'Checks fontanelle'),
      ],
    );
  });

  test('a check ending with a score is not a title', () {
    expect(
      parseCheckLine('Explains plan: (2)'),
      const ParsedCheck(text: 'Explains plan:', score: 2),
    );
  });

  test('a whole OSCE splits into questions', () {
    final questions = parseOsceText('''
Q: Take a history
History:
- Fever (2)
- Feeding

Question 2: Examine the baby
- Fontanelle
Q3. Explain the plan
''');
    expect(questions.map((q) => q.text), [
      'Take a history',
      'Examine the baby',
      'Explain the plan',
    ]);
    expect(questions[0].checks.length, 3);
    expect(questions[0].checks[1], const ParsedCheck(text: 'Fever', score: 2));
    expect(questions[1].checks.single.text, 'Fontanelle');
    expect(questions[2].checks, isEmpty);
  });

  test('ordinary words starting with q are not questions', () {
    final questions = parseOsceText(
      'Q: Station\n- Quickly washes hands\n- Questions the mother',
    );
    expect(questions.single.checks.map((c) => c.text), [
      'Quickly washes hands',
      'Questions the mother',
    ]);
  });

  test('checks without a Q line become one question', () {
    final questions = parseOsceText('- Washes hands\n- Introduces self');
    expect(questions.single.text, '');
    expect(questions.single.checks.length, 2);
  });

  test('text written from an OSCE reads back the same', () {
    final original = [
      const Question(
        id: 'a',
        text: 'Take a history',
        index: 0,
        checks: [
          Check(
            text: 'History',
            isTitle: true,
            isChecked: false,
            index: 0,
            score: 0,
          ),
          Check(
            text: 'Fever',
            isTitle: false,
            isChecked: false,
            index: 1,
            score: 2,
          ),
          Check(text: 'Feeding', isTitle: false, isChecked: false, index: 2),
        ],
      ),
    ];
    final parsed = parseOsceText(osceToText(original)).single;
    expect(parsed.text, 'Take a history');
    expect(parsed.checks, const [
      ParsedCheck(text: 'History', isTitle: true),
      ParsedCheck(text: 'Fever', score: 2),
      ParsedCheck(text: 'Feeding'),
    ]);
  });
}
