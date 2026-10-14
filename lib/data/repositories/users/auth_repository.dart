import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcards/data/services/api/dto/users/profile/profile_dto.dart';
import 'package:flashcards/data/services/api/users/auth_service.dart';
import 'package:flashcards/data/services/api/users/profile_service.dart';
import 'package:flashcards/domain/models/profile/profile.dart';
import 'package:flashcards/utils/result.dart';

class AuthRepository {
  final AuthService _authService;
  final ProfileService _profileService;
  final void Function() _invalidateAllCaches;

  AuthRepository({
    required AuthService authService,
    required ProfileService profileService,
    required void Function() invalidateAllCaches,
  }) : _authService = authService,
       _profileService = profileService,
       _invalidateAllCaches = invalidateAllCaches;

  User? getCurrentUser() => _authService.getCurrentUser();

  Stream<User?> authStateChanges() => _authService.authStateChanges();

  Stream<User?> userChanges() => _authService.userChanges();

  Stream<User?> idTokenChanges() => _authService.idTokenChanges();

  Future<Result<String>> register(
    String email,
    String password,
    Profile profile,
  ) async {
    try {
      var authResult = await _authService.register(
        email: email,
        password: password,
      );

      switch (authResult) {
        case Error<User>(error: var error):
          return Result.error(error);
        case Ok<User>():
      }

      final user = authResult.value;
      var profileResult = await _profileService.setDocument(
        user.uid,
        ProfileDto.fromDomain(profile),
      );

      switch (profileResult) {
        case Error<void>(error: var error):
          // delete auth user. Register operation must be atomic
          await user.delete();
          return Result.error(error);
        case Ok<void>():
      }

      await _authService.updateDisplayName(user, profile.name);
      await user.reload();
      //await _authService.signOut();
      return Result.ok(profile.name);
      //return Result.ok(_authService.getCurrentUser() ?? user);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  /// Signs in with Google ('google.com') or Apple ('apple.com'). The
  /// profile of a new account is made when the app loads it.
  Future<Result<User>> signInWithProvider(String providerId) =>
      _authService.signInWithProvider(providerId);

  bool get hasPassword => _authService.hasPassword;

  String? get socialProviderId => _authService.socialProviderId;

  Future<Result<void>> reauthenticateWithProvider() =>
      _authService.reauthenticateWithProvider();

  Future<Result<User>> login(String email, String password) async {
    return _authService.login(email: email, password: password);
  }

  Future<Result<void>> signOut() async {
    // invalidate all caches
    _invalidateAllCaches();
    return await _authService.signOut();
  }

  Future<Result<User>> sendEmailVerification() async {
    return await _authService.sendEmailVerification();
  }

  Future<Result<User>> verifyBeforeUpdateEmail(String email) async {
    return await _authService.verifyBeforeUpdateEmail(email);
  }

  Future<Result<void>> reauthenticateWithCredential(String password) async {
    return await _authService.reauthenticateWithCredential(password);
  }

  Future<Result<User>> reloadUser() async {
    try {
      var user = _authService.getCurrentUser();
      if (user == null) {
        return Result.error(Exception("Current user is null"));
      }

      await user.reload();
      return Result.ok(user);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> sendResetPasswordEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }

  Future<Result<void>> updatePassword(String password) async {
    var user = _authService.getCurrentUser();
    if (user == null) return Result.error(Exception("Current user is empty"));

    return await _authService.updatePassword(user, password);
  }
}
