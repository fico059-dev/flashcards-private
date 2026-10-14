import 'package:flashcards/utils/typedefs.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'simple_osce.freezed.dart';

part 'simple_osce.g.dart';

/// It's just osce but without questions.
///
/// Since questions are a subcollection inside osce, they are loaded when you request them.
///
/// Simple osce is used when you just want to show basic osce info.
@freezed
abstract class SimpleOsce with _$SimpleOsce {
  const factory SimpleOsce({
    required String id,
    required String name,
    required String scenario,
    required bool isPaid,

    /// Speciality folder; null when the station isn't in a folder.
    String? folderId,

    /// Image shown with the description (scenario).
    String? scenarioImageUrl,
  }) = _SimpleOsce;

  factory SimpleOsce.fromJson(JsonMap json) => _$SimpleOsceFromJson(json);
}
