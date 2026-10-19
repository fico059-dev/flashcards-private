import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcards/bloc/authorization/auth/auth_state.dart';
import 'package:flashcards/bloc/authorization/update_email/update_email_state.dart';
import 'package:flashcards/data/repositories/users/auth_repository.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/utils/form_validations.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateEmailDuringVerificationCubit extends Cubit<UpdateEmailState> {
  final AuthRepository _authRepository;
  final void Function(SignOutReason reason) _setSignOutReason;
  final void Function() _resetSignOutReason;

  UpdateEmailDuringVerificationCubit({
    required AuthRepository authRepository,
    required Function(SignOutReason reason) setSignOutReason,
    required Function() resetSignOutReason,
  }) : _authRepository = authRepository,
       _resetSignOutReason = resetSignOutReason,
       _setSignOutReason = setSignOutReason,
       super(UpdateEmailInitial());

  Future<void> verifyBeforeUpdateEmail(
    String email,
    bool isVerifyEmailPage,
  ) async {
    if (state case UpdateEmailRequiresReauth(email: final prevEmail)) {
      email = prevEmail;
    }

    var errors = _validateForm(email);
    if (errors.isNotEmpty) {
      emit(UpdateEmailFormInvalid(errors: errors));
      return;
    }

    emit(UpdateEmailLoading());

    if (!isVerifyEmailPage) _setSignOutReason(SignOutReason.emailUpdated);
    var result = await _authRepository.verifyBeforeUpdateEmail(email);

    switch (result) {
      case Ok<User>():
        emit(UpdateEmailSent(email: email));
        break;
      case Error<User>(:final error):
        if (!isVerifyEmailPage) _resetSignOutReason;
        final requiresReauth = doesErrorRequireReauth(error);
        //var errorData = mapFirebaseError(error);

        if (requiresReauth) {
          emit(UpdateEmailRequiresReauth(email: email));
          break;
        } else {
          emit(UpdateEmailError(error: error));
          break;
        }
    }
  }

  // current email should be provided from auth bloc
  Future<void> reloadUser(String currentEmail) async {
    emit(UpdateEmailRefreshing());

    var result = await _authRepository.reloadUser();

    switch (result) {
      case Ok<User>(value: final user):
        if (currentEmail != user.email!) {
          emit(UpdateEmailSuccess());
        } else {
          emit(
            UpdateEmailError(
              error: Exception(
                "يبدو إنك ما وثّقت بريدك الجديد بعد.",
              ),
            ),
          );
        }
        break;
      case Error<User>(:final error):
        emit(UpdateEmailError(error: error));
        break;
    }
  }

  Map<String, String> _validateForm(String email) {
    Map<String, String> errors = {};

    putErrorIfExists(errors, 'email', validateEmail(email));

    return errors;
  }
}
