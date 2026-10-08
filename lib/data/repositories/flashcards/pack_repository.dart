import 'package:flashcards/data/repositories/utils/pack_visibility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards/data/repositories/utils/pagination/paginated_cursor_map.dart';
import 'package:flashcards/data/repositories/utils/user_claims.dart';
import 'package:flashcards/data/services/api/dto/flashcards/custom_session/flashcard_ids/flashcard_ids_dto.dart';
import 'package:flashcards/data/utils/data_utils.dart';
import 'package:flashcards/data/repositories/utils/cache/page_cache/cached_page_pagination.dart';
import 'package:flashcards/data/repositories/utils/cache/page_cache/page_cache.dart';
import 'package:flashcards/data/services/api/dto/flashcards/pack/pack_dto.dart';
import 'package:flashcards/data/services/api/flashcards/fcp_service.dart';
import 'package:flashcards/data/services/api/flashcards/pack_service.dart';
import 'package:flashcards/data/services/api/users/auth_service.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/domain/models/flashcards/pack/pack.dart';
import 'package:flashcards/domain/models/flashcards/simple_pack/simple_pack.dart';
import 'package:flashcards/utils/result.dart';

enum CountType { due, learning, seen }

class _TypedResult {
  final CountType type;
  final Result<MapEntry<String, int>> result;

  _TypedResult(this.type, this.result);
}

class PackRepository {
  final PackService _packService;
  final FcpService _fcpService;
  final AuthService _authService;

  final _db = FirebaseFirestore.instance;

  final PageCache<Pack> _packsCache;
  final PageCache<AdminPack> _adminPacksCache;
  final PaginatedCursorMap _availablePacksCursorMap = PaginatedCursorMap();

  PackRepository({
    required PackService packService,
    required FcpService fcpService,
    required AuthService authService,
    required PageCache<Pack> packCache,
    required PageCache<AdminPack> adminPacksCache,
  }) : _packService = packService,
       _fcpService = fcpService,
       _authService = authService,
       _adminPacksCache = adminPacksCache,
       _packsCache = packCache;

  void handlePackAddedInCache({
    required String packId,
    required String packName,
    bool isPaid = false,
  }) {
    _packsCache.insertAtStart(
      Pack(
        id: packId,
        name: packName,
        flashcardsCount: 0,
        dueCount: 0,
        newCount: 0,
        learningCount: 0,
        isPaid: isPaid,
      ),
    );

    _adminPacksCache.insertAtStart(
      AdminPack(
        packId: packId,
        packName: packName,
        flashcardsCount: 0,
        isPaid: isPaid,
      ),
    );
  }

  void handlePackDeletedInCache(String packId) {
    _packsCache.removeItem(packId);
    _adminPacksCache.removeItem(packId);
  }

  void handlePackRenameInCache({
    required String packId,
    required String newName,
  }) {
    _packsCache.updateItem(
      id: packId,
      copyWith: (item) => item.copyWith(name: newName),
    );
    _adminPacksCache.updateItem(
      id: packId,
      copyWith: (item) => item.copyWith(packName: newName),
    );
  }

  List<Pack>? getPackPageFromCache(int pageIndex) {
    if (!_packsCache.isPageFresh(pageIndex)) return null;

    //packsCache.printCache();
    return _packsCache.get(pageIndex)!.data;
  }

  Future<Result<List<Pack>>> refreshPacksAndFetchFirstPage({
    required int firstPageIndex,
    required int pageSize,
  }) {
    _packsCache.invalidate();
    return getPackPage(pageIndex: firstPageIndex, pageSize: pageSize);
  }

  Future<Result<SimplePack>> getPack(String packId) async {
    final cacheItem = _adminPacksCache.getItem(packId);
    if (cacheItem != null) return Result.ok(cacheItem);

    final result = await _packService.getDocument(packId);
    switch (result) {
      case Error<PackDto>(:final error):
        return Result.error(error);
      case Ok<PackDto>():
    }

    final pack = result.value.toAdminPackDomain();
    return Result.ok(pack);
  }

