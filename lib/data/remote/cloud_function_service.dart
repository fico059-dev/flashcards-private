import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcards/data/mappers/uint8list_converter.dart';
import 'package:flashcards/data/services/api/dto/flashcards/flashcard/flashcard_dto.dart';
import 'package:flashcards/data/services/api/dto/requests/create_custom_session/create_custom_session_request_dto.dart';
import 'package:flashcards/utils/typedefs.dart';
import 'package:flashcards/utils/result.dart' as res;

class CloudFunctionService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<HttpsCallableResult> createCustomSession(
    CreateCustomSessionRequestDto request,
  ) async {
    return await _functions
        .httpsCallable("createCustomSession")
        .call(request.toJson());
  }

  /// Returns the name that was saved.
  Future<String> renameCustomSession({
    required String sessionId,
    required String name,
  }) async {
    final result = await _functions
        .httpsCallable('renameCustomSession')
        .call(<String, dynamic>{'sessionId': sessionId, 'name': name});
    return (result.data as Map)['name'] as String;
  }

  Future<void> deleteFlashcardEverywhere(FlashcardDto flashcardDto) async {
    final callable = _functions.httpsCallable('deleteFlashcardEverywhere');
    await callable.call(<String, dynamic>{
      'flashcard': flashcardDto.toJsonWithId(),
    });
  }

  Future<void> updateFlashcardEverywhere({
    required String flashcardId,
    required JsonMap partialJson,
    required bool shouldDeleteQuestion,
    required bool shouldDeleteAnswer,
    required Uint8List? answerImageBytes,
    required Uint8List? questionImageBytes,
  }) async {
    final callable = _functions.httpsCallable("updateFlashcardEverywhere");
    final data = <String, dynamic>{
      "flashcardId": flashcardId,
      "updateFlashcardDto": partialJson,
      "shouldDeleteAnswer": shouldDeleteAnswer,
      "shouldDeleteQuestion": shouldDeleteQuestion,
    };

    if (answerImageBytes != null) {
      data["answerImageBase64"] = answerImageBytes.toJson();
    }

    if (questionImageBytes != null) {
      data["questionImageBase64"] = questionImageBytes.toJson();
    }

    //print(data);
    await callable.call(data);
  }

  Future<void> renamePackEverywhere(String packId, String packName) async {
    final callable = _functions.httpsCallable('renamePackEverywhere');
    await callable.call(<String, dynamic>{
      'packId': packId,
      'packName': packName,
    });
  }

  Future<void> setPackPremium(String packId, bool isPaid) async {
    final callable = _functions.httpsCallable('setPackPremium');
    await callable.call(<String, dynamic>{'packId': packId, 'isPaid': isPaid});
  }

  Future<void> deletePackWithCards(String packId) async {
    final callable = _functions.httpsCallable(
      'deletePackWithCards',
      options: HttpsCallableOptions(timeout: const Duration(minutes: 9)),
    );
    await callable.call(<String, dynamic>{'packId': packId});
  }

  Future<void> deletePackEverywhereIfEmpty(String packId) async {
    final callable = _functions.httpsCallable("deletePackEverywhereIfEmpty");
    await callable.call(<String, dynamic>{"packId": packId});
  }

  Future<void> deletePackProgress(String packId) async {
    final callable = _functions.httpsCallable('deletePackProgress');
    await callable.call(<String, dynamic>{'packId': packId});
  }

  Future<void> setAdminRole(String email) async {
    final callable = _functions.httpsCallable('addAdminRole');
    await callable.call(<String, dynamic>{'email': email});
  }

  Future<List<JsonMap>> listAdmins() async {
    final result = await _functions.httpsCallable('listAdmins').call();
    final admins = (result.data as Map)['admins'] as List;
    return admins.map((admin) => JsonMap.from(admin as Map)).toList();
  }

  Future<void> removeAdminRole(String uid) async {
    final callable = _functions.httpsCallable('removeAdminRole');
    await callable.call(<String, dynamic>{'uid': uid});
  }

  Future<res.Result<void>> deleteUserAndUserData() async {
    try {
      final callable = _functions.httpsCallable("deleteUserAndUserData");
      await callable.call();
      return res.Result.ok(null);
    } on Exception catch (error) {
      return res.Result.error(error);
    }
  }

  Future<void> devGrant({
    required String scope,
    int minutes = 120,
    String? targetUid,
  }) async {
    final uid = targetUid ?? FirebaseAuth.instance.currentUser!.uid;
    await _functions.httpsCallable('devGrant').call({
      'targetUid': uid,
      'scope': scope,
      'minutes': minutes,
    });
    await FirebaseAuth.instance.currentUser?.getIdToken(true);
  }

  Future<void> verifyPurchase({
    required String source,
    required String productId,
    required String verificationData,
  }) async {
    await _functions.httpsCallable('verifyPurchase').call({
      'source': source,
      'productId': productId,
      'verificationData': verificationData,
    });
    await FirebaseAuth.instance.currentUser?.getIdToken(true);
  }
}
