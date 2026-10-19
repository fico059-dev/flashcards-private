import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcards/ui/widgets/auth/social_sign_in_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('closing the Google or Apple window is not an error', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));
    String? message(String code) => socialSignInErrorMessage(
      FirebaseAuthException(code: code),
      context,
    );
    expect(message('popup-closed-by-user'), isNull);
    expect(message('web-context-canceled'), isNull);
    expect(message('canceled'), isNull);
    expect(
      message('account-exists-with-different-credential'),
      contains('email and password'),
    );
    expect(message('popup-blocked'), contains('pop-ups'));
  });
}
