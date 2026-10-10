import 'package:flashcards/domain/enums/pack_selected_filter.dart';
import 'package:flashcards/utils/typedefs.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_custom_session_request_dto.freezed.dart';

part 'create_custom_session_request_dto.g.dart';

@freezed
abstract class CreateCustomSessionRequestDto
    with _$CreateCustomSessionRequestDto {
  const factory CreateCustomSessionRequestDto({
    required String profileId,
    required PackSelectedFilter filter,
    required List<String> tags,
    required List<String> packIds,
    required int sessionSize,
    String? name,

    /// Cards must have every tag. Older app versions leave this out and get
    /// cards with any of the tags.
    @Default(true) bool matchAllTags,
  }) = _CreateCustomSessionRequestDto;

  factory CreateCustomSessionRequestDto.fromJson(JsonMap json) =>
      _$CreateCustomSessionRequestDtoFromJson(json);
}
