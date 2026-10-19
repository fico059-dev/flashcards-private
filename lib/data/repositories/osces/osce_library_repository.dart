import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards/data/remote/cloud_function_service.dart';
import 'package:flashcards/data/repositories/osces/osce_repository.dart';
import 'package:flashcards/data/services/api/dto/osces/osce/osce_dto.dart';
import 'package:flashcards/data/services/api/osce/osce_service.dart';
import 'package:flashcards/data/utils/image_compression.dart';
import 'package:flashcards/domain/models/osce/osce_folder/osce_library.dart';
import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';
import 'package:flashcards/utils/result.dart';

/// OSCE stations organised in speciality folders.
class OsceLibraryRepository {
  final OsceService _osceService;
  final OsceRepository _osceRepository;
  final CloudFunctionService _functions;

  OsceLibraryRepository({
    required OsceService osceService,
    required OsceRepository osceRepository,
    required CloudFunctionService functions,
  }) : _osceService = osceService,
       _osceRepository = osceRepository,
       _functions = functions;

  static const _cacheDuration = Duration(minutes: 10);
  (DateTime, OsceLibrary)? _cache;

  Future<Result<OsceLibrary>> getLibrary({bool refresh = false}) async {
    final cache = _cache;
    if (!refresh &&
        cache != null &&
        DateTime.now().difference(cache.$1) < _cacheDuration) {
      return Result.ok(cache.$2);
    }
    try {
      final results = await Future.wait([
        _loadStations(),
        _functions.listOsceFolders(),
      ]);
      final library = OsceLibrary(
        stations: results[0] as List<SimpleOsce>,
        folders: [
          for (final json in results[1] as List<Map<String, dynamic>>)
            OsceFolder.fromJson(json),
        ],
      );
      _cache = (DateTime.now(), library);
      return Result.ok(library);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<List<SimpleOsce>> _loadStations() async {
    final stations = <SimpleOsce>[];
    DocumentSnapshot? startAfter;
    while (true) {
      final result = await _osceService.getDocumentsPagination(
        limit: 200,
        startAfter: startAfter,
      );
      switch (result) {
        case Error(:final error):
          throw error;
        case Ok():
      }
      stations.addAll(
        result.value.items.map((dto) => dto.toSimpleOsceDomain()),
      );
      startAfter = result.value.lastDocument;
      if (startAfter == null) return stations;
    }
  }

  // Admin changes. Each one refreshes the cached lists.

  Future<Result<void>> saveFolder({
    String? id,
    required String name,
    String? parentId,
  }) => _change(
    () => _functions.saveOsceFolder(id: id, name: name, parentId: parentId),
  );

  Future<Result<void>> deleteFolder(String id) =>
      _change(() => _functions.deleteOsceFolder(id));

  Future<Result<void>> moveStation(String osceId, String? folderId) =>
      _change(() => _functions.setOsceFolder(osceId, folderId));

  Future<Result<void>> setPremium(String osceId, bool isPaid) =>
      _change(() => _functions.setOscePremium(osceId, isPaid));

  /// Uploads [imageBytes] as the description image, or removes it for null.
  Future<Result<void>> setScenarioImage(String osceId, Uint8List? imageBytes) =>
      _change(() async {
        String? base64;
        if (imageBytes != null) {
          final jpeg = await prepareJpeg(imageBytes);
          if (jpeg == null) throw Exception("This image couldn't be read.");
          base64 = base64Encode(jpeg);
        }
        await _functions.setOsceScenarioImage(osceId, base64);
      });

  Future<Result<void>> _change(Future<void> Function() action) async {
    try {
      await action();
      _cache = null;
      _osceRepository.invalidateCache();
      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
