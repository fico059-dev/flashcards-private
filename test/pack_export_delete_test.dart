import 'package:flashcards/bloc/pack/delete_pack/delete_pack_cubit.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/data/services/anki/anki_exporter.dart';
import 'package:flashcards/data/services/anki/anki_txt_parser.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/delete_pack_dialog.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/pack_options_bottom_sheet.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePackRepository implements PackRepository {
  final deleted = <String>[];

  @override
  Future<Result<void>> deletePackWithCards(String packId) async {
    deleted.add(packId);
    return Result.ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Anki export', () {
    final cards = [
      Flashcard(
        id: '1',
        packId: 'p',
        question: 'First line\nSecond "quoted" <line>',
        answer: 'Answer & more',
        questionImageUrl: 'https://img/q.jpg',
        tags: [Tag.fromName('Heart Failure'), Tag.fromName('cardio')],
      ),
      const Flashcard(
        id: '2',
        packId: 'p',
        question: '{Furosemide} is a loop diuretic',
        answer: 'Furosemide is a loop diuretic',
        tags: [],
      ),
    ];

    test('writes Anki headers, note types, clozes and images', () {
      final text = buildAnkiExport(packName: 'Cardio\tPack', cards: cards);
      final lines = text.split('\n');
      expect(lines.take(5), [
        '#separator:tab',
        '#html:true',
        '#notetype column:1',
        '#tags column:4',
        '#deck:Cardio Pack',
      ]);
      expect(
        lines[5],
        'Basic\t"First line<br>Second ""quoted"" &lt;line&gt;'
        '<br><img src=""https://img/q.jpg"">"\t'
        'Answer &amp; more\theart_failure cardio',
      );
      expect(lines[6], 'Cloze\t{{c1::Furosemide}} is a loop diuretic\t\t');
    });

    test('the app imports its own export back', () {
      final result = parseAnkiTxt(
        buildAnkiExport(packName: 'Cardio', cards: cards),
      );
      expect(result.cards, hasLength(2));
      expect(result.cards[0].question, 'First line\nSecond "quoted" <line>');
      expect(result.cards[0].answer, 'Answer & more');
      expect(result.cards[0].tags, ['heart_failure', 'cardio']);
      expect(result.cards[1].question, '{Furosemide} is a loop diuretic');
      expect(result.cards[1].isCloze, isTrue);
    });

    test('file names are safe', () {
      expect(ankiExportFileName('Cardio: Step 1/2'), 'Cardio_Step_12.txt');
      expect(ankiExportFileName('???'), 'pack.txt');
    });
  });

  testWidgets('Deleting a pack with cards warns and deletes everything', (
    tester,
  ) async {
    final repo = _FakePackRepository();
    final cubit = DeletePackCubit(packRepo: repo);
    const pack = AdminPack(
      packId: 'pack1',
      packName: 'Cardiology',
      flashcardsCount: 12,
      isPaid: false,
      tagCounts: {},
    );
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showDeletePackDialog(
                context,
                pack,
                cubit,
                null,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('12 flashcards'), findsOneWidget);
    await tester.tap(find.text('Delete pack and 12 cards'));
    await tester.pumpAndSettle();

    expect(repo.deleted, ['pack1']);
    expect(result, isTrue);
    expect(find.text('Successfully deleted pack "Cardiology"'), findsOneWidget);
  });

  testWidgets('Pack menu scrolls down to Delete Pack on a small phone', (
    tester,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(375 * 2, 667 * 2);
    view.devicePixelRatio = 2;
    addTearDown(view.reset);

    const pack = AdminPack(
      packId: 'pack1',
      packName: 'Cardiology',
      flashcardsCount: 12,
      isPaid: false,
      tagCounts: {},
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showPackOptionsBottomSheet(context, pack),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Export Pack'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Delete Pack'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Delete Pack').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
