import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/domain/models/flashcards/stat_record/stat_record.dart';
import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:flashcards/utils/typedefs.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fsrs/fsrs.dart';

part 'flashcard_dto.freezed.dart';

part 'flashcard_dto.g.dart';

@freezed
abstract class FlashcardDto with _$FlashcardDto {
  const factory FlashcardDto({
    @JsonKey(includeToJson: false) String? id,
    required String packId,
    required String question,
    required String answer,
    required bool isPaid,
    @Default(null) String? questionImageUrl,
    @Default(null) String? answerImageUrl,
    @Default([]) List<String> tags,
    @JsonKey(includeIfNull: false) String? sourceKey,
    @JsonKey(includeIfNull: false) String? sourceImages,
  }) = _FlashcardDto;

  factory FlashcardDto.fromJson(JsonMap json) => _$FlashcardDtoFromJson(json);

  factory FlashcardDto.fromJsonWithId(JsonMap json, String id) =>
      FlashcardDto.fromJson(json).copyWith(id: id);

  factory FlashcardDto.fromDomain(Flashcard flashcard) => FlashcardDto(
    id: flashcard.id,
    isPaid: flashcard.isPaid,
    question: flashcard.question,
    answer: flashcard.answer,
    packId: flashcard.packId,
    tags: flashcard.tags.map((tag) => tag.id).toList(),
    answerImageUrl: flashcard.answerImageUrl,
    questionImageUrl: flashcard.questionImageUrl,
    sourceKey: flashcard.sourceKey,
    sourceImages: flashcard.sourceImages,
  );
}

extension FlashcardDtoX on FlashcardDto {
  Flashcard toDomain() => Flashcard(
    id: id!,
    isPaid: isPaid,
    question: question,
    answer: answer,
    packId: packId,
    tags: tags.map((e) => Tag.fromId(e)).toList(),
    questionImageUrl: questionImageUrl,
    answerImageUrl: answerImageUrl,
    sourceKey: sourceKey,
    sourceImages: sourceImages,
  );

  StatRecord toEmptyStatRecord() => StatRecord(
    packId: packId,
    flashcardId: id!,
    card: Card(),
    flashcard: toDomain(),
    isPaid: false,
  );

  JsonMap toJsonWithId() {
    final json = toJson();
    if (id != null) {
      json['id'] = id;
    }
    return json;
  }
}
