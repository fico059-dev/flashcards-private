import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/pack_parent_dialog.dart';
import 'package:flashcards/ui/theme/themes.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakePacks implements PackRepository {
  final packs = const [
    AdminPack(
      packId: 'f',
      packName: 'Foundation Pack R1',
      flashcardsCount: 0,
      isPaid: false,
    ),
    AdminPack(
      packId: 'n',
      packName: 'Neonatal Essentials',
      flashcardsCount: 0,
      isPaid: false,
    ),
    AdminPack(
      packId: 'n1',
      packName: 'Neonatal sub',
      flashcardsCount: 0,
      isPaid: false,
      parentId: 'n',
    ),
  ];
  (String, String?)? saved;

  @override
  Future<Result<List<AdminPack>>> getAllAdminPacks() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return Result.ok(packs);
  }

  @override
  Future<Result<void>> setPackParent(String packId, String? parentId) async {
    saved = (packId, parentId);
    return Result.ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('opened from a menu that closes, the picker still works', (
    tester,
  ) async {
    final repo = _FakePacks();
    await tester.pumpWidget(
      Provider<PackRepository>.value(
        value: repo,
        child: MaterialApp(
          theme: lightThemeData,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (sheetContext) => ListTile(
                    title: const Text('Put inside another pack'),
                    onTap: () {
                      // Same as the pack menu: close it, then open the picker.
                      Navigator.of(sheetContext).pop();
                      showPackParentDialog(sheetContext, repo.packs[1]);
                    },
                  ),
                ),
                child: const Text('menu'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Put inside another pack'));
    await tester.pumpAndSettle();

    expect(find.text('Put "Neonatal Essentials" inside…'), findsOneWidget);
    // It can't go inside itself or its own sub-pack.
    expect(find.text('Neonatal sub'), findsNothing);
    await tester.tap(find.text('Foundation Pack R1'));
    await tester.pumpAndSettle();

    expect(repo.saved, ('n', 'f'));
    expect(
      find.text('"Neonatal Essentials" is now inside "Foundation Pack R1"'),
      findsOneWidget,
    );
  });
}
