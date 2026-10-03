import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards/data/remote/cloud_function_service.dart';
import 'package:flashcards/data/services/api/dto/flashcards/custom_session/flashcard_ids/flashcard_ids_dto.dart';
import 'package:flashcards/data/services/api/dto/flashcards/pack/update_pack/update_pack_dto.dart';
import 'package:flashcards/data/utils/data_utils.dart';
import 'package:flashcards/data/remote/firestore_db_context.dart';
import 'package:flashcards/data/services/api/dto/flashcards/pack/pack_dto.dart';
import 'package:flashcards/data/services/api/exceptions/document_doesnt_exist_exception.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flashcards/utils/typedefs.dart';

class PackService {
  final CollectionReference<JsonMap> _packs;
  final WriteBatch Function() _createBatch;
  final CollectionReference<JsonMap> Function(String packId)
  _getFlashcardIdsCollection;

  final CloudFunctionService _functions;

  final String _flashcardIdsDocName;

  PackService({
    required FirestoreDbContext dbContext,
    required CloudFunctionService functions,
  }) : _packs = dbContext.packs,
       _functions = functions,
       _createBatch = dbContext.createBatch,
       _getFlashcardIdsCollection = dbContext.getPacksFlashcardIdsCollection,
       _flashcardIdsDocName = dbContext.flashcardIdsDocName;

  DocumentReference<JsonMap> getDocumentReference(String packId) {
    return _packs.doc(packId);
  }

  DocumentReference<JsonMap> generateDocumentReference() {
    return _packs.doc();
  }

  Future<Result<PaginatedDtoResult<PackDto>>> getDocsPagination(
    DocumentSnapshot? startAfter,
    int limit, {
    bool onlyFreePacks = false,
  }) async {
    try {
      var query = _packs.orderBy('name').limit(limit);
      if (onlyFreePacks) {
        query = query.where('isPaid', isEqualTo: false);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      final dtoList =
          snapshot.docs
              .map((doc) => PackDto.fromJsonWithId(doc.data(), doc.id))
              .toList();

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

  Future<Result<PackDto>> getDocument(String packId) async {
    try {
      final snapshot = await _packs.doc(packId).get();
      if (!snapshot.exists) {
        return Result.error(Exception("Pack doesn't exist"));
      }
      var dto = PackDto.fromJsonWithId(snapshot.data()!, snapshot.id);
      return Result.ok(dto);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<FlashcardIdsDto>> getFlashcardIds(String packId) async {
    try {
      final ref = _getFlashcardIdsCollection(packId);
      final snapshot = await ref.doc(_flashcardIdsDocName).get();
      if (!snapshot.exists) {
        throw Exception("All_ids document doesn't exist");
      }

      final dto = FlashcardIdsDto.fromJson(snapshot.data()!);

      return Result.ok(dto);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> setPackPremium(String packId, bool isPaid) async {
    try {
      await _functions.setPackPremium(packId, isPaid);
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> renamePackEverywhere(
    String packId,
    String packName,
  ) async {
    try {
      await _functions.renamePackEverywhere(packId, packName);

      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> setDocument(PackDto dto) async {
    try {
      final ref = _packs.doc();

      return await setDocumentWithReference(dto, ref);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> setDocumentWithReference(
    PackDto dto,
    DocumentReference ref,
  ) async {
    try {
      final batch = _createBatch();

      // create the main document first
      batch.set(ref, dto.toJson());

      // create subcollection with one document "all_ids"
      // that has all of the flashcardIds
      final subcollectionRef = _getFlashcardIdsCollection(
        ref.id,
      ).doc(_flashcardIdsDocName);
      batch.set(subcollectionRef, FlashcardIdsDto(flashcardIds: []).toJson());

      await batch.commit();
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> updateDocument(String packId, UpdatePackDto dto) async {
    final ref = getDocumentReference(packId);
    return await updateDocumentWithRef(ref, dto);
  }

  Future<Result<void>> updateDocumentWithRef(
    DocumentReference<JsonMap> packRef,
    UpdatePackDto dto,
  ) async {
    try {
      final batch = _createBatch();

      batch.update(packRef, dto.toJson());

      final flashcardIdsPatch = dto.flashcardIdsPatchDto;
      if (flashcardIdsPatch != null) {
        final idsRef = _getFlashcardIdsCollection(
          packRef.id,
        ).doc(_flashcardIdsDocName);
        batch.update(idsRef, flashcardIdsPatch.toJson());
      }

      await batch.commit();
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> deletePackEverywhereIfEmpty(String packId) async {
    try {
      await _functions.deletePackEverywhereIfEmpty(packId);

      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // transactions
  Future<PackDto> getDocumentInTransaction(
    DocumentReference<JsonMap> docRef,
    Transaction transaction,
  ) async {
    final snapshot = await transaction.get(docRef);
    if (!snapshot.exists) {
      throw DocumentDoesntExistException();
    }
    final dto = PackDto.fromJson(snapshot.data()!);
    return dto;
  }

  Future<FlashcardIdsDto> getFlashcardIdsInTransaction(
    String packId,
    Transaction transaction,
  ) async {
    final ref = _getFlashcardIdsCollection(packId).doc(_flashcardIdsDocName);
    final snapshot = await transaction.get(ref);
    if (!snapshot.exists) {
      throw DocumentDoesntExistException();
    }
    final dto = FlashcardIdsDto.fromJson(snapshot.data()!);
    return dto;
  }

  void updateDocumentInTransaction({
    required DocumentReference<JsonMap> packRef,
    required UpdatePackDto dto,
    required Transaction transaction,
  }) {
    transaction.update(packRef, dto.toJson());

    final flashcardIdsPatch = dto.flashcardIdsPatchDto;
    if (flashcardIdsPatch != null) {
      final idsRef = _getFlashcardIdsCollection(
        packRef.id,
      ).doc(_flashcardIdsDocName);
      transaction.update(idsRef, flashcardIdsPatch.toJson());
    }
  }

  void deleteDocumentInTransaction(
    DocumentReference<JsonMap> docRef,
    Transaction transaction,
  ) {
    transaction.delete(docRef);
  }
}
