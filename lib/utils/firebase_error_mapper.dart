import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flashcards/l10n/app_localizations.dart';

class FirebaseErrorData {
  final String message;
  final bool requiresReauthentication;

  FirebaseErrorData({
    required this.message,
    this.requiresReauthentication = false,
  });
}

String extractErrorMessage(Object error) {
  if (error is TimeoutException) {
    return error.message ?? 'The connection timed out, please try again.';
  }

  if (error is FirebaseFunctionsException) {
    return error.message ?? 'Unknown Firebase Functions error';
  }

  if (error is FirebaseException) {
    // FirebaseAuth, FirebaseFirestore, etc. all extend FirebaseException
    return error.message ?? 'Unknown Firebase error';
  }

  if (error is PlatformException) {
    // Sometimes seen in Auth or native calls
    return error.message ?? 'Unknown platform error';
  }

  if (error is Exception) {
    return error.toString().replaceFirst("Exception: ", "");
  }

  return 'Unknown error: $error';
}

bool doesErrorRequireReauth(dynamic error) {
  return error is FirebaseAuthException &&
      error.code == "requires-recent-login";
}

FirebaseErrorData mapFirebaseError({
  required dynamic error,
  required BuildContext context,
}) {
  final locale = AppLocalizations.of(context);

  print(error);

  if (error is! FirebaseAuthException) {
    return FirebaseErrorData(message: extractErrorMessage(error));
  }

  print("Firebase code: ${error.code}");
  switch (error.code) {
    case "requires-recent-login":
      return FirebaseErrorData(
        message:
            // "For security reasons, please reauthenticate to perform this action.",
            locale!.error_requiresRecentLogin,
        requiresReauthentication: true,
      );
    case "invalid-email":
      return FirebaseErrorData(message: locale!.error_invalidEmail);
    case "user-disabled":
      return FirebaseErrorData(message: locale!.error_userDisabled);
    case "user-not-found":
      return FirebaseErrorData(message: locale!.error_userNotFound);
    case "wrong-password":
      return FirebaseErrorData(message: locale!.error_wrongPassword);
    case "too-many-requests":
      return FirebaseErrorData(message: locale!.error_tooManyRequests);
    case "user-token-expired":
      return FirebaseErrorData(message: locale!.error_tokenExpired);
    case "network-request-failed":
      return FirebaseErrorData(message: locale!.error_networkIssue);
    case "invalid-credential":
      return FirebaseErrorData(message: locale!.error_invalidCredential);
    case "operation-not-allowed":
      return FirebaseErrorData(message: locale!.error_operationNotAllowed);
    // register error codes
    case "email-already-in-use":
      return FirebaseErrorData(message: locale!.error_emailAlreadyInUse);
    case "weak-password":
      return FirebaseErrorData(
        message: error.toString().replaceAll(RegExp(r'\[.*?\]'), ''),
      );
    default:
      // Include the code so unexpected failures can be diagnosed.
      final authFailed = "${locale!.error_authFailed} (${error.code})";
      if (error.message == null) {
        return FirebaseErrorData(message: authFailed);
      }

      if (error.message!.contains("Password must contain")) {
        return FirebaseErrorData(
          message: _extractFirstPasswordRequirement(
            message: error.message!,
            context: context,
          ),
        );
      } else if (error.message!.contains("INVALID_NEW_EMAIL")) {
        return FirebaseErrorData(message: "Invalid email format.");
      }

      return FirebaseErrorData(message: "$authFailed\n${error.message}");
  }

  // Additional password validation cases
  //   case "Password must contain a non-alphanumeric character":
  //   message =
  //   AppLocalizations.of(
  //   context,
  //   )!.error_passwordNonAlphanumeric;
  //   break;
  //   case "Password must contain at least 8 characters":
  //   message =
  //   AppLocalizations.of(
  //   context,
  //   )!.error_passwordEightCharacters;
  //   break;
  //   case "Password must contain an upper case character":
  //   message =
  //   AppLocalizations.of(context)!.error_passwordUpperCase;
  //   break;
  //   case "Password must contain a numeric character":
  //   message = AppLocalizations.of(context)!.error_passwordNumeric;
  //   break;
  //
  //   default:
  //   message = AppLocalizations.of(context)!.error_unexpected;
  // }
}

String _extractFirstPasswordRequirement({
  required String message,
  required BuildContext context,
}) {
  final locale = AppLocalizations.of(context);

  final RegExp regex = RegExp(r'\[(.*?)]'); // Match text inside brackets
  final Match? match = regex.firstMatch(message);

  if (match != null) {
    String extractedText = match.group(1) ?? "";
    List<String> requirements = extractedText.split(", "); // Split by comma
    return requirements.isNotEmpty
        ? requirements.first
        : locale!.error_passwordRequirement;
  }

  return locale!.error_passwordRequirement;
}

// switch (errorMessage) {
// case "For security reasons, please reauthenticate to perform this action.":
// message =
// AppLocalizations.of(context)!.error_requiresRecentLogin;
// break;
// case "Invalid email format.":
// message = AppLocalizations.of(context)!.error_invalidEmail;
// break;
// case "User with that email is disabled.":
// message = AppLocalizations.of(context)!.error_userDisabled;
// break;
// case "No account found with that email.":
// message = AppLocalizations.of(context)!.error_userNotFound;
// break;
// case "Incorrect password. Try again.":
// message = AppLocalizations.of(context)!.error_wrongPassword;
// break;
// case "You've send too many requests, try again later":
// message = AppLocalizations.of(context)!.error_tooManyRequests;
// break;
// case "Session expired, please log in again.":
// message = AppLocalizations.of(context)!.error_tokenExpired;
// break;
// case "There is a problem with the network, please check your internet connection":
// message = AppLocalizations.of(context)!.error_networkIssue;
// break;
// case "Invalid credentials, please try again":
// message =
// AppLocalizations.of(context)!.error_invalidCredential;
// break;
// case "There is a problem with firebase auth, please contact the developer":
// message =
// AppLocalizations.of(context)!.error_operationNotAllowed;
// break;
// case "That email is already in use, try another one.":
// message =
// AppLocalizations.of(context)!.error_emailAlreadyInUse;
// break;
// case "Authentication failed. Please try again.":
// message = AppLocalizations.of(context)!.error_authFailed;
// break;
// case "An unexpected error occurred. Please try again.":
// message = AppLocalizations.of(context)!.error_unexpected;
// break;
// case "Password does not meet security requirements.":
// message =
// AppLocalizations.of(context)!.error_passwordRequirement;
// break;
//
// // Additional password validation cases
// case "Password must contain a non-alphanumeric character":
// message =
// AppLocalizations.of(
// context,
// )!.error_passwordNonAlphanumeric;
// break;
// case "Password must contain at least 8 characters":
// message =
// AppLocalizations.of(
// context,
// )!.error_passwordEightCharacters;
// break;
// case "Password must contain an upper case character":
// message =
// AppLocalizations.of(context)!.error_passwordUpperCase;
// break;
// case "Password must contain a numeric character":
// message = AppLocalizations.of(context)!.error_passwordNumeric;
// break;
//
// default:
// message = AppLocalizations.of(context)!.error_unexpected;
// }
