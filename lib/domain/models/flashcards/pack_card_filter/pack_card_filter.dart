import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/domain/models/flashcards/tag/tag.dart';

enum ImageFilter { any, withImage, withoutImage }

/// Which cards of a pack the admin wants to see in the pack editor.
class PackCardFilter {
  /// Words that must appear in the question or answer.
  final String text;

  /// Tag ids to look for.
  final Set<String> tagIds;

  /// True: a card needs every selected tag. False: any one of them.
  final bool matchAllTags;
  final bool untaggedOnly;
  final ImageFilter images;

  const PackCardFilter({
    this.text = '',
    this.tagIds = const {},
    this.matchAllTags = false,
    this.untaggedOnly = false,
    this.images = ImageFilter.any,
  });

  bool get isActive =>
      text.trim().isNotEmpty ||
      tagIds.isNotEmpty ||
      untaggedOnly ||
      images != ImageFilter.any;

  PackCardFilter copyWith({
    String? text,
    Set<String>? tagIds,
    bool? matchAllTags,
    bool? untaggedOnly,
    ImageFilter? images,
  }) => PackCardFilter(
    text: text ?? this.text,
    tagIds: tagIds ?? this.tagIds,
    matchAllTags: matchAllTags ?? this.matchAllTags,
    untaggedOnly: untaggedOnly ?? this.untaggedOnly,
    images: images ?? this.images,
  );

  bool matches(Flashcard card) {
    final words = text
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty);
    if (words.isNotEmpty) {
      final haystack = '${card.question}\n${card.answer}'.toLowerCase();
      if (!words.every(haystack.contains)) return false;
    }

    final cardTags = card.tags.map((t) => t.id).toSet();
    if (untaggedOnly && cardTags.isNotEmpty) return false;
    if (tagIds.isNotEmpty) {
      final ok = matchAllTags
          ? tagIds.every(cardTags.contains)
          : tagIds.any(cardTags.contains);
      if (!ok) return false;
    }

    final hasImage =
        (card.questionImageUrl?.isNotEmpty ?? false) ||
        (card.answerImageUrl?.isNotEmpty ?? false);
    return switch (images) {
      ImageFilter.any => true,
      ImageFilter.withImage => hasImage,
      ImageFilter.withoutImage => !hasImage,
    };
  }

  List<Flashcard> apply(List<Flashcard> cards) =>
      isActive ? cards.where(matches).toList() : cards;

  /// Every tag used in [cards], A to Z, with how many cards have it.
  static List<(Tag, int)> tagsIn(Iterable<Flashcard> cards) {
    final counts = <String, (Tag, int)>{};
    for (final card in cards) {
      for (final tag in card.tags) {
        final current = counts[tag.id];
        counts[tag.id] = (tag, (current?.$2 ?? 0) + 1);
      }
    }
    return counts.values.toList()..sort(
      (a, b) => a.$1.name.toLowerCase().compareTo(b.$1.name.toLowerCase()),
    );
  }
}
