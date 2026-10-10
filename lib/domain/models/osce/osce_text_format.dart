import 'package:flashcards/domain/models/osce/question/question.dart';

/// Lets admins write a whole OSCE (or one checklist) as plain text instead of
/// filling one box per check.
///
/// ```
/// Q: Take a history from the mother
/// History:
/// - Asks about fever (2)
/// - Asks about feeding
/// Q: Examine the baby
/// - Checks the fontanelle [3]
/// ```
///
/// * A line starting with `Q:`, `Q1:`, `Q1.` or `Question 1:` starts a question.
/// * A line ending with `:` (or starting with `#`) is a title.
/// * Any other line is a check. A score in brackets at the end, like `(2)` or
///   `[2]`, sets its marks; otherwise it is worth 1.
/// * Bullets and numbering at the start (`-`, `•`, `*`, `1.`, `1)`) are removed.
const osceTextFormatHelp =
    'Q: starts a question\n'
    'A line ending with ":" is a title\n'
    'Every other line is a check, worth 1 mark\n'
    'Put marks at the end in brackets: "Asks about fever (2)"';

class ParsedCheck {
  final String text;
  final bool isTitle;
  final int score;

  const ParsedCheck({required this.text, this.isTitle = false, this.score = 1});

  @override
  bool operator ==(Object other) =>
      other is ParsedCheck &&
      other.text == text &&
      other.isTitle == isTitle &&
      other.score == score;

  @override
  int get hashCode => Object.hash(text, isTitle, score);

  @override
  String toString() => isTitle ? 'Title($text)' : 'Check($text, $score)';
}

class ParsedQuestion {
  final String text;
  final List<ParsedCheck> checks;

  const ParsedQuestion({required this.text, required this.checks});
}

final _questionRegex = RegExp(
  r'^(?:q(?:uestion)?\s*\d*\s*[:.)]|q(?:uestion)?\s+\d+\s*[-–]?)\s*',
  caseSensitive: false,
);
final _bulletRegex = RegExp(r'^(?:[-•*·▪◦–]+|\d{1,3}[.)])\s+');
final _scoreRegex = RegExp(
  r'\s*[(\[]\s*(\d{1,4})\s*(?:marks?|pts?|points?)?\s*[)\]]\s*$',
  caseSensitive: false,
);

/// Reads one checklist line. Returns null for empty lines.
ParsedCheck? parseCheckLine(String rawLine) {
  var line = rawLine.trim();
  if (line.isEmpty) return null;

  if (line.startsWith('#')) {
    final text = line.replaceFirst(RegExp(r'^#+\s*'), '').trim();
    return text.isEmpty ? null : ParsedCheck(text: text, isTitle: true);
  }

  line = line.replaceFirst(_bulletRegex, '').trim();
  if (line.isEmpty) return null;

  var score = 1;
  final scoreMatch = _scoreRegex.firstMatch(line);
  if (scoreMatch != null) {
    score = int.parse(scoreMatch.group(1)!);
    line = line.substring(0, scoreMatch.start).trim();
    if (score < 1) score = 1;
    if (score > 1000) score = 1000;
  }
  if (line.isEmpty) return null;

  if (scoreMatch == null && line.endsWith(':')) {
    final text = line.substring(0, line.length - 1).trim();
    if (text.isNotEmpty) return ParsedCheck(text: text, isTitle: true);
  }
  return ParsedCheck(text: line, score: score);
}

/// Reads a checklist, one check per line.
List<ParsedCheck> parseChecklist(String text) => [
  for (final line in text.split('\n'))
    if (parseCheckLine(line) case final check?) check,
];

/// Reads a whole OSCE. Lines before the first `Q:` belong to a question with
/// no text, so a plain checklist becomes one question.
List<ParsedQuestion> parseOsceText(String text) {
  final questions = <ParsedQuestion>[];
  String? currentText;
  var currentChecks = <ParsedCheck>[];
  var started = false;

  void finish() {
    if (!started) return;
    if ((currentText ?? '').isEmpty && currentChecks.isEmpty) return;
    questions.add(
      ParsedQuestion(text: currentText ?? '', checks: currentChecks),
    );
  }

  for (final rawLine in text.split('\n')) {
    final line = rawLine.trim();
    final questionMatch = _questionRegex.firstMatch(line);
    if (questionMatch != null) {
      finish();
      started = true;
      currentText = line.substring(questionMatch.end).trim();
      currentChecks = <ParsedCheck>[];
      continue;
    }
    final check = parseCheckLine(line);
    if (check == null) continue;
    started = true;
    currentChecks.add(check);
  }
  finish();
  return questions;
}

/// Writes checks back as text, so an existing checklist can be edited in one
/// box.
String checklistToText(Iterable<ParsedCheck> checks) => checks
    .map(
      (c) => c.isTitle
          ? '${c.text}:'
          : c.score == 1
          ? '- ${c.text}'
          : '- ${c.text} (${c.score})',
    )
    .join('\n');

/// Writes a whole OSCE as text in the same format [parseOsceText] reads.
String osceToText(Iterable<Question> questions) => questions
    .map(
      (q) => [
        'Q: ${q.text}',
        checklistToText(
          q.checks.map(
            (c) =>
                ParsedCheck(text: c.text, isTitle: c.isTitle, score: c.score),
          ),
        ),
      ].where((part) => part.trim().isNotEmpty).join('\n'),
    )
    .join('\n\n');
