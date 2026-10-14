import 'package:flashcards/domain/models/osce/osce.dart';
import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';
import 'package:flashcards/utils/typedefs.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'osce_dto.freezed.dart';
part 'osce_dto.g.dart';

@freezed
abstract class OsceDto with _$OsceDto {
  const factory OsceDto({
    @JsonKey(includeToJson: false) required String? id,
    required String name,
    required String scenario,
    @Default(<dynamic>[]) List<dynamic> questions,
    @Default(false) bool isPaid,

    /// Set by the setOsceFolder / setOsceScenarioImage functions only.
    @JsonKey(includeToJson: false) String? folderId,
    @JsonKey(includeToJson: false) String? scenarioImageUrl,
  }) = _OsceDto;

  factory OsceDto.fromJson(JsonMap json) => _$OsceDtoFromJson(json);

  factory OsceDto.fromJsonWithId(JsonMap json, String id) =>
      OsceDto.fromJson(json).copyWith(id: id);
}

extension OsceDtoX on OsceDto {
  Osce toOsceDomain() => Osce(
    id: id!,
    name: name,
    scenario: scenario,
    questions: [],
    isPaid: isPaid,
    folderId: folderId,
    scenarioImageUrl: scenarioImageUrl,
  );

  SimpleOsce toSimpleOsceDomain() => SimpleOsce(
    id: id!,
    name: name,
    scenario: scenario,
    isPaid: isPaid,
    folderId: folderId,
    scenarioImageUrl: scenarioImageUrl,
  );
}