  Future<Result<Pack>> getFullPack({required String packId}) async {
    final cacheItem = _packsCache.getItem(packId);
    if (cacheItem != null) return Result.ok(cacheItem);

    final claims = await UserClaims.current();
    final hasCards = claims.hasCards;

    final uid = _getUid();
    final results = await Future.wait([
      _packService.getDocument(packId),
      _fcpService.countDueDocuments(uid, packId, hasCards),
      _fcpService.countLearningDocuments(uid, packId, hasCards),
      _fcpService.countSeenDocuments(uid, packId, hasCards),
    ]);

    final packResult = results[0] as Result<PackDto>;
    final dueResult = results[1] as Result<MapEntry<String, int>>;
    final learningResult = results[2] as Result<MapEntry<String, int>>;
    final seenResult = results[3] as Result<MapEntry<String, int>>;
    switch (packResult) {
      case Error<PackDto>(:final error):
        return Result.error(error);
      case Ok<PackDto>():
    }
    final dueCount = _extractCount(dueResult);
    final learningCount = _extractCount(learningResult);
    final seenCount = _extractCount(seenResult);
    final pack = packResult.value.toPackDomain(
      dueCount,
      packResult.value.flashcardsCount - seenCount,
      learningCount,
    );

    return Result.ok(pack);
  }

