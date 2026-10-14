// Renders the OSCE question editor after pasting text, to a PNG file:
// flutter test test/screens/osce_builder_screens_test.dart
@Tags(['screens'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flashcards/data/repositories/osces/osce_repository.dart';
import 'package:flashcards/data/services/local/pdf_export_service.dart';
import 'package:flashcards/domain/models/core/image_data_wrapper.dart';
import 'package:flashcards/domain/models/osce/osce.dart';
import 'package:flashcards/domain/models/osce/question/check/check.dart';
import 'package:flashcards/domain/models/osce/question/question.dart';
import 'package:flashcards/ui/pages/profile/admin_dashboard/question_builder/create_question_page.dart';
import 'package:flashcards/ui/theme/themes.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

class _FakeOsceRepo implements OsceRepository {
  var _next = 0;

  @override
  String generateQuestionId(String osceId) => 'new${_next++}';

  @override
  Future<Result<List<MapEntry<String, Question>>>> getQuestions(
    String osceId,
  ) async => Result.ok([]);

  @override
  Future<Result<void>> updateQuestion({
    required String osceId,
    required Question question,
    ImageDataWrapper questionImageData = const ImageDataWrapper(),
  }) async => Result.ok(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary =
        tester.renderObject(find.byType(RepaintBoundary).first)
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('build/screens')..createSync(recursive: true);
    File('${dir.path}/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('OSCE editor: add questions from text', (tester) async {
    await tester.runAsync(() async {
      await _loadFont('Roboto', [
        'Roboto-Regular.ttf',
        'Roboto-Medium.ttf',
        'Roboto-Bold.ttf',
      ]);
      await _loadFont('MaterialIcons', ['MaterialIcons-Regular.otf']);
    });
    tester.view.physicalSize = const Size(390 * 2, 1100 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepositoryProvider<OsceRepository>.value(
        value: _FakeOsceRepo(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightThemeData,
          home: const RepaintBoundary(
            child: QuestionEditorPage(osceId: 'osce'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Add from text'), findsOneWidget);

    await tester.tap(find.text('Add from text'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).last,
      'Q: Take a focused history from the mother\n'
      'History:\n'
      '- Introduces self and confirms identity\n'
      '- Asks about onset of fever (2)\n'
      '- Asks about feeding and wet nappies\n'
      'Q: Explain the management plan\n'
      '- Explains need for admission (2)\n'
      '- Checks understanding',
    );
    await tester.pump();
    expect(find.text('2 questions, 5 checks'), findsOneWidget);
    await _shot(tester, 'osce_text_dialog');

    await tester.tap(find.text('Add questions'));
    await tester.pumpAndSettle();
    expect(find.text('Question 1'), findsOneWidget);
    expect(find.text('Question 2'), findsOneWidget);
    expect(find.text('Total: 4 marks'), findsOneWidget);
    expect(find.text('Total: 3 marks'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await _shot(tester, 'osce_editor_after_paste');
  });

  test('OSCE results PDF', () async {
    final service = PdfExportService(
      theme: pw.ThemeData.base(),
      loadImage: (_) async => null,
    );
    Check c(
      String text, {
      bool done = true,
      int score = 1,
      bool title = false,
    }) => Check(
      text: text,
      isTitle: title,
      isChecked: done,
      index: 0,
      score: title ? 0 : score,
    );
    final osce = Osce(
      id: 'o',
      name: 'Febrile infant',
      scenario:
          'You are the paediatric resident. A 3 week old baby is brought in '
          'with a fever of 38.5. Take a history and explain the plan.',
      questions: [
        Question(
          id: 'a',
          text: 'Take a focused history from the mother',
          index: 0,
          checks: [
            c('History', title: true),
            c('Introduces self and confirms identity'),
            c('Asks about onset of fever', score: 2),
            c('Asks about feeding and wet nappies', done: false),
          ],
        ),
        Question(
          id: 'b',
          text: 'Explain the management plan',
          index: 1,
          checks: [
            c('Explains need for admission', score: 2, done: false),
            c('Checks understanding'),
          ],
        ),
      ],
    );
    final bytes = await service.generateOscePdf(
      osce,
      date: DateTime(2026, 10, 10),
    );
    final dir = Directory('build/screens')..createSync(recursive: true);
    File('${dir.path}/osce_result.pdf').writeAsBytesSync(bytes);
  });
}
