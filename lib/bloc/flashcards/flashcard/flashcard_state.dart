import 'package:flashcards/bloc/flashcards/flashcard/flashcard_event.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/domain/models/flashcards/pack/pack.dart';
import 'package:flashcards/domain/models/flashcards/stat_record/stat_record.dart';
import 'package:flashcards/domain/models/profile/streak/streak.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'flashcard_state.freezed.dart';

enum FlashcardStatus {
  initial,
  loading,
  bookmarkLoading,
  loaded,
  sessionEnded,
  profileUpdated,
  packFinished,
  error,
}

extension FlashcardStatusX on FlashcardStatus {
  bool get isInitial => this == FlashcardStatus.initial;
  bool get isLoading => this == FlashcardStatus.loading;
  bool get isLoaded => this == FlashcardStatus.loaded;
  bool get isError => this == FlashcardStatus.error;
  bool get isSessionEnded => this == FlashcardStatus.sessionEnded;
  bool get isPackFinished => this == FlashcardStatus.packFinished;
  bool get isBookmarkLoading => this == FlashcardStatus.bookmarkLoading;
  bool get isProfileUpdated => this == FlashcardStatus.profileUpdated;
}

@freezed
abstract class FlashcardState with _$FlashcardState {
  const factory FlashcardState({
    @Default(FlashcardStatus.initial) FlashcardStatus status,
    TestType? testType,
    Pack? pack,
    int? cardsPerSession,
    @Default(false) bool answerVisible,
    @Default(false) bool hintVisible,
    @Default([]) List<StatRecord> statRecords,
    @Default(0) int currentCardIndex,
    @Default(0) int currentBatch,

    /// Cards of today's target already studied in this pack before the
    /// pack was opened this time, so the count continues.
    @Default(0) int sessionDone,
    Flashcard? flashcard,

    bool? hasCards,

    /// it reads local storage to see if the flashcards tutorial has been seen or not
    bool? tutorialSeen,

    /// used to communicate with profile bloc to update the state locally
    Streak? newStreak,

    String? errorMessage,
  }) = _FlashcardState;
}
