// Renders the OSCE folder screens to PNG files:
// flutter test test/screens/osce_library_screens_test.dart
@Tags(['screens'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flashcards/data/repositories/osces/osce_library_repository.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/osce_builder/osce_library_admin.dart';
import 'package:flashcards/ui/theme/themes.dart';
import 'package:flashcards/ui/widgets/osce/osce_library_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../osce_library_test.dart' as data;

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
  testWidgets('osce library screens', (tester) async {
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
    final theme = lightThemeData.copyWith(
      textTheme: lightThemeData.textTheme.apply(fontFamily: 'Roboto'),
    );

    final key = GlobalKey();
    final repo = data.FakeLibraryRepository(data.sampleLibrary());
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: RepositoryProvider<OsceLibraryRepository>.value(
          value: repo,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: Scaffold(
              appBar: AppBar(title: const Text('OSCE')),
              body: const OsceLibraryView(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _shot(tester, key, 'osce_top');
    await tester.tap(find.text('Paediatrics'));
    await tester.pumpAndSettle();
    await _shot(tester, key, 'osce_folder');

    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: RepositoryProvider<OsceLibraryRepository>.value(
          value: repo,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const OsceFoldersAdminPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _shot(tester, key, 'osce_admin_folders');
  });
}
