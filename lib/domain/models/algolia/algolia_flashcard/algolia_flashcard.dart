import 'package:flashcards/utils/typedefs.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'algolia_flashcard.freezed.dart';

part 'algolia_flashcard.g.dart';

@freezed
abstract class AlgoliaFlashcard with _$AlgoliaFlashcard {
  const factory AlgoliaFlashcard({
    required String objectID,
    required String question,
    required String answer,
    required bool isPaid,
    required List<String> tags,

    /// The pack the card is in, for searching one pack.
    @Default('') String packId,
  }) = _AlgoliaFlashcard;

  factory AlgoliaFlashcard.fromJson(JsonMap json) =>
      _$AlgoliaFlashcardFromJson(json);
}
