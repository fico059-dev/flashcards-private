import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards/data/services/api/dto/flashcards/custom_session/flashcard_ids/flashcard_ids_patch/flashcard_ids_patch_dto.dart';
import 'package:flashcards/data/services/api/dto/flashcards/fcp_data/fcp_data_dto.dart';
import 'package:flashcards/data/services/anki/anki_import_models.dart';
import 'package:flashcards/data/services/anki/anki_tags.dart';
import 'package:flashcards/data/services/api/dto/flashcards/pack/pack_dto.dart';
import 'package:flashcards/data/services/api/dto/flashcards/tag/tag_dto.dart';
import 'package:flashcards/data/utils/image_compression.dart';
import 'package:flashcards/data/services/api/exceptions/document_doesnt_exist_exception.dart';
import 'package:flashcards/data/services/api/flashcards/fcp_service.dart';
import 'package:flashcards/data/services/api/users/auth_service.dart';
import 'package:flashcards/data/utils/data_utils.dart';
import 'package:flashcards/data/repositories/utils/cache/data_cache/data_cache.dart';
import 'package:flashcards/data/repositories/utils/cache/page_cache/cached_page_pagination.dart';
import 'package:flashcards/data/repositories/utils/cache/page_cache/page_cache.dart';
import 'package:flashcards/data/repositories/utils/cache/page_cache/page_cache_map.dart';
import 'package:flashcards/data/services/api/dto/flashcards/flashcard/flashcard_dto.dart';
import 'package:flashcards/data/services/api/dto/flashcards/flashcard/update_flashcard/update_flashcard_dto.dart';
import 'package:flashcards/data/services/api/dto/flashcards/pack/update_pack/update_pack_dto.dart';
import 'package:flashcards/data/services/api/flashcards/flashcard_service.dart';
import 'package:flashcards/data/services/api/flashcards/pack_service.dart';
import 'package:flashcards/data/services/api/flashcards/tag_service.dart';
import 'package:flashcards/domain/models/core/image_data_wrapper.dart';
import 'package:flashcards/domain/models/core/picked_image.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/domain/models/flashcards/flashcard_review/flashcard_review.dart';
import 'package:flashcards/domain/models/flashcards/pack/pack.dart';
import 'package:flashcards/domain/models/flashcards/simple_pack/simple_pack.dart';
import 'package:flashcards/domain/models/flashcards/stat_record/stat_record.dart';
import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:fsrs/fsrs.dart';

class FlashcardImportSummary {
  final int imported;
  final int skippedDuplicates;
  final int failedImages;
  final Exception? error;

  const FlashcardImportSummary({
    this.imported = 0,
    this.skippedDuplicates = 0,
    this.failedImages = 0,
    this.error,
  });
}

class FlashcardRepository {
  final FlashcardService _flashcardService;
  final PackService _packService;
  final FcpService _fcpService;
  final TagService _tagService;
  final AuthService _authService;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DataCache<Tag> _tagCache;
  final PageCache<Pack> _packsCache;
  final PageCache<AdminPack> _adminPacksCache;

  // It maps flashcard id to the cache pages. That is how it's used inside
  // manage pack flashcards view
  final PageCacheMap<Flashcard> _adminPageCache = PageCacheMap(
    cacheDuration: Duration(minutes: 20),
    getId: (item) => item.id,
  );

  FlashcardRepository({
    required FlashcardService flashcardService,
    required PackService packService,
    required FcpService fcpService,
    required TagService tagService,
    required AuthService authService,
    required DataCache<Tag> tagCache,
    required PageCache<Pack> packCache,
    required PageCache<AdminPack> adminPacksCache,
  }) : _flashcardService = flashcardService,
       _packService = packService,
       _tagCache = tagCache,
       _tagService = tagService,
       _adminPacksCache = adminPacksCache,
       _authService = authService,
       _fcpService = fcpService,
       _packsCache = packCache;

