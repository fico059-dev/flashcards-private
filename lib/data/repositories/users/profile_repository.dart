import 'package:flashcards/data/remote/cloud_function_service.dart';
import 'package:flashcards/data/repositories/utils/user_claims.dart';
import 'package:flashcards/data/services/api/dto/users/profile/profile_dto.dart';
import 'package:flashcards/data/services/api/dto/users/profile/update_profile/update_profile_dto.dart';
import 'package:flashcards/data/services/api/users/auth_service.dart';
import 'package:flashcards/domain/models/profile/education_level.dart';
import 'package:flashcards/domain/models/profile/profile_settings/profile_settings.dart';
import 'package:flashcards/domain/models/profile/streak/streak.dart';
import '../../../domain/models/profile/profile.dart';
import '../../../utils/result.dart';
import '../../services/api/users/profile_service.dart';

class ProfileRepository {
  final ProfileService _profileService;
  final AuthService _authService;
  final CloudFunctionService _functions;

  int _cardsDoneToday = 0;
  bool _cardsTodayStarted = false;
  final _cardsRequiredForStreakIncrement = 3;

  ProfileRepository({
    required ProfileService profileService,
    required AuthService authService,
    required CloudFunctionService functions,
  }) : _profileService = profileService,
       _functions = functions,
       _authService = authService;

  Future<Result<void>> createDefaultProfile() async {
    final user = _authService.getCurrentUser();
    if (user == null) {
      throw Exception("User is null");
    }

    // Accounts made with Google or Apple: use the name they give.
    final email = user.email ?? "";
    final emailName = email.contains('@') ? email.split('@').first : '';
    final parts = (user.displayName ?? '').trim().split(RegExp(r'\s+'))
      ..removeWhere((part) => part.isEmpty);
    final name = parts.isNotEmpty
        ? parts.first
        : (emailName.isNotEmpty ? emailName : "FlashPedz");
    final surname = parts.length > 1 ? parts.skip(1).join(' ') : "User";
    final profile = Profile(
      name: name,
      surname: surname,
      username: emailName.isNotEmpty ? emailName : "$name $surname",
      email: email.isEmpty ? "unknown email" : email,
      phoneNumber: "",
      educationLevel: EducationLevel.medicalStudent,
      streak: Streak(count: 1, lastStreakDate: DateTime.now()),
      profileSettings: ProfileSettings(),
    );

    return await _profileService.setDocument(
      user.uid,
      ProfileDto.fromDomain(profile),
    );
  }

