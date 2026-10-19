// Renders the notebook and a highlighted card to PNG files:
// flutter test test/screens/notebook_screens_test.dart
@Tags(['screens'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flashcards/ui/theme/themes.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/answer_container/widgets/flashcard_answer.dart';
import 'package:flashcards/ui/widgets/notebook/highlightable_text.dart';
import 'package:flashcards/ui/widgets/notebook/highlights_list.dart';
import 'package:flashcards/domain/models/flashcards/highlight/highlight.dart';
import 'package:flashcards/data/repositories/notebook/highlight_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../notebook_test.dart' as data;

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = File(
      '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter'}'
      '/bin/cache/artifacts/material_fonts/$file',
    ).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

Future<void> _shot(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory(
      Platform.environment['SCREENS_DIR'] ?? 'build/screens',
    )..createSync(recursive: true);
    File('${dir.path}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('notebook screens', (tester) async {
    await tester.runAsync(() async {
      await _loadFont('Roboto', [
        'Roboto-Regular.ttf',
        'Roboto-Medium.ttf',
        'Roboto-Bold.ttf',
      ]);
      await _loadFont('MaterialIcons', ['MaterialIcons-Regular.otf']);
    });
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final functions = data.FakeHighlightFunctions();
    for (final (card, side, text, question) in [
      (
        'c1',
        'answer',
        'Beta blockers or non-dihydropyridine calcium channel blockers',
        'First line for rate control in {atrial fibrillation}?',
      ),
      (
        'c1',
        'question',
        'atrial fibrillation',
        'First line for rate control in {atrial fibrillation}?',
      ),
      (
        'c2',
        'answer',
        'Kussmaul breathing',
        'Signs of diabetic ketoacidosis?',
      ),
      ('c3', 'answer', 'Koplik spots', 'Pathognomonic sign of measles?'),
    ]) {
      functions.stored.add({
        'id': '$card$text',
        'flashcardId': card,
        'packId': 'p',
        'side': side,
        'text': text,
        'start': 0,
        'question': question,
        'createdAt': 0,
      });
    }
    final repo = HighlightRepository(
      functions: functions,
      authService: data.FakeAuth(),
    );
    final theme = lightThemeData.copyWith(
      textTheme: lightThemeData.textTheme.apply(fontFamily: 'Roboto'),
    );

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: ChangeNotifierProvider.value(
          value: repo,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: Scaffold(
              appBar: AppBar(title: const Text('Notebook')),
              body: HighlightsList(repository: repo),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _shot(tester, key, 'notebook');

    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: ChangeNotifierProvider.value(
          value: repo,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const Scaffold(
              body: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(height: 60),
                    FlashcardAnswer(
                      answer:
                          'Beta blockers or non-dihydropyridine calcium '
                          'channel blockers (diltiazem, verapamil). Digoxin '
                          'in sedentary patients or heart failure.',
                      highlightTarget: HighlightTarget(
                        flashcardId: 'c1',
                        packId: 'p',
                        side: HighlightSide.answer,
                        question: 'q',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.longPress(find.byType(SelectableText));
    await tester.pumpAndSettle();
    await _shot(tester, key, 'card_highlight');
  });
}
