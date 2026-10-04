import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards/data/repositories/utils/user_claims.dart';
import 'package:flashcards/data/services/api/dto/flashcards/fcp_data/fcp_data_dto.dart';
import 'package:flashcards/data/services/api/dto/flashcards/pack/pack_dto.dart';
import 'package:flashcards/data/services/api/dto/osces/osce/osce_dto.dart';
import 'package:flashcards/data/services/api/dto/osces/osce_performance/osce_attempt/osce_attempt_dto.dart';
import 'package:flashcards/data/services/api/dto/osces/osce_performance/osce_performance_dto.dart';
import 'package:flashcards/data/services/api/flashcards/fcp_service.dart';
import 'package:flashcards/data/services/api/flashcards/pack_service.dart';
import 'package:flashcards/data/services/api/osce/osce_performance_service.dart';
import 'package:flashcards/data/services/api/osce/osce_service.dart';
import 'package:flashcards/data/services/api/users/auth_service.dart';
import 'package:flashcards/data/services/local/study_log_store.dart';
import 'package:flashcards/data/utils/data_utils.dart';
import 'package:flashcards/domain/models/progress/card_progress.dart';
import 'package:flashcards/domain/models/progress/osce_progress.dart';
import 'package:flashcards/domain/models/progress/study_log.dart';
import 'package:flashcards/utils/result.dart';

/// Gathers everything the Progress tab shows.
class ProgressRepository {
  final FcpService _fcpService;
  final PackService _packService;
  final OsceService _osceService;
  final OscePerformanceService _oscePerfService;
  final AuthService _authService;
  final StudyLogStore _logStore;

  ProgressRepository({
    required FcpService fcpService,
    required PackService packService,
    required OsceService osceService,
    required OscePerformanceService oscePerfService,
    required AuthService authService,
    required StudyLogStore logStore,
  }) : _fcpService = fcpService,
       _packService = packService,
       _osceService = osceService,
       _oscePerfService = oscePerfService,
       _authService = authService,
       _logStore = logStore;

  // Reading every progress document costs Firestore reads, so the raw data
  // is kept for a few minutes (e.g. while the goal is being changed).
  static const _cacheDuration = Duration(minutes: 5);
  (DateTime, String, List<PackInfo>, List<CardProgressItem>)? _cardCache;
  (DateTime, String, Map<String, String>, Map<String, List<OsceAttemptPoint>>)?
  _osceCache;

  String get _uid => _authService.getCurrentUser()!.uid;

  bool _isFresh(DateTime? fetchedAt, String? uid) =>
      fetchedAt != null &&
      uid == _uid &&
      DateTime.now().difference(fetchedAt) < _cacheDuration;

  Future<StudyLog> getLog() => _logStore.loadCombined();

  Future<StudyLog> saveGoal(StudyGoal goal) => _logStore.saveGoal(goal);

