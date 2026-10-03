import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcards/bloc/authorization/auth/auth_event.dart';
import 'package:flashcards/bloc/authorization/auth/auth_state.dart';
import 'package:flashcards/data/repositories/users/auth_repository.dart';
import 'package:flashcards/data/repositories/users/profile_repository.dart';
import 'package:flashcards/data/services/api/dto/users/profile/update_profile/update_profile_dto.dart';
import 'package:flashcards/data/services/api/exceptions/document_doesnt_exist_exception.dart';
import 'package:flashcards/domain/models/profile/profile.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  late StreamSubscription<User?> _authSubscription;
  late StreamSubscription<User?> _userSubscription;
  late SignOutReason _expectedSignOutReason;
  Timer? _resumeTimer;
  Timer? _resetPendingEmailVerificationTimer;

  AuthBloc({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository,
       super(AuthInitial()) {
    resetSignOutReason();

    _authSubscription = _authRepository.authStateChanges().listen(
      _handleUserStateChange,
    );
    _userSubscription = _authRepository.userChanges().listen(_handleUserChange);

    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthLoggedOut>(_onAuthLoggedOut);
    on<AuthReset>(_onAuthReset);
    on<AuthSignOut>(_onAuthSignOut);
    on<AuthReloadUser>(_onAuthReloadUser);
    on<AuthNeedsEmailVerification>(_onAuthNeedsEmailVerification);
    on<UpdatePendingEmailVerification>(_onUpdatePendingEmailVerification);
    on<AuthRetry>(_onAuthRetry);

    // Initial check when app is started
    _handleUserStateChange(_authRepository.getCurrentUser());
  }

  void _handleUserChange(User? user) {
    print("[USER] User change... user: $user");
    if (user == null) return;

    if (state is AuthVerifyEmailPending && user.emailVerified) {
      add(AuthLoggedIn(user: user));
    }
  }

  void _handleUserStateChange(User? user) {
    print("[USER STATE] User state change... user: $user");

    if (user == null) {
      add(AuthLoggedOut());
    } else if (user.emailVerified) {
      add(AuthLoggedIn(user: user));
    } else {
      add(AuthNeedsEmailVerification(email: user.email!));
    }
  }

  void _onUpdatePendingEmailVerification(
    UpdatePendingEmailVerification event,
    Emitter<AuthState> emit,
  ) {
    switch (state) {
      case Authenticated():
        if (event.pendingEmailVerification) {
          _startResetPendingEmailVerificationTimer();
        } else {
          _resetPendingEmailVerificationTimer?.cancel();
        }
        emit(
          (state as Authenticated).copyWith(
            pendingEmailVerification: event.pendingEmailVerification,
          ),
        );
        break;
      default:
        break;
    }
  }

  void _onAuthNeedsEmailVerification(
    AuthNeedsEmailVerification event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthVerifyEmailPending(email: event.email));
  }

  void _onAuthReloadUser(AuthReloadUser event, Emitter<AuthState> emit) async {
    var prevState = state;
    emit(AuthLoading());

    var result = await _authRepository.reloadUser();

    switch (result) {
      case Ok<User>():
        // do nothing, auth listener will emit new state
        break;
      case Error<User>(error: var error):
        emit(prevState.copyWith(error: error));
        break;
    }
  }

  void _onAuthRetry(AuthRetry event, Emitter<AuthState> emit) {
    emit(AuthInitial());
    _handleUserStateChange(_authRepository.getCurrentUser());
  }

  Future<void> _onAuthLoggedIn(
    AuthLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    final prevState = state;
    try {
      await _loadProfileAndAuthenticate(event, emit, prevState);
    } catch (error) {
      // Without this, an unexpected error (e.g. a malformed profile) would
      // leave the splash screen loading forever.
      emit(
        prevState.copyWith(
          error: error is Exception ? error : Exception(error.toString()),
        ),
      );
    }
  }

  Future<void> _loadProfileAndAuthenticate(
    AuthLoggedIn event,
    Emitter<AuthState> emit,
    AuthState prevState,
  ) async {
    final result = await _profileRepository.getCurrentProfile();

    switch (result) {
      case Ok<Profile>(value: final profile):
        if (profile.email != event.user.email) {
          final dto = UpdateProfileDto(email: event.user.email);
          var updateResult = await _profileRepository.updateCurrentProfile(dto);

          switch (updateResult) {
            case Ok<void>():
              emit(Authenticated(user: event.user));
              break;
            case Error<void>(:final error):
              emit(prevState.copyWith(error: error));
              break;
          }
        } else {
          emit(Authenticated(user: event.user));
        }
        return;
      case Error<Profile>(:final error):
        if (error is! DocumentDoesntExistException) {
          emit(prevState.copyWith(error: error));
          return;
        }
    }

    print("Profile document not found, creating it now...");
    // If profile document doesn't exists (which should not happen) we go ahead and create it
    final createResult = await _profileRepository.createDefaultProfile();
    switch (createResult) {
      case Ok<void>():
        emit(Authenticated(user: event.user));
        break;
      case Error<void>(:final error):
        emit(prevState.copyWith(error: error));
    }
  }

  void _onAuthLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) {
    if (state case Unauthenticated()) return;

    emit(Unauthenticated(reason: _expectedSignOutReason));
    resetSignOutReason();
  }

  void _onAuthReset(AuthReset event, Emitter<AuthState> emit) {
    if (state is AuthInitial) return;

    emit(AuthInitial());
  }

  Future<void> _onAuthSignOut(
    AuthSignOut event,
    Emitter<AuthState> emit,
  ) async {
    var prevState = state;
    emit(AuthLoading());

    setSignOutReason(SignOutReason.manual);
    final result = await _authRepository.signOut();

    switch (result) {
      case Ok<void>():
        //emit(Unauthenticated(reason: Sign));
        break;
      case Error<void>(:final error):
        resetSignOutReason();
        emit(prevState.copyWith(error: error));
        break;
    }
  }

  void setSignOutReason(SignOutReason reason) {
    _expectedSignOutReason = reason;
    print(
      "[DEBUG] sign out reason changed to: ${_expectedSignOutReason.toString()}",
    );
  }

  void resetSignOutReason() {
    _expectedSignOutReason = SignOutReason.tokenExpired;
    print(
      "[DEBUG] sign out reason reset back to ${_expectedSignOutReason.toString()}",
    );
  }

  void _startResetPendingEmailVerificationTimer() {
    _resetPendingEmailVerificationTimer?.cancel();
    _resetPendingEmailVerificationTimer = Timer(
      const Duration(minutes: 20),
      () {
        add(UpdatePendingEmailVerification(pendingEmailVerification: false));
      },
    );
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    _userSubscription.cancel();
    _resumeTimer?.cancel();
    _resetPendingEmailVerificationTimer?.cancel();
    return super.close();
  }
}
