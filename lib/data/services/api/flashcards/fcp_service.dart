import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards/data/services/api/exceptions/document_doesnt_exist_exception.dart';
import 'package:flashcards/data/utils/data_utils.dart';
import 'package:flashcards/data/remote/firestore_db_context.dart';
import 'package:flashcards/data/services/api/dto/flashcards/fcp_data/fcp_data_dto.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flashcards/utils/typedefs.dart';

class FcpService {
  final CollectionReference<JsonMap> _fcpData;

  FcpService({required FirestoreDbContext dbContext})
    : _fcpData = dbContext.fcpData;

  Future<Result<FcpDataDto>> getFcpDataDocument({
    required String profileId,
    required String flashcardId,
  }) async {
    try {
      final id = _constructId(profileId: profileId, flashcardId: flashcardId);
      final ref = _fcpData.doc(id);
      final snapshot = await ref.get();
      if (!snapshot.exists) {
        throw DocumentDoesntExistException();
      }

      final dto = FcpDataDto.fromJson(snapshot.data()!);
      return Result.ok(dto);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  /// One page of all the progress documents of the profile, for statistics.
  Future<Result<PaginatedDtoResult<FcpDataDto>>> getProfileDocsPagination({
    required String profileId,
    required bool hasCards,
    required DocumentSnapshot? startAfter,
    required int limit,
  }) async {
    try {
      var query = _fcpData
          .where('profileId', isEqualTo: profileId)
          .orderBy(FieldPath.documentId)
          .limit(limit);
      if (!hasCards) {
        query = query.where('isPaid', isEqualTo: false);
      }
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      final snapshot = await query.get();
      final dtoList = <FcpDataDto>[];
      for (final doc in snapshot.docs) {
        try {
          dtoList.add(FcpDataDto.fromJson(doc.data()));
        } on Object {
          // An old or damaged document shouldn't hide all the statistics.
        }
      }
      return Result.ok(
        PaginatedDtoResult(
          items: dtoList,
          lastDocument: getLastDocFromSnapshot(snapshot),
        ),
      );
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<List<FcpDataDto>>> getDueCardsForPack(
    String profileId,
    String packId,
    int target,
    bool hasCards,
  ) async {
    try {
      var query = _fcpData
          .where("profileId", isEqualTo: profileId)
          .where("flashcardSnapshot.packId", isEqualTo: packId)
          .where("ignored", isEqualTo: false)
          .where("fsrs_card.due", isLessThanOrEqualTo: Timestamp.now())
          .orderBy("fsrs_card.due", descending: false)
          .limit(target);

      if (!hasCards) {
        query = query.where('isPaid', isEqualTo: false);
      }

      final snapshot = await query.get();

      var result =
          snapshot.docs.map((doc) => FcpDataDto.fromJson(doc.data())).toList();

      return Result.ok(result);
    } on Exception catch (error) {
      // rethrow;
      return Result.error(error);
    }
  }

  Future<Result<int>> countBookmarkedDocsForPacks(
    String profileId,
    List<String> packIds,
      bool hasCards,
  ) async {
    try {
      var query =
          _fcpData
              .where('flashcardSnapshot.packId', whereIn: packIds)
              .where('profileId', isEqualTo: profileId)
              .where('hasBookmark', isEqualTo: true);

      if(!hasCards) {
        query = query.where('isPaid', isEqualTo: false);
      }

      final snapshot = await query.count().get();
      if (snapshot.count == null) {
        return Result.error(Exception("No count found"));
      }

      return Result.ok(snapshot.count!);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<int>> countIgnoredDocsForPacks(
    String profileId,
    List<String> packIds,
      bool hasCards,
  ) async {
    try {
      var query =
          _fcpData
              .where('flashcardSnapshot.packId', whereIn: packIds)
              .where('profileId', isEqualTo: profileId)
              .where('ignored', isEqualTo: true);

      if (!hasCards) {
        query = query.where('isPaid', isEqualTo: false);
      }

      final snapshot = await query.count().get();
      if (snapshot.count == null) {
        return Result.error(Exception("No count found"));
      }

      return Result.ok(snapshot.count!);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<int>> countDocumentsForPacks(
    String profileId,
    List<String> packIds,
    bool hasCards,
  ) async {
    try {
      var query =
          _fcpData
              .where('flashcardSnapshot.packId', whereIn: packIds)
              .where('profileId', isEqualTo: profileId);

      if (!hasCards) {
        query = query.where('isPaid', isEqualTo: false);
      }

      final snapshot = await query.count().get();
      if (snapshot.count == null) {
        return Result.error(Exception("No count found"));
      }

      return Result.ok(snapshot.count!);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<int>> countDocumentsForProfileAndPack(
    String profileId,
    String packId,
    bool hasCards,
  ) async {
    try {
      var query = _fcpData
          .where("profileId", isEqualTo: profileId)
          .where("flashcardSnapshot.packId", isEqualTo: packId);

      if (!hasCards) {
        query = query.where('isPaid', isEqualTo: false);
      }

      final snapshot = await query.count().get();
      if (snapshot.count == null) {
        return Result.error(
          Exception("Count is null inside countDocumentsForProfileAndPack"),
        );
      }
      return Result.ok(snapshot.count!);
    } on Exception catch (error) {
      rethrow;
      return Result.error(error);
    }
  }

  /// Here we ask for 'hasCards' permission, if you are trying to access a paid pack and call this function
  /// it will return 0, since you don't have permission to access it.
  /// But 'hasCards' is important here because you can't sent request to count for free packs counts if you
  /// don't filter out by 'hasCards', because security rules will block that request.
  /// Security rules are not filters, they will block the request event if you are not trying to access the forbidden data
  Future<Result<MapEntry<String, int>>> countDueDocuments(
    String profileId,
    String packId,
    bool hasCards,
  ) async {
    try {
      var query = _fcpData
          .where('profileId', isEqualTo: profileId)
          .where('flashcardSnapshot.packId', isEqualTo: packId)
          .where('ignored', isEqualTo: false)
          .where('fsrs_card.due', isLessThanOrEqualTo: Timestamp.now());
          //.where('fsrs_card.state', isNotEqualTo: 'newState');

      if (!hasCards) {
        query = query.where('isPaid', isEqualTo: false);
      }

      final querySnapshot = await query.count().get();
      if (querySnapshot.count == null) {
        return Result.error(
          Exception("Count is null inside countDueCardsForToday"),
        );
      }
      return Result.ok(MapEntry(packId, querySnapshot.count!));
    } on Exception catch (error) {
      //rethrow;
      return Result.error(error);
    }
  }

  /// Here we ask for 'hasCards' permission, if you are trying to access a paid pack and call this function
  /// it will return 0, since you don't have permission to access it.
  /// But 'hasCards' is important here because you can't sent request to count for free packs counts if you
  /// don't filter out by 'hasCards', because security rules will block that request.
  /// Security rules are not filters, they will block the request event if you are not trying to access the forbidden data
  Future<Result<MapEntry<String, int>>> countLearningDocuments(
    String profileId,
    String packId,
    bool hasCards,
  ) async {
    try {
      var query = _fcpData
          .where('profileId', isEqualTo: profileId)
          .where('flashcardSnapshot.packId', isEqualTo: packId)
          .where('ignored', isEqualTo: false)
          .where('fsrs_card.state', whereIn: ['learning', 'relearning']);

      if (!hasCards) {
        query = query.where('isPaid', isEqualTo: false);
      }

      final snapshot = await query.count().get();
      if (snapshot.count == null) {
        return Result.error(
          Exception("Count is null inside countOverdueDocuments"),
        );
      }

      return Result.ok(MapEntry(packId, snapshot.count!));
    } on Exception catch (error) {
      //rethrow;
      return Result.error(error);
    }
  }

  /// Here we ask for 'hasCards' permission, if you are trying to access a paid pack and call this function
  /// it will return 0, since you don't have permission to access it.
  /// But 'hasCards' is important here because you can't sent request to count for free packs counts if you
  /// don't filter out by 'hasCards', because security rules will block that request.
  /// Security rules are not filters, they will block the request event if you are not trying to access the forbidden data
  Future<Result<MapEntry<String, int>>> countSeenDocuments(
    String profileId,
    String packId,
    bool hasCards,
  ) async {
    try {
      var query = _fcpData
          .where('profileId', isEqualTo: profileId)
          .where('flashcardSnapshot.packId', isEqualTo: packId);

      if (!hasCards) {
        query = query.where('isPaid', isEqualTo: false);
      }

      final snapshot = await query.count().get();
      if (snapshot.count == null) {
        return Result.error(
          Exception("Count is null inside countOverdueDocuments"),
        );
      }

      return Result.ok(MapEntry(packId, snapshot.count!));
    } on Exception catch (error) {
      //rethrow;
      return Result.error(error);
    }
  }

  Future<Result<List<FcpDataDto>>> getDueDocsWithBookmark(
    String profileId,
    int target,
    bool hasCards,
  ) async {
    try {
      var query = _fcpData
          .where("profileId", isEqualTo: profileId)
          .where("hasBookmark", isEqualTo: true)
          .where("ignored", isEqualTo: false)
          .where("fsrs_card.due", isLessThanOrEqualTo: Timestamp.now())
          .orderBy("fsrs_card.due", descending: false)
          .limit(target);

      if (!hasCards) {
        query = query.where('isPaid', isEqualTo: false);
      }

      final snapshot = await query.get();

      final list =
          snapshot.docs.map((doc) => FcpDataDto.fromJson(doc.data())).toList();
      return Result.ok(list);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Future<Result<List<FcpDataDto>>> getNewStateDocsWithBookmark(
  //   String profileId,
  //   int target,
  //   bool hasCards,
  // ) async {
  //   try {
  //     var query = _fcpData
  //         .where("profileId", isEqualTo: profileId)
  //         .where("hasBookmark", isEqualTo: true)
  //         .where("ignored", isEqualTo: false)
  //         .where("fsrs_card.state", isEqualTo: "newState")
  //         .limit(target);
  //
  //     if (!hasCards) {
  //       query = query.where('isPaid', isEqualTo: false);
  //     }
  //
  //     final snapshot = await query.get();
  //
  //     final list =
  //         snapshot.docs.map((doc) => FcpDataDto.fromJson(doc.data())).toList();
  //     return Result.ok(list);
  //   } on Exception catch (error) {
  //     return Result.error(error);
  //   }
  // }

  Future<Result<PaginatedDtoResult<FcpDataDto>>> getDocsWithBookmarkPagination({
    required String profileId,
    required DocumentSnapshot? startAfter,
    required int limit,
    required bool hasCards,
  }) async {
    try {
      var query = _fcpData
          .where("profileId", isEqualTo: profileId)
          .where("hasBookmark", isEqualTo: true)
          .orderBy("flashcardSnapshot.question")
          .limit(limit);

      if (!hasCards) {
        query = query.where('isPaid', isEqualTo: false);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      final dtoList =
          snapshot.docs.map((doc) => FcpDataDto.fromJson(doc.data())).toList();

      return Result.ok(
        PaginatedDtoResult(
          items: dtoList,
          lastDocument: getLastDocFromSnapshot(snapshot),
        ),
      );
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<PaginatedDtoResult<FcpDataDto>>> getIgnoredCardsPagination({
    required String profileId,
    required DocumentSnapshot? startAfter,
    required int limit,
    required bool hasCards,
  }) async {
    try {
      var query = _fcpData
          .where('profileId', isEqualTo: profileId)
          .where('ignored', isEqualTo: true)
          .orderBy('flashcardSnapshot.question')
          .limit(limit);

      if (!hasCards) {
        query = query.where('isPaid', isEqualTo: false);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();

      final dtoList =
          snapshot.docs.map((doc) => FcpDataDto.fromJson(doc.data())).toList();

      final result = PaginatedDtoResult(
        items: dtoList,
        lastDocument: getLastDocFromSnapshot(snapshot),
      );

      return Result.ok(result);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  /// With [merge], fields already in the document but not in [dto] are kept.
  Future<Result<void>> setDocument(FcpDataDto dto, {bool merge = false}) async {
    try {
      final ref = _fcpData.doc("${dto.profileId}_${dto.flashcardId}");
      await ref.set(dto.toJson(), merge ? SetOptions(merge: true) : null);
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> updateDocument(
    String profileId,
    String flashcardId,
    JsonMap partialJson,
  ) async {
    try {
      final ref = _fcpData.doc("${profileId}_$flashcardId");
      await ref.update(partialJson);
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  void addSetCardToBatch(WriteBatch batch, FcpDataDto dto) {
    final docRef = _fcpData.doc("${dto.profileId}_${dto.flashcardId}");
    batch.set(docRef, dto.toJson(), SetOptions(merge: true));
  }

  String _constructId({
    required String profileId,
    required String flashcardId,
  }) {
    return '${profileId}_$flashcardId';
  }
}
