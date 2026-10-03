import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthReloadUser extends AuthEvent {}

class AuthReset extends AuthEvent {}

class UpdatePendingEmailVerification extends AuthEvent {
  final bool pendingEmailVerification;

  const UpdatePendingEmailVerification({
    required this.pendingEmailVerification,
  });

  @override
  List<Object?> get props => [pendingEmailVerification];
}

class AuthLoggedIn extends AuthEvent {
  final User user;

  const AuthLoggedIn({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthLoggedOut extends AuthEvent {}

class AuthNeedsEmailVerification extends AuthEvent {
  final String email;

  const AuthNeedsEmailVerification({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthSignOut extends AuthEvent {}

/// Runs the startup sign-in check again, e.g. after loading the profile failed.
class AuthRetry extends AuthEvent {}