  Future<Result<List<Pack>>> getPackPage({
    required int pageIndex,
    required int pageSize,
  }) async {
    try {
      if (_packsCache.isPageFresh(pageIndex)) {
        return Result.ok(_packsCache.get(pageIndex)!.data);
      }

      final lastDoc = _packsCache.getLastDocFromPrevPage(pageIndex);
      final uid = _getUid();

      final getResult = await _packService.getDocsPagination(lastDoc, pageSize);
      switch (getResult) {
        case Error<PaginatedDtoResult<PackDto>>(:final error):
          return Result.error(error);
        case Ok<PaginatedDtoResult<PackDto>>():
      }
      final dtoList = getResult.value.items;
      if (dtoList.isEmpty) return Result.ok([]);

      final futures = <Future<_TypedResult>>[];

      final claims = await UserClaims.current();
      final hasCards = claims.hasCards;
      for (final dto in dtoList) {
        // We can't sent those requests if user doesn't have card subs
        if (dto.isPaid && !hasCards) {
          continue;
        }

        final id = dto.id!;
        futures.add(
          _fcpService
              .countDueDocuments(uid, id, hasCards)
              .then((res) => _TypedResult(CountType.due, res)),
        );
        futures.add(
          _fcpService
              .countLearningDocuments(uid, id, hasCards)
              .then((res) => _TypedResult(CountType.learning, res)),
        );
        futures.add(
          _fcpService
              .countSeenDocuments(uid, id, hasCards)
              .then((res) => _TypedResult(CountType.seen, res)),
        );
      }

      final typedResults = await Future.wait(futures);

      final dueResults = <Result<MapEntry<String, int>>>[];
      final learningResults = <Result<MapEntry<String, int>>>[];
      final seenResults = <Result<MapEntry<String, int>>>[];

      for (final tr in typedResults) {
        switch (tr.type) {
          case CountType.due:
            dueResults.add(tr.result);
            break;
          case CountType.learning:
            learningResults.add(tr.result);
            break;
          case CountType.seen:
            seenResults.add(tr.result);
            break;
        }
      }

      final dueCountMap = _extractCounts(dueResults);
      final learningCountMap = _extractCounts(learningResults);
      final seenCountMap = _extractCounts(seenResults);

      final packs = dtoList.map((dto) {
        final id = dto.id!;
        final dueCount = calculateDueCount(dueCountMap, id);
        final newCount = calculateNewCount(
          seenCountMap,
          id,
          dto.flashcardsCount,
        );
        final learningCount = calculateLearningCount(learningCountMap, id);

        return dto.toPackDomain(dueCount, newCount, learningCount);
      }).toList();

      final updatedPacks = _packsCache.removeDuplicatesFromManualCache(packs);
      _packsCache.put(
        pageIndex,
        CachedPagePagination(
          data: updatedPacks,
          fetchedAt: DateTime.now(),
          lastDocument: getResult.value.lastDocument,
        ),
      );
      return Result.ok(updatedPacks);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  List<AdminPack>? getAdminPackPageFromCache(int pageIndex) {
    if (!_adminPacksCache.isPageFresh(pageIndex)) return null;

    return _adminPacksCache.get(pageIndex)!.data;
  }

  Future<Result<List<AdminPack>>> refreshAdminPacksAndFetchFirstPage({
    required int pageSize,
    required int firstPageIndex,
  }) {
    _adminPacksCache.invalidate();
    return getAdminPackPage(pageIndex: firstPageIndex, pageSize: pageSize);
  }

  Future<Result<List<AdminPack>>> getAdminPackPage({
    required int pageIndex,
    required int pageSize,
  }) async {
    if (_adminPacksCache.isPageFresh(pageIndex)) {
      return Result.ok(_adminPacksCache.get(pageIndex)!.data);
    }

    final lastDoc = _adminPacksCache.getLastDocFromPrevPage(pageIndex);
    final result = await _packService.getDocsPagination(lastDoc, pageSize);
    switch (result) {
      case Error<PaginatedDtoResult<PackDto>>(:final error):
        return Result.error(error);
      case Ok<PaginatedDtoResult<PackDto>>():
    }

    final list = result.value.items
        .map((dto) => dto.toAdminPackDomain())
        .toList();

    final updatedList = _adminPacksCache.removeDuplicatesFromManualCache(list);
    _adminPacksCache.put(
      pageIndex,
      CachedPagePagination(
        data: updatedList,
        fetchedAt: DateTime.now(),
        lastDocument: result.value.lastDocument,
      ),
    );

    return Result.ok(updatedList);
  }

  /// It return only the packs that the user has access to.
  /// Ex. if user has no cards subscription this will only return free packs
  /// Also those pages are not cached
  Future<Result<List<AdminPack>>> getAvailablePacksPage({
    required int pageIndex,
    required int pageSize,
    required hasCards,
  }) async {
    final lastDoc = _availablePacksCursorMap.getLastDocFromPrevPage(pageIndex);

    final result = await _packService.getDocsPagination(
      lastDoc,
      pageSize,
      onlyFreePacks: !hasCards,
    );
    switch (result) {
      case Error<PaginatedDtoResult<PackDto>>(:final error):
        return Result.error(error);
      case Ok<PaginatedDtoResult<PackDto>>():
    }

    final list = result.value.items
        .map((dto) => dto.toAdminPackDomain())
        .toList();

    _availablePacksCursorMap.put(pageIndex, result.value.lastDocument);

    return Result.ok(list);
  }

  Future<Result<void>> renamePack(String packId, String newName) async {
    final result = await _packService.renamePackEverywhere(packId, newName);
    switch (result) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }

    handlePackRenameInCache(packId: packId, newName: newName);
    return Result.ok(null);
  }

  /// Switches a pack between free and premium, including its flashcards and
  /// users' progress on them.
  Future<Result<void>> setPackPremium(String packId, bool isPaid) async {
    final result = await _packService.setPackPremium(packId, isPaid);
    switch (result) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }

    _packsCache.invalidate();
    _adminPacksCache.updateItem(
      id: packId,
      copyWith: (item) => item.copyWith(isPaid: isPaid),
    );
    return Result.ok(null);
  }

