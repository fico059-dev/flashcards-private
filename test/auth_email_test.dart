import 'package:flashcards/bloc/authorization/auth/auth_bloc.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('emails differing only in case or spaces are the same', () {
    expect(sameEmail('Name@Gmail.com ', 'name@gmail.com'), isTrue);
    expect(sameEmail('a@b.com', 'c@b.com'), isFalse);
  });

  test('the splash screen names the step that failed', () {
    final error = StepException('Reading your profile', Exception('denied'));
    expect(extractErrorMessage(error), 'Reading your profile failed: denied');
  });
}
