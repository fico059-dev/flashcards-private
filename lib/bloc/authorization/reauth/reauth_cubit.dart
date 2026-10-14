import 'package:flashcards/bloc/authorization/reauth/reauth_state.dart';
import 'package:flashcards/data/repositories/users/auth_repository.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/utils/form_validations.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReauthCubit extends Cubit<ReauthState> {
  final AuthRepository _authRepository;

  ReauthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(ReauthInitial());

  Future<void> reauthenticate(String password) async {
    var errors = _validateForm(password);
    if (errors.isNotEmpty) {
      emit(ReauthFormInvalid(errors: errors));
      return;
    }

    emit(ReauthLoading());

    var result = await _authRepository.reauthenticateWithCredential(password);

    switch (result) {
      case Ok<void>():
        emit(ReauthSuccess());
        break;
      case Error<void>(:final error):
        emit(ReauthError(error: error));
        break;
    }
  }

  /// For accounts made with Google or Apple, which have no password.
  Future<void> reauthenticateWithProvider() async {
    emit(ReauthLoading());
    final result = await _authRepository.reauthenticateWithProvider();
    switch (result) {
      case Ok<void>():
        emit(ReauthSuccess());
      case Error<void>(:final error):
        emit(ReauthError(error: error));
    }
  }

  Map<String, String> _validateForm(String password) {
    Map<String, String> errors = {};

    putErrorIfExists(errors, 'password', validatePassword(password));
    return errors;
  }
}
