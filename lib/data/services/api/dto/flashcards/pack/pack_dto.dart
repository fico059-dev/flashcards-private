import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/domain/models/flashcards/pack/pack.dart';
import 'package:flashcards/utils/typedefs.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pack_dto.freezed.dart';
part 'pack_dto.g.dart';

@freezed
abstract class PackDto with _$PackDto {
  const factory PackDto({
    @JsonKey(includeToJson: false) required String? id,
    required String name,
    required int flashcardsCount,
    @Default({}) Map<String, int> tagCounts,
    @Default([]) List<String> tags,
    @Default(false) bool isPaid,

    /// When not empty, only these users (and admins) see the pack. Set by
    /// the setPackAccess function only.
    @JsonKey(includeToJson: false) @Default([]) List<String> allowedEmails,
  }) = _PackDto;

  factory PackDto.fromJson(JsonMap json) => _$PackDtoFromJson(json);

  factory PackDto.fromJsonWithId(JsonMap json, String id) =>
      PackDto.fromJson(json).copyWith(id: id);

  factory PackDto.fromPackName(String packName, {bool isPaid = false}) =>
      PackDto(
        id: '',
        name: packName,
        tags: [],
        flashcardsCount: 0,
        isPaid: isPaid,
      );
}

// Needs to work like extension because dart will scream at you
// if you write it inside abstract class PackDto
extension PackDtoX on PackDto {
  Pack toPackDomain(int dueCount, int newCount, int learningCount) => Pack(
    id: id!,
    name: name,
    flashcardsCount: flashcardsCount,
    dueCount: dueCount,
    newCount: newCount,
    learningCount: learningCount,
    tagCounts: tagCounts,
    isPaid: isPaid ?? false,
  );

  AdminPack toAdminPackDomain() => AdminPack(
    packId: id!,
    isPaid: isPaid,
    packName: name,
    flashcardsCount: flashcardsCount,
    tagCounts: tagCounts,
    allowedEmails: allowedEmails,
  );
}
