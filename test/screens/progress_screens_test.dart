// Renders the Progress tab to PNG files for a visual check:
// flutter test test/screens/progress_screens_test.dart
@Tags(['screens'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flashcards/bloc/progress/progress_cubit.dart';
import 'package:flashcards/domain/models/progress/study_log.dart';
import 'package:flashcards/ui/pages/main_tab_pages/learning_progress/learning_progress_page.dart';
import 'package:flashcards/ui/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../progress_test.dart' as data;

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
  testWidgets('progress screens', (tester) async {
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

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightThemeData.copyWith(
            textTheme: lightThemeData.textTheme.apply(fontFamily: 'Roboto'),
          ),
          home: BlocProvider(
            create: (_) => ProgressCubit(
              progressRepo: data.FakeProgressRepository(
                goal: StudyGoal(
                  examDate: DateTime.now().add(const Duration(days: 45)),
                  targetCards: 230,
                  targetOsceScore: 80,
                ),
              ),
            )..load(),
            child: const LearningProgressView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cardsList = find.byType(Scrollable).first;
    for (var i = 0; i < 2; i++) {
      await _shot(tester, key, 'cards_$i');
      await tester.drag(cardsList, const Offset(0, -700));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('OSCE'));
    await tester.pumpAndSettle();
    final osceList = find.byType(Scrollable).last;
    for (var i = 0; i < 1; i++) {
      await _shot(tester, key, 'osce_$i');
      await tester.drag(osceList, const Offset(0, -700));
      await tester.pumpAndSettle();
    }
  });
}
