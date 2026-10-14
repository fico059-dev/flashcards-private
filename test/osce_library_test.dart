import 'dart:math';

import 'package:flashcards/data/repositories/osces/osce_library_repository.dart';
import 'package:flashcards/domain/models/osce/osce_folder/osce_library.dart';
import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';
import 'package:flashcards/ui/theme/themes.dart';
import 'package:flashcards/ui/widgets/osce/osce_library_view.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

SimpleOsce _s(String id, {String? folder, bool paid = false}) => SimpleOsce(
  id: id,
  name: 'Station $id',
  scenario: 'Scenario $id',
  isPaid: paid,
  folderId: folder,
);

OsceLibrary sampleLibrary() => OsceLibrary(
  folders: const [
    OsceFolder(id: 'peds', name: 'Paediatrics'),
    OsceFolder(id: 'neo', name: 'Neonatology', parentId: 'peds'),
    OsceFolder(id: 'surg', name: 'Surgery'),
  ],
  stations: [
    _s('1', folder: 'peds'),
    _s('2', folder: 'neo', paid: true),
    _s('3', folder: 'neo'),
    _s('4', folder: 'surg', paid: true),
    _s('5'),
    _s('6', folder: 'deleted-folder'),
  ],
);

class FakeLibraryRepository implements OsceLibraryRepository {
  final OsceLibrary library;
  FakeLibraryRepository(this.library);

  @override
  Future<Result<OsceLibrary>> getLibrary({bool refresh = false}) async =>
      Result.ok(library);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('OsceLibrary', () {
    final library = sampleLibrary();

    test('folders and stations by level', () {
      expect(library.subfolders(null).map((f) => f.name), [
        'Paediatrics',
        'Surgery',
      ]);
      expect(library.subfolders('peds').map((f) => f.id), ['neo']);
      expect(library.stationsIn('peds').map((s) => s.id), ['1']);
      // Stations of a deleted folder show at the top level.
      expect(library.stationsIn(null).map((s) => s.id), ['5', '6']);
    });

    test('a folder includes its sub-folders', () {
      expect(library.allStationsUnder('peds').map((s) => s.id), [
        '1',
        '2',
        '3',
      ]);
      expect(library.allStationsUnder(null), hasLength(6));
      expect(library.pathName('neo'), 'Paediatrics / Neonatology');
      expect(library.isInside('neo', 'peds'), isTrue);
      expect(library.isInside('surg', 'peds'), isFalse);
    });

    test('random station respects the folder and access', () {
      final picked = {
        for (var seed = 0; seed < 50; seed++)
          library
              .randomStation('peds', hasAccess: false, random: Random(seed))!
              .id,
      };
      expect(picked, {'1', '3'});

      final all = {
        for (var seed = 0; seed < 80; seed++)
          library
              .randomStation(null, hasAccess: true, random: Random(seed))!
              .id,
      };
      expect(all, {'1', '2', '3', '4', '5', '6'});

      // Only premium stations and no subscription: nothing to pick.
      expect(library.randomStation('surg', hasAccess: false), isNull);
    });
  });

  testWidgets('OSCE tab shows folders and opens them', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepositoryProvider<OsceLibraryRepository>.value(
        value: FakeLibraryRepository(sampleLibrary()),
        child: MaterialApp(
          theme: lightThemeData,
          home: const Scaffold(body: OsceLibraryView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Random station'), findsOneWidget);
    expect(find.text('From all 6 stations'), findsOneWidget);
    expect(find.text('Paediatrics'), findsOneWidget);
    expect(find.text('3 stations · 1 folder'), findsOneWidget);
    expect(find.text('Other stations'), findsOneWidget);
    expect(find.text('Station 5'), findsOneWidget);

    await tester.tap(find.text('Paediatrics'));
    await tester.pumpAndSettle();
    expect(find.text('From the 3 stations in this folder'), findsOneWidget);
    expect(find.text('Neonatology'), findsOneWidget);
    expect(find.text('Station 1'), findsOneWidget);
    expect(find.text('Station 5'), findsNothing);

    await tester.tap(find.text('Neonatology'));
    await tester.pumpAndSettle();
    expect(find.text('Paediatrics'), findsOneWidget); // breadcrumb
    expect(find.text('Station 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('From all 6 stations'), findsOneWidget);
  });
}
