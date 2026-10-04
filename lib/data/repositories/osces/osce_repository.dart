import 'package:collection/collection.dart';
import 'package:flashcards/data/services/api/dto/osces/osce/osce_dto.dart';
import 'package:flashcards/data/services/api/dto/osces/osce/patch_osce/patch_osce_dto.dart';
import 'package:flashcards/data/services/api/dto/osces/osce_performance/patch_osce_performance/patch_osce_performance_dto.dart';
import 'package:flashcards/data/services/api/dto/osces/question/check/check_dto.dart';
import 'package:flashcards/data/services/api/dto/osces/question/patch_question/patch_question_dto.dart';
import 'package:flashcards/data/services/api/dto/osces/question/question_dto.dart';
import 'package:flashcards/data/services/api/osce/osce_performance_service.dart';
import 'package:flashcards/data/utils/data_utils.dart';
import 'package:flashcards/data/repositories/utils/cache/page_cache/cached_page_pagination.dart';
import 'package:flashcards/data/repositories/utils/cache/page_cache/page_cache.dart';
import 'package:flashcards/data/services/api/osce/osce_service.dart';
import 'package:flashcards/domain/models/core/image_data_wrapper.dart';
import 'package:flashcards/domain/models/core/picked_image.dart';
import 'package:flashcards/domain/models/osce/osce.dart';
import 'package:flashcards/domain/models/osce/question/question.dart';
import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';
import 'package:flashcards/utils/result.dart';

class OsceRepository {
  final OsceService _osceService;
  final PageCache<SimpleOsce> _osceCache = PageCache(
    cacheDuration: Duration(minutes: 20),
    getId: (item) => item.id,
  );
  final OscePerformanceService _oscePerfService;

  OsceRepository({
    required OsceService osceService,
    required OscePerformanceService oscePerfService,
  }) : _osceService = osceService,
       _oscePerfService = oscePerfService;

  /// Forgets the cached station pages, after admin changes elsewhere.
  void invalidateCache() => _osceCache.invalidate();

  List<SimpleOsce>? getOscePageFromCache(int pageIndex) {
    if (!_osceCache.isPageFresh(pageIndex)) return null;

    //_osceCache.printCache();
    return _osceCache.get(pageIndex)!.data;
  }

  String generateQuestionId(String osceId) {
    return _osceService.generateQuestionReference(osceId).id;
  }

  Future<Result<List<SimpleOsce>>> refreshOsceAndFetchFirstPage({
    required int pageSize,
    required int firstPageIndex,
  }) {
    _osceCache.invalidate();
    return getOscePage(pageSize: pageSize, pageIndex: firstPageIndex);
  }

  Future<Result<List<SimpleOsce>>> getOscePage({
    required int pageSize,
    required int pageIndex,
  }) async {
    if (_osceCache.isPageFresh(pageIndex)) {
      return Result.ok(_osceCache.get(pageIndex)!.data);
    }

    final lastDoc = _osceCache.getLastDocFromPrevPage(pageIndex);
    final result = await _osceService.getDocumentsPagination(
      limit: pageSize,
      startAfter: lastDoc,
    );
    switch (result) {
      case Error<PaginatedDtoResult<OsceDto>>(:final error):
        return Result.error(error);
      case Ok<PaginatedDtoResult<OsceDto>>():
    }

    final osceList =
        result.value.items.map((dto) => dto.toSimpleOsceDomain()).toList();
    final osceListUpdated = _osceCache.removeDuplicatesFromManualCache(
      osceList,
    );
    _osceCache.put(
      pageIndex,
      CachedPagePagination(
        data: osceListUpdated,
        fetchedAt: DateTime.now(),
        lastDocument: result.value.lastDocument,
      ),
    );

    return Result.ok(osceListUpdated);
  }