  Future<Result<FlashcardReview>> getFlashcardReview(String flashcardId) async {
    final fcpResult = await _fcpService.getFcpDataDocument(
      profileId: _getUid(),
      flashcardId: flashcardId,
    );
    switch (fcpResult) {
      case Error<FcpDataDto>(:final error):
        if (error is! DocumentDoesntExistException) {
          return Result.error(error);
        }

        // if the fcpData doc is not found, we need to fetch flashcard and pack
        // then combine that into stat record and then into fc review.
        final result = await _getFlashcardAndPack(flashcardId);
        switch (result) {
          case Error<(Flashcard, SimplePack)>(:final error):
            return Result.error(error);
          case Ok<(Flashcard, SimplePack)>():
        }
        final (flashcard, pack) = result.value;
        final record = StatRecord(
          isPaid: pack.isPaid,
          packId: pack.packId,
          flashcardId: flashcardId,
          card: Card(),
          flashcard: flashcard,
        );
        final review = FlashcardReview(
          packName: pack.packName,
          packFlashcardsCount: pack.flashcardsCount,
          record: record,
        );
        return Result.ok(review);
      case Ok<FcpDataDto>(:final value):
        // if the fcpData doc is found, it means we have fsrsData and fcSnapshot doc
        // then we only need to fetch the pack data.
        final record = value.toStatRecordDomain();
        final result = await _packService.getDocument(record.packId);
        switch (result) {
          case Error<PackDto>(:final error):
            return Result.error(error);
          case Ok<PackDto>():
        }
        final pack = result.value.toAdminPackDomain();
        final review = FlashcardReview(
          packName: pack.packName,
          packFlashcardsCount: pack.flashcardsCount,
          record: record,
        );

        return Result.ok(review);
    }

    // final fcResult = await _flashcardService.getDocument(flashcardId);
    // switch (fcResult) {
    //   case Error<FlashcardDto>(:final error):
    //     return Result.error(error);
    //   case Ok<FlashcardDto>():
    // }
    // final flashcard = fcResult.value.toDomain();
    // final (fcpResult, packResult) =
    //     await (
    //       _fcpService.getFcpDataDocument(
    //         profileId: _getUid(),
    //         flashcardId: flashcardId,
    //       ),
    //       _packService.getDocument(flashcard.packId),
    //     ).wait;
    //
    // late final Card fsrsCard;
    // late final isBookmarked;
    // switch (fcpResult) {
    //   case Error<FcpDataDto>(:final error):
    //     if (error is DocumentDoesntExistException) {
    //       fsrsCard = Card();
    //       isBookmarked = false;
    //     } else {
    //       return Result.error(error);
    //     }
    //   case Ok<FcpDataDto>(:final value):
    //     final fcpData = value.toStatRecordDomain();
    //     fsrsCard = fcpData.card;
    //     isBookmarked = fcpData.hasBookmark;
    // }
    // switch (packResult) {
    //   case Error<PackDto>(:final error):
    //     return Result.error(error);
    //   case Ok<PackDto>():
    // }
    // final pack = packResult.value.toAdminPackDomain();
    //
    // final flashcardReview = FlashcardReview(
    //   flashcard: flashcard,
    //   fsrsCard: fsrsCard,
    //   packName: pack.packName,
    //   packFlashcardsCount: pack.flashcardsCount,
    //   isBookmarked: isBookmarked
    // );
    //
    // return Result.ok(flashcardReview);
  }

  Future<Result<(Flashcard, SimplePack)>> _getFlashcardAndPack(
    String flashcardId,
  ) async {
    final fcResult = await _flashcardService.getDocument(flashcardId);
    switch (fcResult) {
      case Error<FlashcardDto>(:final error):
        return Result.error(error);
      case Ok<FlashcardDto>():
    }
    final flashcard = fcResult.value.toDomain();

    final packResult = await _packService.getDocument(flashcard.packId);
    switch (packResult) {
      case Error<PackDto>(:final error):
        return Result.error(error);
      case Ok<PackDto>():
    }
    final pack = packResult.value.toAdminPackDomain();

    return Result.ok((flashcard, pack));
  }

  Future<Result<Flashcard>> getFlashcard(String flashcardId) async {
    final result = await _flashcardService.getDocument(flashcardId);
    switch (result) {
      case Error<FlashcardDto>(:final error):
        return Result.error(error);
      case Ok<FlashcardDto>():
    }
    final flashcard = result.value.toDomain();
    return Result.ok(flashcard);
  }

