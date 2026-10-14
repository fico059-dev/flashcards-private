import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flashcards/utils/result.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? getCurrentUser() => _firebaseAuth.currentUser;

  Stream<User?> userChanges() => _firebaseAuth.userChanges();

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  Stream<User?> idTokenChanges() => _firebaseAuth.idTokenChanges();

  /// Google or Apple, for signing in.
  static AuthProvider providerFor(String providerId) => switch (providerId) {
    'apple.com' =>
      AppleAuthProvider()
        ..addScope('email')
        ..addScope('name'),
    _ =>
      GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'}),
  };

  /// Signs in with Google ('google.com') or Apple ('apple.com'). A new
  /// account is created the first time.
  Future<Result<User>> signInWithProvider(String providerId) async {
    try {
      final provider = providerFor(providerId);
      final credential = kIsWeb
          ? await _firebaseAuth.signInWithPopup(provider)
          : await _firebaseAuth.signInWithProvider(provider);
      final user = credential.user;
      if (user == null) return Result.error(Exception('Sign-in cancelled'));
      // Apple gives the name only the first time.
      final name = credential.additionalUserInfo?.profile?['name'];
      if ((user.displayName ?? '').isEmpty && name is Map) {
        final full = [
          name['firstName'],
          name['lastName'],
        ].whereType<String>().join(' ').trim();
        if (full.isNotEmpty) await user.updateDisplayName(full);
      }
      return Result.ok(user);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  /// Whether the user signs in with a password (else Google or Apple).
  bool get hasPassword =>
      _firebaseAuth.currentUser?.providerData.any(
        (p) => p.providerId == 'password',
      ) ??
      false;

  /// Google or Apple, when the user signs in with one of them.
  String? get socialProviderId {
    final ids =
        _firebaseAuth.currentUser?.providerData.map((p) => p.providerId) ??
        const <String>[];
    for (final id in ['google.com', 'apple.com']) {
      if (ids.contains(id)) return id;
    }
    return null;
  }

  /// Confirms it's really the user (before deleting the account) by
  /// signing in with Google or Apple again.
  Future<Result<void>> reauthenticateWithProvider() async {
    try {
      final user = _firebaseAuth.currentUser;
      final providerId = socialProviderId;
      if (user == null || providerId == null) {
        return Result.error(Exception("User is not logged in"));
      }
      final provider = providerFor(providerId);
      if (kIsWeb) {
        await user.reauthenticateWithPopup(provider);
      } else {
        await user.reauthenticateWithProvider(provider);
      }
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<User>> register({
    required String email,
    required String password,
  }) async {
    try {
      var credentials = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.ok(credentials.user!);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> updateDisplayName(User user, String displayName) async {
    try {
      await user.updateDisplayName(displayName);
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> updatePassword(User user, String password) async {
    try {
      await user.updatePassword(password);
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<User>> verifyBeforeUpdateEmail(String email) async {
    try {
      var user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.error(Exception("Current user is null"));
      }

      await user.verifyBeforeUpdateEmail(email);
      return Result.ok(user);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      var credentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.ok(credentials.user!);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<User>> sendEmailVerification() async {
    try {
      var user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.error(Exception("User is not logged in"));
      }

      await user.sendEmailVerification();
      return Result.ok(user);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> reauthenticateWithCredential(String password) async {
    try {
      var user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.error(Exception("User is not logged in"));
      }
      var credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<User>> deleteAccount() async {
    try {
      var user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.error(Exception("Current user is null"));
      }

      await _firebaseAuth.currentUser!.delete();
      return Result.ok(user);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