  Future<Result<CardProgressStats>> getCardStats({bool refresh = false}) async {
    try {
      final cache = _cardCache;
      if (refresh || !_isFresh(cache?.$1, cache?.$2)) {
        final hasCards = (await UserClaims.current()).hasCards;
        final results = await Future.wait([
          _loadPacks(hasCards),
          _loadCardProgress(hasCards),
        ]);
        _cardCache = (
          DateTime.now(),
          _uid,
          results[0] as List<PackInfo>,
          results[1] as List<CardProgressItem>,
        );
      }
      final (_, _, packs, items) = _cardCache!;

      final now = DateTime.now();
      final studied = items
          .where((i) => i.isStudied && packs.any((p) => p.id == i.packId))
          .length;
      await _logStore.update((log) => log.recordStudiedCount(now, studied));
      final log = await _logStore.loadCombined();

      return Result.ok(
        CardProgressStats.calculate(
          items: items,
          packs: packs,
          log: log,
          now: now,
        ),
      );
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<OsceProgressStats>> getOsceStats({bool refresh = false}) async {
    try {
      final cache = _osceCache;
      if (refresh || !_isFresh(cache?.$1, cache?.$2)) {
        final hasOsce = (await UserClaims.current()).hasOsce;
        final results = await Future.wait([
          _loadStations(hasOsce),
          _loadAttempts(),
        ]);
        _osceCache = (
          DateTime.now(),
          _uid,
          results[0] as Map<String, String>,
          results[1] as Map<String, List<OsceAttemptPoint>>,
        );
      }
      final (_, _, stations, attempts) = _osceCache!;
      return Result.ok(
        OsceProgressStats.calculate(
          allStations: stations,
          attemptsByStation: attempts,
          log: await _logStore.loadCombined(),
          now: DateTime.now(),
        ),
      );
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<List<PackInfo>> _loadPacks(bool hasCards) async {
    final packs = <PackInfo>[];
    await _readAllPages<PackDto>(
      (startAfter) => _packService.getDocsPagination(
        startAfter,
        200,
        onlyFreePacks: !hasCards,
      ),
      (dto) {
        final pack = dto.toAdminPackDomain();
        packs.add(
          PackInfo(
            id: pack.packId,
            name: pack.packName,
            totalCards: pack.flashcardsCount,
          ),
        );
      },
    );
    return packs;
  }

  Future<List<CardProgressItem>> _loadCardProgress(bool hasCards) async {
    final items = <CardProgressItem>[];
    final uid = _uid;
    await _readAllPages<FcpDataDto>(
      (startAfter) => _fcpService.getProfileDocsPagination(
        profileId: uid,
        hasCards: hasCards,
        startAfter: startAfter,
        limit: 1000,
      ),
      (dto) => items.add(
        CardProgressItem(
          flashcardId: dto.flashcardId,
          packId: dto.flashcardSnapshotDto.packId,
          question: dto.flashcardSnapshotDto.question,
          tags: dto.flashcardSnapshotDto.tags,
          card: dto.fsrsCard,
          ignored: dto.ignored,
        ),
      ),
    );
    return items;
  }

  Future<Map<String, String>> _loadStations(bool hasOsce) async {
    final stations = <String, String>{};
    await _readAllPages<OsceDto>(
      (startAfter) => _osceService.getDocumentsPagination(
        limit: 200,
        startAfter: startAfter,
      ),
      (dto) {
        final osce = dto.toSimpleOsceDomain();
        if (hasOsce || !osce.isPaid) stations[osce.id] = osce.name;
      },
    );
    return stations;
  }

  Future<Map<String, List<OsceAttemptPoint>>> _loadAttempts() async {
    final uid = _uid;
    final osceIds = <String>[];
    await _readAllPages<OscePerformanceDto>(
      (startAfter) => _oscePerfService.getOscePerformancesPagination(
        uid: uid,
        startAfter: startAfter,
        limit: 100,
      ),
      (dto) => osceIds.add(dto.osceId),
    );

    final entries = await Future.wait(
      osceIds.map((osceId) async {
        final result = await _oscePerfService.getOsceAttemptsPagination(
          uid: uid,
          osceId: osceId,
          startAfter: null,
          limit: 100,
        );
        switch (result) {
          case Error(:final error):
            throw error;
          case Ok():
        }
        return MapEntry(osceId, [
          for (final OsceAttemptDto a in result.value.items)
            if (a.maxScore > 0)
              OsceAttemptPoint(
                a.attemptDate,
                a.achievedScore / a.maxScore * 100,
              ),
        ]);
      }),
    );
    return Map.fromEntries(entries);
  }

  Future<void> _readAllPages<T>(
    Future<Result<PaginatedDtoResult<T>>> Function(DocumentSnapshot? startAfter)
    getPage,
    void Function(T item) onItem,
  ) async {
    DocumentSnapshot? startAfter;
    while (true) {
      final result = await getPage(startAfter);
      switch (result) {
        case Error(:final error):
          throw error;
        case Ok():
      }
      result.value.items.forEach(onItem);
      startAfter = result.value.lastDocument;
      if (startAfter == null) return;
    }
  }
}
