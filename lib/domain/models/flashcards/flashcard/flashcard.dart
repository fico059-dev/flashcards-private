import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'flashcard.freezed.dart';

@freezed
abstract class Flashcard with _$Flashcard {
  const factory Flashcard({
    required String id,
    required String packId,
    required String question,
    required String answer,
    @Default(false) bool isPaid,
    String? questionImageUrl,
    String? answerImageUrl,
    required List<Tag> tags,

    /// The Anki note the card was imported from (e.g. "anki:<guid>"), so
    /// importing the deck again updates the card instead of duplicating it.
    String? sourceKey,

    /// The Anki image names the card was imported with.
    String? sourceImages,
  }) = _Flashcard;
}
