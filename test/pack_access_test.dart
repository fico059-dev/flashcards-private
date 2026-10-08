import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/data/repositories/utils/pack_visibility.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/pack_access_page.dart';
import 'package:flashcards/ui/theme/themes.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakePacks implements PackRepository {
  List<String>? saved;
  List<String> current = const [];

  @override
  Future<Result<List<String>>> getPackAccess(String packId) async =>
      Result.ok(current);

  @override
  Future<Result<List<String>>> setPackAccess(
    String packId,
    List<String> emails,
  ) async {
    saved = emails;
    return Result.ok(emails);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('PackVisibility', () {
    test('packs not limited are for everyone', () {
      const user = PackVisibility(isAdmin: false, openedPackIds: {});
      expect(user.allows('p', restricted: false), isTrue);
    });

    test('limited packs: only opened ones, and admins see all', () {
      const ali = PackVisibility(isAdmin: false, openedPackIds: {'p'});
      const bob = PackVisibility(isAdmin: false, openedPackIds: {});
      const admin = PackVisibility(isAdmin: true, openedPackIds: {});
      expect(ali.allows('p', restricted: true), isTrue);
      expect(ali.allows('q', restricted: true), isFalse);
      expect(bob.allows('p', restricted: true), isFalse);
      expect(admin.allows('p', restricted: true), isTrue);
    });
  });

  test('pasted emails are split, cleaned and checked', () {
    final (valid, invalid) = parseEmails(
      'Ali@Mail.com, sara@mail.com;\nali@mail.com  bad-email',
    );
    expect(valid, ['ali@mail.com', 'sara@mail.com']);
    expect(invalid, ['bad-email']);
  });

  testWidgets('admin limits a pack to pasted emails and saves', (tester) async {
    final repo = _FakePacks();
    await tester.pumpWidget(
      Provider<PackRepository>.value(
        value: repo,
        child: MaterialApp(
          theme: lightThemeData,
          home: const PackAccessPage(
            pack: AdminPack(
              packId: 'p1',
              packName: 'NeoReview 2025',
              flashcardsCount: 10,
              isPaid: false,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Only the users below'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'ali@mail.com, Sara@mail.com',
    );
    await tester.tap(find.byIcon(Icons.person_add_alt_1));
    await tester.pumpAndSettle();
    expect(find.text('2 user(s) can see this pack'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    expect(find.text('1 user(s) can see this pack'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repo.saved, ['sara@mail.com']);
  });

  testWidgets('choosing Everyone opens the pack again', (tester) async {
    final repo = _FakePacks()..current = ['ali@mail.com'];
    await tester.pumpWidget(
      Provider<PackRepository>.value(
        value: repo,
        child: MaterialApp(
          theme: lightThemeData,
          home: const PackAccessPage(
            pack: AdminPack(
              packId: 'p1',
              packName: 'Private pack',
              flashcardsCount: 10,
              isPaid: false,
              restricted: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ali@mail.com'), findsOneWidget);
    await tester.tap(find.text('Everyone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repo.saved, isEmpty);
  });
}
