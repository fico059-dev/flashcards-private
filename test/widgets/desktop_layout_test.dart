import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fsrs/fsrs.dart' as fsrs;

void main() {
  Future<(List<String>, List<fsrs.Rating>)> pumpShortcuts(
    WidgetTester tester,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final shown = <String>[];
    final rated = <fsrs.Rating>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReadableWidth(
            child: ReviewShortcuts(
              onShowAnswer: () => shown.add('shown'),
              onRate: rated.add,
              child: const Text('card'),
            ),
          ),
        ),
      ),
    );
    return (shown, rated);
  }

  testWidgets('keys show the answer and rate the card', (tester) async {
    final (shown, rated) = await pumpShortcuts(tester, const Size(1200, 800));

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.sendKeyEvent(LogicalKeyboardKey.numpad4);

    expect(shown, hasLength(2));
    expect(rated, [
      fsrs.Rating.again,
      fsrs.Rating.hard,
      fsrs.Rating.good,
      fsrs.Rating.easy,
    ]);
    expect(find.textContaining('Keyboard:'), findsOneWidget);
    expect(tester.getSize(find.text('card').first).width, lessThan(821));
  });

  testWidgets('phones get no keyboard hint', (tester) async {
    await pumpShortcuts(tester, const Size(390, 844));
    expect(find.textContaining('Keyboard:'), findsNothing);
  });

  testWidgets('keys still work after clicking card text, not while typing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final shown = <String>[];
    final rated = <fsrs.Rating>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReviewShortcuts(
            onShowAnswer: () => shown.add('shown'),
            onRate: rated.add,
            child: const Column(
              children: [
                SelectableText('Most common cause of neonatal sepsis'),
                TextField(),
              ],
            ),
          ),
        ),
      ),
    );

    // Clicking the card text moves the focus to it.
    await tester.tap(find.byType(SelectableText));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    expect(shown, hasLength(1));
    expect(rated, [fsrs.Rating.good]);

    // Typing a note: the keys type instead.
    await tester.showKeyboard(find.byType(TextField));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    expect(rated, [fsrs.Rating.good]);

    // Nothing has focus (e.g. after a dialog closed).
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
    expect(rated, [fsrs.Rating.good, fsrs.Rating.easy]);

    // A dialog on top gets the keys.
    showDialog<void>(
      context: tester.element(find.byType(TextField)),
      builder: (_) => const AlertDialog(content: Text('Dialog')),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    expect(rated, [fsrs.Rating.good, fsrs.Rating.easy]);
  });
}
