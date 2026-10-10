// Renders a formatted card to a PNG file:
// flutter test test/screens/card_format_screens_test.dart
@Tags(['screens'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flashcards/ui/theme/themes.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/answer_container/widgets/flashcard_answer.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/main_card/widgets/question_text.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/flashcard_builder/card_format_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  testWidgets('formatted card screens', (tester) async {
    await tester.runAsync(() async {
      await _loadFont('Roboto', [
        'Roboto-Regular.ttf',
        'Roboto-Medium.ttf',
        'Roboto-Bold.ttf',
      ]);
      await _loadFont('MaterialIcons', ['MaterialIcons-Regular.otf']);
    });
    tester.view.physicalSize = const Size(390 * 2, 900 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightThemeData,
        home: Scaffold(
          body: RepaintBoundary(
            key: key,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardFormatToolbar(controller: TextEditingController()),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const QuestionText(
                        question:
                            'A term baby has **bilious vomiting** on day 1.\n'
                            '[size=22]What is the __first__ investigation?[/size]',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const FlashcardAnswer(
                    answer:
                        '**Upper GI contrast study** to rule out malrotation.\n'
                        '| Finding | Next step |\n'
                        '|---|---|\n'
                        '| Malrotation | __Urgent__ surgery |\n'
                        '| Normal | Observe, review feeds |',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory(
        Platform.environment['SCREENS_DIR'] ?? 'build/screens',
      )..createSync(recursive: true);
      File(
        '${dir.path}/formatted_card.png',
      ).writeAsBytesSync(png!.buffer.asUint8List());
    });
  });
}