  Future<Result<Osce>> getOsce(SimpleOsce simpleOsce) async {
    try {
      var result = await _osceService.getQuestions(simpleOsce.id);
      switch (result) {
        case Error<List<QuestionDto>>(:final error):
          return Result.error(error);
        case Ok<List<QuestionDto>>():
      }
      final questions = result.value.toQuestionsDomain();
      final osce = Osce.fromSimpleOsce(simpleOsce, questions);

      return Result.ok(osce);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<Result<void>> addSimpleOsce({
    required String name,
    required String scenario,
    required bool isPaid,
  }) async {
    final osceDto = OsceDto(
      id: null,
      name: name,
      scenario: scenario,
      isPaid: isPaid,
    );
    final result = await _osceService.setDocument(osceDto);
    switch (result) {
      case Error<String>(:final error):
        return Result.error(error);
      case Ok<String>():
    }

    _osceCache.insertAtStart(
      SimpleOsce(
        id: result.value,
        name: name,
        scenario: scenario,
        isPaid: isPaid,
      ),
    );
    return Result.ok(null);
  }

  Future<Result<void>> patchOsce(String osceId, PatchOsceDto dto) async {
    // we also need to patch the osce performances that reference this osce
    final perfDto = PatchOscePerformanceDto(
      osceSnapshot: dto.toOscePatchSnapshot(),
    );
    final perfResult = await _oscePerfService.patchOscePerformances(
      osceId: osceId,
      patch: perfDto,
    );
    switch (perfResult) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }

    final result = await _osceService.patchOsce(osceId, dto);
    switch (result) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }

    _osceCache.updateItem(
      id: osceId,
      copyWith:
          (item) => item.copyWith(
            name: dto.name ?? item.name,
            scenario: dto.scenario ?? item.scenario,
          ),
    );
    return Result.ok(null);
  }

  Future<Result<void>> deleteOsce(String osceId) async {
    final result = await _osceService.deleteOsce(osceId);
    switch (result) {
      case Error<void>(:final error):
        return Result.error(error);
      case Ok<void>():
    }

    _osceCache.removeItem(osceId);
    return Result.ok(null);
  }

  Future<Result<List<MapEntry<String, Question>>>> getQuestions(
    String osceId,
  ) async {
    final result = await _osceService.getQuestions(osceId);
    switch (result) {
      case Error<List<QuestionDto>>(:final error):
        return Result.error(error);
      case Ok<List<QuestionDto>>():
    }

    final list =
        result.value.map((dto) => MapEntry(dto.id!, dto.toDomain())).toList();
    return Result.ok(list);
  }

  Future<Result<void>> addQuestion({
    required String osceId,
    required Question question,
    required PickedImage? questionImage,
  }) async {
    // upload the image first, if it exists
    String? questionUrl;
    if (questionImage != null) {
      final questionResult = await _osceService.uploadQuestionImageAndGetUrl(
        osceId: osceId,
        questionId: question.id,
        image: questionImage,
      );
      switch (questionResult) {
        case Error<String>(:final error):
          return Result.error(error);
        case Ok<String>(:final value):
          questionUrl = value;
      }
    }

    final dto = QuestionDto.fromDomain(
      question: question,
      imageUrl: questionUrl,
    );

    return await _osceService.createQuestion(
      osceId: osceId,
      questionId: question.id,
      dto: dto,
    );
  }

  Future<Result<void>> updateQuestion({
    required String osceId,
    required Question question,
    ImageDataWrapper questionImageData = const ImageDataWrapper(),
  }) async {
    var patchDto = PatchQuestionDto(
      checks:
          question.checks
              .mapIndexed((index, check) => CheckDto.fromDomain(check, index))
              .toList(),
      text: question.text,
      index: question.index,
    );
    bool includeNullImage = false;

    final (shouldDeleteQuestion, questionPickedImage) =
        questionImageData.getPickedImageAndDeletedFlag();

    if (shouldDeleteQuestion) {
      await _osceService.deleteQuestionImage(
        osceId: osceId,
        questionId: question.id,
      );
      includeNullImage = true;
    }

    String? imageUrl;
    if (questionPickedImage != null) {
      final result = await _osceService.uploadQuestionImageAndGetUrl(
        osceId: osceId,
        questionId: question.id,
        image: questionPickedImage,
      );
      switch (result) {
        case Error<String>(:final error):
          return Result.error(error);
        case Ok<String>():
      }

      imageUrl = result.value;
      includeNullImage = true;
    }
    patchDto = patchDto.copyWith(imageDownloadUrl: imageUrl);

    await _osceService.updateQuestion(
      osceId: osceId,
      questionId: question.id,
      dto: patchDto,
      includeNullImage: includeNullImage,
    );

    return Result.ok(null);
  }

  Future<Result<void>> deleteQuestion({
    required String osceId,
    required String questionId,
  }) {
    return _osceService.deleteQuestionAndImage(
      osceId: osceId,
      questionId: questionId,
    );
  }
}
