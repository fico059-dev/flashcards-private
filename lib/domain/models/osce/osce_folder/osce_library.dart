import 'dart:math';

import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';

/// A speciality folder of OSCE stations. Folders can contain sub-folders.
class OsceFolder {
  final String id;
  final String name;
  final String? parentId;

  const OsceFolder({required this.id, required this.name, this.parentId});

  factory OsceFolder.fromJson(Map<String, dynamic> json) => OsceFolder(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    parentId: json['parentId'] as String?,
  );
}

/// All stations and folders, with helpers to browse them.
class OsceLibrary {
  final List<SimpleOsce> stations;
  final List<OsceFolder> folders;

  OsceLibrary({required this.stations, required this.folders})
    : _byId = {for (final f in folders) f.id: f};

  final Map<String, OsceFolder> _byId;

  OsceFolder? folder(String? id) => id == null ? null : _byId[id];

  /// Folders directly inside [parentId] (null for the top level), A to Z.
  List<OsceFolder> subfolders(String? parentId) =>
      folders.where((f) => _parentOf(f) == parentId).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  /// Stations directly in [folderId] (null: stations in no folder), A to Z.
  /// Stations of a deleted folder show at the top level.
  List<SimpleOsce> stationsIn(String? folderId) =>
      stations.where((s) => _folderOf(s) == folderId).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  /// Stations in [folderId] and all its sub-folders; every station for null.
  List<SimpleOsce> allStationsUnder(String? folderId) {
    if (folderId == null) return stations;
    return stations.where((s) => isInside(_folderOf(s), folderId)).toList();
  }

  /// Folders from the top level down to [folderId].
  List<OsceFolder> path(String? folderId) {
    final path = <OsceFolder>[];
    var current = folder(folderId);
    while (current != null && path.length < 100) {
      path.insert(0, current);
      current = folder(current.parentId);
    }
    return path;
  }

  /// Readable location, e.g. "Paediatrics / Neonatology".
  String pathName(String? folderId) =>
      path(folderId).map((f) => f.name).join(' / ');

  /// Whether [folderId] is [ancestorId] or one of its sub-folders.
  bool isInside(String? folderId, String ancestorId) {
    var current = folder(folderId);
    for (var depth = 0; current != null && depth < 100; depth++) {
      if (current.id == ancestorId) return true;
      current = folder(current.parentId);
    }
    return false;
  }

  /// A random station from [folderId] (all stations for null). With
  /// [hasAccess] false only free stations are picked; null when there are
  /// none to pick.
  SimpleOsce? randomStation(
    String? folderId, {
    required bool hasAccess,
    Random? random,
  }) {
    final candidates = allStationsUnder(
      folderId,
    ).where((s) => hasAccess || !s.isPaid).toList();
    if (candidates.isEmpty) return null;
    return candidates[(random ?? Random()).nextInt(candidates.length)];
  }

  String? _parentOf(OsceFolder f) =>
      f.parentId != null && _byId.containsKey(f.parentId) ? f.parentId : null;

  String? _folderOf(SimpleOsce s) =>
      s.folderId != null && _byId.containsKey(s.folderId) ? s.folderId : null;
}