  /// Limits the pack to [emails]; an empty list opens it to everyone.
  Future<Result<List<String>>> setPackAccess(
    String packId,
    List<String> emails,
  ) async {
    final result = await _packService.setPackAccess(packId, emails);
    if (result case Ok<List<String>>(:final value)) {
      _packsCache.invalidate();
      PackVisibility.invalidate();
      _adminPacksCache.updateItem(
        id: packId,
        copyWith: (item) => item.copyWith(restricted: value.isNotEmpty),
      );
    }
    return result;
  }

  /// The emails the pack is limited to (empty: everyone). Admins only.
  Future<Result<List<String>>> getPackAccess(String packId) =>
      _packService.getPackAccess(packId);

  Future<Result<List<String>>> getFlashcardIdsFromPack(String packId) async {
    final result = await _packService.getFlashcardIds(packId);
    switch (result) {
      case Error<FlashcardIdsDto>(:final error):
        return Result.error(error);
      case Ok<FlashcardIdsDto>():
    }
    return Result.ok(result.value.flashcardIds);
  }

  Future<Result<SimplePack>> createPack(
    String packName, {
    bool isPaid = false,
  }) async {
    final ref = _packService.generateDocumentReference();

    final dto = PackDto.fromPackName(packName, isPaid: isPaid);

    final result = await _packService.setDocumentWithReference(dto, ref);
    switch (result) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }

    handlePackAddedInCache(packId: ref.id, packName: packName, isPaid: isPaid);

    final pack = SimplePack(
      packId: ref.id,
      flashcardsCount: 0,
      packName: packName,
      isPaid: isPaid,
    );
    return Result.ok(pack);
  }

  Future<Result<void>> deletePackIfEmpty(String packId) async {
    final packRef = _packService.getDocumentReference(packId);

    try {
      await _db.runTransaction((transaction) async {
        final packIds = await _packService.getFlashcardIdsInTransaction(
          packId,
          transaction,
        );
        if (packIds.flashcardIds.isNotEmpty) {
          throw Exception("You can delete a pack only if it's empty");
        }

        _packService.deleteDocumentInTransaction(packRef, transaction);
      });
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  /// Deletes the pack with all its flashcards and everyone's progress on them.
  Future<Result<void>> deletePackWithCards(String packId) async {
    final result = await _packService.deletePackWithCards(packId);
    switch (result) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }

    handlePackDeletedInCache(packId);
    return Result.ok(null);
  }

  Future<Result<void>> deletePackEverywhereIfEmpty(String packId) async {
    final result = await _packService.deletePackEverywhereIfEmpty(packId);
    switch (result) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }

    handlePackDeletedInCache(packId);
    return Result.ok(null);
  }

  String _getUid() {
    return getCurrentUserAndThrow(
      authService: _authService,
      repoName: "Pack repository",
    ).uid;
  }

  Map<String, int> _extractCounts(List<Result<MapEntry<String, int>>> results) {
    final Map<String, int> map = {};

    for (final result in results) {
      switch (result) {
        case Error<MapEntry<String, int>>(:final error):
          print(error);
          break;
        case Ok<MapEntry<String, int>>(:final value):
          map[value.key] = value.value;
      }
    }
    return map;
  }

  int _extractCount(Result<MapEntry<String, int>> result) {
    switch (result) {
      case Error<MapEntry<String, int>>(:final error):
        print(error);
        return -1;
      case Ok<MapEntry<String, int>>():
    }
    return result.value.value;
  }

  int calculateDueCount(Map<String, int> dueCountMap, String id) {
    return dueCountMap[id] ?? -1;
  }

  int calculateNewCount(
    Map<String, int> seenCountMap,
    String id,
    int flashcardsCount,
  ) {
    return seenCountMap[id] != null ? flashcardsCount - seenCountMap[id]! : -1;
  }

  int calculateLearningCount(Map<String, int> learningCountMap, String id) {
    return learningCountMap[id] ?? -1;
  }
}
