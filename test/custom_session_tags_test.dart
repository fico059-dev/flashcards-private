import 'package:flashcards/bloc/custom_session/session_limit/session_limit_cubit.dart';
import 'package:flashcards/bloc/custom_session/session_tag_picker/session_tag_picker_cubit.dart';
import 'package:flashcards/bloc/custom_session/session_tag_picker/session_tag_picker_state.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/domain/models/flashcards/custom_session_summary/custom_session_summary.dart';
import 'package:flashcards/ui/dialogs/previous_session/rename_session_dialog.dart';
import 'package:flashcards/ui/pages/custom_session/custom_session_maker/flashcard_tag_selection_page.dart';
import 'package:flashcards/ui/widgets/previous_sessions/previous_session_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashcards/ui/theme/themes.dart';

const _packs = [
  AdminPack(
    packId: 'p1',
    packName: 'Neonatology',
    flashcardsCount: 120,
    isPaid: false,
    tagCounts: {'neoreview': 80, 'cardio': 12, '2025': 30},
  ),
  AdminPack(
    packId: 'p2',
    packName: 'Paediatrics',
    flashcardsCount: 60,
    isPaid: false,
    tagCounts: {'2025': 10, 'acid__base': 5},
  ),
];

void main() {
  group('tag picker', () {
    test('lists tags A to Z with nothing selected', () {
      final cubit = SessionTagPickerCubit()..loadAllTags(_packs);
      final state = cubit.state as SessionTagPickerLoaded;
      expect(state.allTagCounts.keys.map((t) => t.name), [
        '2025',
        'Acid Base',
        'Cardio',
        'Neoreview',
      ]);
      expect(state.allTagCounts.values, [40, 5, 12, 80]);
      expect(state.selectedTags, isEmpty);
      expect(cubit.state.isCountExact, isTrue);
      expect(cubit.state.maxCardsWithAllTags, isNull);
    });

    test('several tags estimate at most the rarest tag count', () {
      final cubit = SessionTagPickerCubit()..loadAllTags(_packs);
      final tags = (cubit.state as SessionTagPickerLoaded).allTagCounts.keys;
      cubit.toggleTag(tags.firstWhere((t) => t.id == 'neoreview'));
      cubit.toggleTag(tags.firstWhere((t) => t.id == '2025'));
      expect(cubit.state.selectedTagsList, ['neoreview', '2025']);
      expect(cubit.state.isCountExact, isFalse);
      expect(cubit.state.maxCardsWithAllTags, 40);

      cubit.clearSelection();
      expect(cubit.state.selectedTagsList, isEmpty);
    });
  });

  test('default session names', () {
    expect(
      defaultSessionName(tagNames: ['Neoreview', '2025'], packNames: ['A']),
      'Neoreview + 2025',
    );
    expect(
      defaultSessionName(tagNames: [], packNames: ['Cardiology', 'Renal']),
      'Cardiology, Renal',
    );
    expect(defaultSessionName(tagNames: ['x' * 80], packNames: []).length, 60);
  });

  testWidgets('tag page: sorted list, AND summary, clear', (tester) async {
    final cubit = SessionTagPickerCubit();
    await tester.pumpWidget(
      MaterialApp(
        theme: lightThemeData,
        home: BlocProvider.value(
          value: cubit,
          child: const FlashcardTagSelectionPage(packs: _packs),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No tags selected: all cards included'), findsOneWidget);
    final names = tester
        .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
        .map((tile) => (tile.title as Text).data)
        .toList();
    expect(names, ['2025', 'Acid Base', 'Cardio', 'Neoreview']);

    await tester.tap(find.text('Neoreview'));
    await tester.pump();
    await tester.tap(find.widgetWithText(CheckboxListTile, '2025'));
    await tester.pump();
    expect(find.text('Cards with all 2 tags:'), findsOneWidget);
    expect(find.text('AND'), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pump();
    expect(find.text('No tags selected: all cards included'), findsOneWidget);
  });

  testWidgets('session card shows the name and renames', (tester) async {
    String? renamed;
    final session = CustomSessionSummary(
      id: 's1',
      createdAt: DateTime(2026, 10, 1),
      isPaid: false,
      cardCount: 40,
      correctCount: 0,
      currentIndex: 3,
      name: 'Neoreview + 2025',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: lightThemeData,
        home: Scaffold(
          body: Builder(
            builder: (context) => PreviousSessionCard(
              session: session,
              hasCards: true,
              onRenamePressed: () async => renamed =
                  await showRenameSessionDialog(
                    context,
                    currentName: session.name!,
                  ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Neoreview + 2025'), findsOneWidget);
    await tester.tap(find.byTooltip('Rename session'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Neo 2025 exam ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(renamed, 'Neo 2025 exam');

    // Older sessions without a name keep the old title.
    expect(session.copyWith(name: null).displayName, 'Custom Session');
  });
}
