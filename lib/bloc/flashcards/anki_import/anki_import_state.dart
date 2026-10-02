import 'package:flashcards/data/repositories/flashcards/flashcard_repository.dart';
import 'package:flashcards/data/services/anki/anki_import_models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'anki_import_state.freezed.dart';

@freezed
sealed class AnkiImportState with _$AnkiImportState {
  const factory AnkiImportState.initial() = AnkiImportInitial;

  /// The chosen file is being read.
  const factory AnkiImportState.reading({required String fileName}) =
      AnkiImportReading;

  /// The file was read, the admin can review it before importing.
  const factory AnkiImportState.preview({
    required String fileName,
    required AnkiParseResult result,
  }) = AnkiImportPreview;

  const factory AnkiImportState.importing({
    required int processed,
    required int total,
  }) = AnkiImportImporting;

  const factory AnkiImportState.done({
    required FlashcardImportSummary summary,
  }) = AnkiImportDone;

  /// The file couldn't be read.
  const factory AnkiImportState.error({required Object error}) =
      AnkiImportError;
}