  List<Flashcard>? getFlashcardPageFromCache({
    required String packId,
    required int pageIndex,
  }) {
    if (!_adminPageCache.isPageFresh(packId, pageIndex)) return null;

    return _adminPageCache.get(packId, pageIndex)!.data;
  }

  Future<Result<List<Flashcard>>> refreshFlashcardAndFetchFirstPage({
    required String packId,
    required int firstPageIndex,
    required int pageSize,
  }) {
    _adminPageCache.invalidate(packId);
    return getFlashcardPage(
      packId: packId,
      pageIndex: firstPageIndex,
      pageSize: pageSize,
    );
  }

  Future<Result<List<Flashcard>>> getFlashcardPage({
    required String packId,
    required int pageIndex,
    required int pageSize,
  }) async {
    if (_adminPageCache.isPageFresh(packId, pageIndex)) {
      return Result.ok(_adminPageCache.get(packId, pageSize)!.data);
    }

    final lastDoc = _adminPageCache.getLastDocFromPrevPage(packId, pageIndex);
    final result = await _flashcardService.getDocumentsByPackIdPagination(
      packId: packId,
      limit: pageSize,
      startAfter: lastDoc,
    );
    switch (result) {
      case Error<PaginatedDtoResult<FlashcardDto>>(:final error):
        return Result.error(error);
      case Ok<PaginatedDtoResult<FlashcardDto>>():
    }

    final domainList = result.value.items.map((dto) => dto.toDomain()).toList();
    final updatedList = _adminPageCache.removeDuplicatesFromManualCache(
      packId,
      domainList,
    );

    _adminPageCache.put(
      packId,
      pageIndex,
      CachedPagePagination(
        data: updatedList,
        fetchedAt: DateTime.now(),
        lastDocument: result.value.lastDocument,
      ),
    );

    return Result.ok(updatedList);
  }

  /// Reads every flashcard of the pack straight from the server, for export.
  Future<Result<List<Flashcard>>> getAllFlashcardsInPack(String packId) async {
    const pageSize = 500;
    final flashcards = <Flashcard>[];
    DocumentSnapshot? lastDoc;
    while (true) {
      final result = await _flashcardService.getDocumentsByPackIdPagination(
        packId: packId,
        limit: pageSize,
        startAfter: lastDoc,
      );
      switch (result) {
        case Error<PaginatedDtoResult<FlashcardDto>>(:final error):
          return Result.error(error);
        case Ok<PaginatedDtoResult<FlashcardDto>>():
      }

      flashcards.addAll(result.value.items.map((dto) => dto.toDomain()));
      lastDoc = result.value.lastDocument;
      if (result.value.items.length < pageSize || lastDoc == null) break;
    }
    return Result.ok(flashcards);
  }

  Future<Result<void>> deleteFlashcardEverywhere(Flashcard flashcard) async {
    final packId = flashcard.packId;
    final flashcardId = flashcard.id;
    final result = await _flashcardService.deleteFlashcardEverywhere(
      FlashcardDto.fromDomain(flashcard),
    );
    switch (result) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }

