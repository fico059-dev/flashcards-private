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
    test('packs without a list are for everyone', () {
      const user = PackVisibility(email: 'a@x.com', isAdmin: false);
      expect(user.allows(const []), isTrue);
    });

    test('limited packs: only listed emails, any case, and admins', () {
      const list = ['a@x.com'];
      expect(
        const PackVisibility(email: 'A@X.com', isAdmin: false).allows(list),
        isTrue,
      );
      expect(
        const PackVisibility(email: 'b@x.com', isAdmin: false).allows(list),
        isFalse,
      );
      expect(
        const PackVisibility(email: null, isAdmin: false).allows(list),
        isFalse,
      );
      expect(
        const PackVisibility(email: 'b@x.com', isAdmin: true).allows(list),
        isTrue,
      );
    });
  });

  test('pasted emails are split, cleaned and checked', () {
    final (valid, invalid) = parseEmails(
      'Ali@Mail.com, sara@mail.com;\nali@mail.com  bad-email',
    );
    expect(valid, ['ali@mail.com', 'sara@mail.com']);
    expect(invalid, ['bad-email']);
  });

  testWidgets('admin limits a pack to pasted emails and saves', (
    tester,
  ) async {
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
    final repo = _FakePacks();
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
              allowedEmails: ['ali@mail.com'],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Everyone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repo.saved, isEmpty);
  });
}
