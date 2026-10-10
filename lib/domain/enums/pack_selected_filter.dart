import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum PackSelectedFilter { all, unseen, seen, bookmarked, ignored }

extension PackSelectedFilterExtension on PackSelectedFilter {
  String get label {
    switch (this) {
      case PackSelectedFilter.all:
        return 'All Flashcards';
      case PackSelectedFilter.unseen:
        return 'Unseen Flashcards';
      case PackSelectedFilter.seen:
        return 'Seen Flashcards';
      case PackSelectedFilter.bookmarked:
        return 'Bookmarked Flashcards';
      case PackSelectedFilter.ignored:
        return 'Ignored Flashcards';
    }
  }
}
