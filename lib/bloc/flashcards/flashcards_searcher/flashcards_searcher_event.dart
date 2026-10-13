import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flashcards/domain/models/algolia/algolia_flashcard/algolia_flashcard.dart';
import 'package:flashcards/domain/models/flashcards/tag/tag.dart';

abstract class FlashcardsSearcherEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FlashcardsSearcherPackAddedToState extends FlashcardsSearcherEvent {
  final AlgoliaFlashcard flashcard;

  FlashcardsSearcherPackAddedToState({required this.flashcard});

  @override
  List<Object?> get props => [flashcard];
}

class FlashcardsSearcherPackUpdatedInState extends FlashcardsSearcherEvent {
  final String flashcardId;
  final AlgoliaFlashcard Function(AlgoliaFlashcard pack) copyWith;

  FlashcardsSearcherPackUpdatedInState({
    required this.copyWith,
    required this.flashcardId,
  });

  @override
  List<Object?> get props => [copyWith, flashcardId];
}

class FlashcardsSearcherPackRemovedFromState extends FlashcardsSearcherEvent {
  final String flashcardId;

  FlashcardsSearcherPackRemovedFromState({required this.flashcardId});

  @override
  List<Object?> get props => [flashcardId];
}

class FlashcardsSearcherNextPageRequested extends FlashcardsSearcherEvent {}

class FlashcardsSearcherRequestSent extends FlashcardsSearcherEvent {
  final String query;
  final Completer<void>? completer;

  FlashcardsSearcherRequestSent({required this.query, this.completer});

  @override
  List<Object?> get props => [query, completer];
}

class FlashcardsSearcherTagToggled extends FlashcardsSearcherEvent {
  final Tag tag;

  FlashcardsSearcherTagToggled({required this.tag});

  @override
  List<Object?> get props => [tag];
}

/// Searches only [packIds], or every pack when null.
class FlashcardsSearcherScopeChanged extends FlashcardsSearcherEvent {
  final Set<String>? packIds;

  FlashcardsSearcherScopeChanged({required this.packIds});

  @override
  List<Object?> get props => [packIds];
}

// class FlashcardsSearcherClaimsFetched extends FlashcardsSearcherEvent {}