    _handleFlashcardDeletedInCache(packId, flashcard.tags.toIdList());
    _adminPageCache.removeItem(packId, flashcardId);
    return Result.ok(null);
  }

  Future<Result<void>> updateFlashcardEverywhere({
    required String packId,
    required String flashcardId,
    required List<Tag> allAvailableTags,
    String? question,
    String? answer,
    List<Tag>? selectedTags,
    List<Tag>? oldTags,
    ImageDataWrapper questionImageData = const ImageDataWrapper(),
    ImageDataWrapper answerImageData = const ImageDataWrapper(),
  }) async {
    final (shouldDeleteQuestion, questionPickedImage) = questionImageData
        .getPickedImageAndDeletedFlag();
    final (shouldDeleteAnswer, answerPickedImage) = answerImageData
        .getPickedImageAndDeletedFlag();

    final updateDto = UpdateFlashcardDto(
      question: question,
      answer: answer,
      tags: selectedTags?.toIdList(),
    );

    final futures = [
      _flashcardService.updateFlashcardEverywhere(
        flashcardId: flashcardId,
        partialJson: updateDto.toJson(),
        shouldDeleteAnswer: shouldDeleteAnswer,
        shouldDeleteQuestion: shouldDeleteQuestion,
        questionImageBytes: await questionPickedImage?.getImageBytes(),
        answerImageBytes: await answerPickedImage?.getImageBytes(),
      ),
    ];

    if (selectedTags != null) {
      futures.add(
        _tagService.setDocuments(selectedTags.findNewTagsDto(allAvailableTags)),
      );
    }

    final results = await Future.wait(futures);
    final updateResult = results[0];

    switch (updateResult) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }

    _adminPageCache.invalidate(flashcardId);

    if (selectedTags != null) {
      final setResult = results[1];
      switch (setResult) {
        case Error<void>(:final error):
          return Result.error(error);
        case Ok<void>():
      }
      _tagCache.insertAll(0, selectedTags.findNewTags(allAvailableTags));
      if (oldTags == null) {
        throw Exception("You need to specify old tags as well");
      }
      _handleFlashcardTagsUpdatedInCache(
        packId: packId,
        oldTags: oldTags.toIdList(),
        newTags: selectedTags.toIdList(),
      );
    }
    return Result.ok(null);
  }

  Future<Result<void>> createFlashcardAndAssignToPack({
    required String packId,
    required String question,
    required String answer,
    PickedImage? questionImage,
    PickedImage? answerImage,
    required List<Tag> allAvailableTags,
    required List<Tag> selectedTags,
  }) async {
    final flashcardRef = _flashcardService.createDocumentReference();
    final packRef = _packService.getDocumentReference(packId);

    String? questionUrl, answerUrl;
    if (questionImage != null) {
      final questionResult = await _flashcardService
          .uploadQuestionImageAndGetUrl(
            flashcardId: flashcardRef.id,
            image: questionImage,
          );
      switch (questionResult) {
        case Error<String>(:final error):
          return Result.error(error);
        case Ok<String>(:final value):
          questionUrl = value;
      }
    }

    if (answerImage != null) {
      final questionResult = await _flashcardService.uploadAnswerImageAndGetUrl(
        flashcardId: flashcardRef.id,
        image: answerImage,
      );
      switch (questionResult) {
        case Error<String>(:final error):
          return Result.error(error);
        case Ok<String>(:final value):
          answerUrl = value;
      }
    }

    final newTags = selectedTags.findNewTagsDto(allAvailableTags);

    var flashcard = Flashcard(
      id: flashcardRef.id,
      packId: packId,
      question: question,
      answer: answer,
      tags: selectedTags,
      answerImageUrl: answerUrl,
      questionImageUrl: questionUrl,
    );
    try {
      await _db.runTransaction((transaction) async {
        final packDto = await _packService.getDocumentInTransaction(
          packRef,
          transaction,
        );
        final flashcardIdsDto = await _packService.getFlashcardIdsInTransaction(
          packId,
          transaction,
        );

        flashcard = flashcard.copyWith(isPaid: packDto.isPaid);

        _flashcardService.setDocumentInTransaction(
          documentReference: flashcardRef,
          dto: FlashcardDto.fromDomain(flashcard),
          transaction: transaction,
        );

        // insert flashcardId to the end of the flashcard_builder field 'flashcardIds'
        final newFlashcardIds = addElement(
          flashcardIdsDto.flashcardIds,
          flashcardRef.id,
        );

        final updatedTagCounts = addTagsToPackMap(
          packDto.tagCounts,
          selectedTags.toIdList(),
        );

        final updatePackDto = UpdatePackDto(
          flashcardIdsPatchDto: FlashcardIdsPatchDto(
            flashcardIds: newFlashcardIds,
          ),
          tagCounts: updatedTagCounts,
          tags: updatedTagCounts.keys.toList(),
          flashcardsCount: packDto.flashcardsCount + 1,
        );

        _packService.updateDocumentInTransaction(
          packRef: packRef,
          dto: updatePackDto,
          transaction: transaction,
        );

        _tagService.setDocumentsInTransaction(newTags, transaction);
      });

      _handleFlashcardAddedToPack(
        packId,
        flashcardRef.id,
        selectedTags.toIdList(),
      );
      _adminPageCache.insertAtStart(packId, flashcard);
      _tagCache.insertAll(0, selectedTags.findNewTags(allAvailableTags));
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  /// Imports many flashcards (e.g. from an Anki deck) into a pack. Cards are
  /// saved in batches, so if something fails part way the cards saved before
  /// stay in the pack and [FlashcardImportSummary.error] is set.
  ///
  /// Cards whose question already exists in the pack are skipped, which makes
  /// it safe to run the same import again after a failure.
  Future<FlashcardImportSummary> importFlashcardsToPack({
    required String packId,
    required List<AnkiCard> cards,
    required bool importTags,
    required void Function(int processed, int total) onProgress,
  }) async {
    const batchSize = 100;
    var imported = 0;
    var skipped = 0;
    var failedImages = 0;

    final existingResult = await _flashcardService.getQuestionsInPack(packId);
    final Set<String> existingQuestions;
    switch (existingResult) {
      case Error<Set<String>>(:final error):
        return FlashcardImportSummary(error: error);
      case Ok<Set<String>>(:final value):
        existingQuestions = value;
    }

    final toImport = <AnkiCard>[];
    for (final card in cards) {
      if (existingQuestions.add(card.question)) {
        toImport.add(card);
      } else {
        skipped++;
      }
    }
    onProgress(0, toImport.length);

    final packRef = _packService.getDocumentReference(packId);
    // Every imported card's tags, used to update the cached tag counts.
    final importedTagIds = <String>[];

    for (var start = 0; start < toImport.length; start += batchSize) {
      final batch = toImport.skip(start).take(batchSize).toList();
      final flashcards = <Flashcard>[];

      // Upload a few images at a time
      const parallelUploads = 5;
      for (var i = 0; i < batch.length; i += parallelUploads) {
        final group = batch.skip(i).take(parallelUploads);
        final uploaded = await Future.wait(
          group.map((card) async {
            final ref = _flashcardService.createDocumentReference();
            final questionUrl = await _uploadImportedImage(
              ref.id,
              card.questionImage,
              isQuestion: true,
            );
            final answerUrl = await _uploadImportedImage(
              ref.id,
              card.answerImage,
              isQuestion: false,
            );
            if (card.questionImage != null && questionUrl == null) {
              failedImages++;
            }
            if (card.answerImage != null && answerUrl == null) {
              failedImages++;
            }
            return Flashcard(
              id: ref.id,
              packId: packId,
              question: card.question,
              answer: card.answer,
              tags: importTags ? ankiTagsToTags(card.tags) : const [],
              questionImageUrl: questionUrl,
              answerImageUrl: answerUrl,
            );
          }),
        );
        flashcards.addAll(uploaded);
        onProgress(imported + flashcards.length, toImport.length);
      }

      try {
        await _db.runTransaction((transaction) async {
          final packDto = await _packService.getDocumentInTransaction(
            packRef,
            transaction,
          );
          final flashcardIdsDto = await _packService
              .getFlashcardIdsInTransaction(packId, transaction);

          var tagCounts = packDto.tagCounts;
          final batchTags = <Tag>{};
          for (final flashcard in flashcards) {
            _flashcardService.setDocumentInTransaction(
              documentReference: _flashcardService.getDocumentReference(
                flashcard.id,
              ),
              dto: FlashcardDto.fromDomain(
                flashcard.copyWith(isPaid: packDto.isPaid),
              ),
              transaction: transaction,
            );
            tagCounts = addTagsToPackMap(tagCounts, flashcard.tags.toIdList());
            batchTags.addAll(flashcard.tags);
          }

          _packService.updateDocumentInTransaction(
            packRef: packRef,
            dto: UpdatePackDto(
              flashcardIdsPatchDto: FlashcardIdsPatchDto(
                flashcardIds: [
                  ...flashcardIdsDto.flashcardIds,
                  ...flashcards.map((f) => f.id),
                ],
              ),
              tagCounts: tagCounts,
              tags: tagCounts.keys.toList(),
              flashcardsCount: packDto.flashcardsCount + flashcards.length,
            ),
            transaction: transaction,
          );

          _tagService.setDocumentsInTransaction(
            batchTags.map(TagDto.fromTagDomain).toList(),
            transaction,
          );
        });
      } on Exception catch (error) {
        _handleFlashcardsImportedInCache(packId, imported, importedTagIds);
        return FlashcardImportSummary(
          imported: imported,
          skippedDuplicates: skipped,
          failedImages: failedImages,
          error: error,
        );
      }

      imported += flashcards.length;
      for (final flashcard in flashcards) {
        importedTagIds.addAll(flashcard.tags.toIdList());
      }
    }

    _handleFlashcardsImportedInCache(packId, imported, importedTagIds);
    return FlashcardImportSummary(
      imported: imported,
      skippedDuplicates: skipped,
      failedImages: failedImages,
    );
  }

  /// Compresses and uploads an imported image. Returns null if it failed, in
  /// which case the card is imported without that image.
  Future<String?> _uploadImportedImage(
    String flashcardId,
    AnkiImage? image, {
    required bool isQuestion,
  }) async {
    if (image == null) return null;
    final bytes = image.count > 1
        ? await combineImagesVertically(image.paths) ??
              await compressImportedImage(image.path)
        : await compressImportedImage(image.path);
    if (bytes == null) return null;

    final picked = PickedImage(bytes: bytes);
    final result = isQuestion
        ? await _flashcardService.uploadQuestionImageAndGetUrl(
            flashcardId: flashcardId,
            image: picked,
          )
        : await _flashcardService.uploadAnswerImageAndGetUrl(
            flashcardId: flashcardId,
            image: picked,
          );
    return switch (result) {
      Ok<String>(:final value) => value,
      Error<String>() => null,
    };
  }

  void _handleFlashcardsImportedInCache(
    String packId,
    int importedCount,
    List<String> tagIds,
  ) {
    if (importedCount == 0) return;
    _packsCache.invalidate();
    _tagCache.invalidate();
    _adminPageCache.invalidate(packId);
    _adminPacksCache.updateItem(
      id: packId,
      copyWith: (item) => item.copyWith(
        flashcardsCount: item.flashcardsCount + importedCount,
        tagCounts: addTagsToPackMap(item.tagCounts, tagIds),
      ),
    );
  }

  // pack cache operations
  void _handleFlashcardDeletedInCache(String packId, List<String> oldTags) {
    _packsCache.invalidate();

    _adminPacksCache.updateItem(
      id: packId,
      copyWith: (item) => item.copyWith(
        flashcardsCount: item.flashcardsCount - 1,
        tagCounts: updatePackTagCounts(item.tagCounts, oldTags, []),
      ),
    );
  }

  void _handleFlashcardTagsUpdatedInCache({
    required String packId,
    required List<String> oldTags,
    required List<String> newTags,
  }) {
    _packsCache.updateItem(
      id: packId,
      copyWith: (item) => item.copyWith(
        tagCounts: updatePackTagCounts(item.tagCounts, oldTags, newTags),
      ),
    );

    _adminPacksCache.updateItem(
      id: packId,
      copyWith: (item) => item.copyWith(
        tagCounts: updatePackTagCounts(item.tagCounts, oldTags, newTags),
      ),
    );
  }

  void _handleFlashcardAddedToPack(
    String packId,
    String flashcardId,
    List<String> newTags,
  ) {
    _packsCache.updateItem(
      id: packId,
      copyWith: (item) => item.copyWith(
        flashcardsCount: item.flashcardsCount + 1,
        newCount: item.newCount + 1,
        tagCounts: updatePackTagCounts(item.tagCounts, [], newTags),
      ),
    );

    _adminPacksCache.updateItem(
      id: packId,
      copyWith: (item) => item.copyWith(
        flashcardsCount: item.flashcardsCount + 1,
        tagCounts: updatePackTagCounts(item.tagCounts, [], newTags),
      ),
    );
  }

  String _getUid() {
    return getCurrentUserAndThrow(
      authService: _authService,
      repoName: "flashcard",
    ).uid;
  }
}
