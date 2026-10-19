import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/domain/models/flashcards/pack_card_filter/pack_card_filter.dart';
import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:flutter_test/flutter_test.dart';

Flashcard card(
  String id,
  String q, {
  List<String> tags = const [],
  String? image,
}) => Flashcard(
  id: id,
  packId: 'p',
  question: q,
  answer: 'answer $id',
  questionImageUrl: image,
  tags: [for (final t in tags) Tag.fromName(t)],
);

void main() {
  final cards = [
    card('1', 'Neonatal jaundice causes', tags: ['neoreview', '2025']),
    card('2', 'Kawasaki disease criteria', tags: ['neoreview']),
    card('3', 'Asthma steps', tags: ['2025'], image: 'http://x/img.jpg'),
    card('4', 'Croup management'),
  ];

  List<String> ids(PackCardFilter f) => f.apply(cards).map((c) => c.id).toList();

  test('no filter shows every card', () {
    expect(ids(const PackCardFilter()), ['1', '2', '3', '4']);
  });

  test('search matches all words, in question or answer, any case', () {
    expect(ids(const PackCardFilter(text: 'JAUNDICE')), ['1']);
    expect(ids(const PackCardFilter(text: 'kawasaki criteria')), ['2']);
    expect(ids(const PackCardFilter(text: 'answer 4')), ['4']);
    expect(ids(const PackCardFilter(text: 'kawasaki asthma')), isEmpty);
  });

  test('tags: any or all of the selected', () {
    final tagIds = {Tag.fromName('neoreview').id, Tag.fromName('2025').id};
    expect(ids(PackCardFilter(tagIds: tagIds)), ['1', '2', '3']);
    expect(ids(PackCardFilter(tagIds: tagIds, matchAllTags: true)), ['1']);
  });

  test('untagged and image filters', () {
    expect(ids(const PackCardFilter(untaggedOnly: true)), ['4']);
    expect(ids(const PackCardFilter(images: ImageFilter.withImage)), ['3']);
    expect(
      ids(const PackCardFilter(images: ImageFilter.withoutImage)),
      ['1', '2', '4'],
    );
  });

  test('tag list is A to Z with counts', () {
    final tags = PackCardFilter.tagsIn(cards);
    expect(tags.map((t) => (t.$1.name, t.$2)).toList(), [
      ('2025', 2),
      ('Neoreview', 2),
    ]);
  });
}
