import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_pack.freezed.dart';

@freezed
abstract class AdminPack with _$AdminPack {
  const factory AdminPack({
    required String packId,
    required String packName,
    required int flashcardsCount,
    required bool isPaid,
    @Default({}) Map<String, int> tagCounts,

    /// When not empty, only these users (and admins) see the pack.
    @Default([]) List<String> allowedEmails,
  }) = _AdminPack;
}

extension AdminPackX on AdminPack {
  List<Tag> get tags => tagCounts.keys.map((id) => Tag.fromId(id)).toList();
}

extension ListAdminPacksX on List<AdminPack> {
  // converting to id and name
  List<String> get packNames => map((pack) => pack.packName).toList();

  List<String> get packIds => map((pack) => pack.packId).toList();

  // tags
  List<Tag> get tags => expand((pack) => pack.tags).toList();

  Map<String, bool> toTagSelectedMap({
    defaultValue = false,
    limit = double.infinity,
  }) {
    final result = <String, bool>{};
    final seen = <String>{};

    for (final tag in expand((pack) => pack.tags)) {
      if (seen.length >= limit) break;
      if (seen.add(tag.id)) {
        result[tag.id] = defaultValue;
      }
    }

    return result;
  }

  Map<String, int> get tagCounts {
    final Map<String, int> result = {};
    for (final pack in this) {
      pack.tagCounts.forEach((tag, count) {
        result.update(
          tag,
          (existing) => existing + count,
          ifAbsent: () => count,
        );
      });
    }
    return result;
  }

  Map<Tag, int> get tagCountsConverted {
    final Map<Tag, int> result = {};
    for (final pack in this) {
      pack.tagCounts.forEach((tag, count) {
        result.update(
          Tag.fromId(tag),
          (existing) => existing + count,
          ifAbsent: () => count,
        );
      });
    }
    return result;
  }
}