  Future<Result<Profile>> getCurrentProfile() async {
    final user = _authService.getCurrentUser();
    if (user == null) {
      throw Exception(
        "User is not logged in inside getCurrentProfile function",
      );
    }

    try {
      final result = await _profileService.getDocument(user.uid);
      switch (result) {
        case Error<ProfileDto>(error: var error):
          return Result.error(error);
        case Ok<ProfileDto>():
      }

      final token = await user.getIdTokenResult();
      final claims = UserClaims.fromMap(token.claims);

      return Result.ok(result.value.toDomain(claims.roles));
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  /// Call this every time user completes some flashcard. It required that you called
  /// checkAndStartStreak() first because that function will set the bool value so that
  /// this function can start counting. It will increase the count if the counting is started
  /// and when it reaches 10 it will increment streak and update the db, sending the updated
  /// streak back to the called to signalize that streak is updated so that the called can
  /// update it locally through ProfileReaderBloc. Also every time it increases count it will
  /// also check if the date of the current streak is yesterday, if it's not due to next card
  /// completing after 00:00 it will reset the streak and send the newStreak to the called.
  Future<Result<Streak?>> checkAndIncrementCardsCount(Streak streak) async {
    if (!_cardsTodayStarted) {
      print("increment called but nothing to increment, exiting...");
      return Result.ok(null);
    }

    // we still need to check if the streak date is previous in order to increment count
    // if not we need to reset the the streak
    final last = streak.lastStreakDate.toDateOnly();
    final today = DateTime.now().toDateOnly();
    final yesterday = today.subtract(Duration(days: 1));

    if (last.isBefore(yesterday)) {
      print("Streak is too old in increment method, we need to reset it");
      final newStreak = Streak(count: 0, lastStreakDate: yesterday);
      final result = await updateCurrentProfile(
        UpdateProfileDto(streak: newStreak),
      );
      switch (result) {
        case Error<void>(:final error):
          return Result.error(error);
        case Ok<void>():
      }

      _cardsTodayStarted = true;
      return Result.ok(newStreak);
    }

    _cardsDoneToday += 1;
    if (_cardsDoneToday < _cardsRequiredForStreakIncrement) {
      print("Cards done today incremented, but it didn't reach 10, exiting...");
      return Result.ok(null);
    }

    print("Cards done today is more then 10, incrementing the streak now...");
    final newStreak = Streak(
      count: streak.count + 1,
      lastStreakDate: DateTime.now(),
    );
    final result = await updateCurrentProfile(
      UpdateProfileDto(streak: newStreak),
    );
    switch (result) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }

    _cardsTodayStarted = false;
    return Result.ok(newStreak);
  }

  /// Call this to check when you want to check streak. Meaning when you open a
  /// pack or when you open an app. It will check the streak date with today and
  /// determine weather to start counting completed cards so that we can increase
  /// the streak. Or it will call the db to reset the streak if the user missed the streak.
  /// Now since it only calls the db it will signal the called with returned new Streak value
  /// that the streak is reset and that the called needs to update the profile data locally.
  /// That is usually done through ProfileReaderBloc.
  /// To start counting the completed cards you use checkAndIncrementCardsCount()
  Future<Result<Streak?>> checkAndStartStreak(Streak streak) async {
    print("Starting streak");

    final last = streak.lastStreakDate.toDateOnly();
    final today = DateTime.now().toDateOnly();
    final yesterday = today.subtract(Duration(days: 1));

    // If the streak is updated today, don't do anything
    if (last == today) {
      print("Streak updated today, exiting");
      _cardsTodayStarted = false;
      return Result.ok(null);
    }
    // If the streak is updated yesterday, we start counting the completed flashcards
    // so that we can increase the streak later
    if (last == yesterday) {
      print("Streak started yesterday, we need to start counting");
      _cardsTodayStarted = true;
      return Result.ok(null);
    }

    // if the streak is older than yesterday it means user missed the streak and
    // we need to reset it to 0 and also start counting to increase the streak to 1 today
    // we also set the streak date to yesterday to mimic the effect of it needing to update today
    print("Streak is too old, we need to reset it");
    final newStreak = Streak(count: 0, lastStreakDate: yesterday);
    final result = await updateCurrentProfile(
      UpdateProfileDto(streak: newStreak),
    );
    switch (result) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }

    _cardsTodayStarted = true;
    return Result.ok(newStreak);
  }

  // TODO If update display name fails we should revert changes in profile, that should happen very rarely though
  Future<Result<void>> updateCurrentProfile(
    UpdateProfileDto updateProfileDto,
  ) async {
    //print("Updating profile");
    final user = _authService.getCurrentUser();
    if (user == null) {
      throw Exception(
        "User is not logged in inside updateCurrentProfile function",
      );
    }

    final result = await _profileService.updateDocument(
      user.uid,
      updateProfileDto.toJson(),
    );

    switch (result) {
      case Error<void>(error: var error):
        return Result.error(error);
      case Ok<void>():
    }

    final currDisplayName = user.displayName ?? "";
    // print(currDisplayName);
    final currentName = user.displayName?.split(" ").firstOrNull ?? "";
    final currentSurname = user.displayName?.split(" ").firstOrNull ?? "";
    // print(currentName);
    // print(currentSurname);

    final newName = updateProfileDto.name ?? currentName;
    final newSurname = updateProfileDto.surname ?? currentSurname;
    // print(newName);
    // print(newSurname);
    // final newDisplayName = "$newName $newSurname";
    final newDisplayName = newName;
    // print(newDisplayName);

    if (currDisplayName != newDisplayName) {
      final displayNameResult = await _authService.updateDisplayName(
        user,
        newDisplayName,
      );
      switch (displayNameResult) {
        case Ok<void>():
          return Result.ok(null);
        case Error<void>():
      }

      // revert old changes, it needs to be transaction actually I think in order to make this work properly
      // for now I don't care :)
      return Result.error(displayNameResult.error);
    }

    return Result.ok(null);
  }

  Future<Result<void>> deleteUserAndUserData(String password) async {
    final reauthResult = await _authService.reauthenticateWithCredential(
      password,
    );
    switch (reauthResult) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }

    final deleteRes = await _functions.deleteUserAndUserData();
    switch (deleteRes) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }

    // log out user
    final signOutResult = await _authService.signOut();
    switch (signOutResult) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }
    return Result.ok(null);
  }
}

extension DateTimeX on DateTime {
  DateTime toDateOnly() => DateTime(year, month, day);
}
