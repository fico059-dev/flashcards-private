import 'package:flashcards/data/services/api/algolia_search/local_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final items = [
    LocalSearchItem(
      item: 'cardio',
      text: 'Cardiology Basics',
      tagIds: ['heart'],
    ),
    LocalSearchItem(
      item: 'ecg',
      text: 'ECG and Cardiology',
      tagIds: ['heart', 'ecg'],
    ),
    LocalSearchItem(
      item: 'renal',
      text: 'Renal physiology',
      tagIds: ['kidney'],
    ),
  ];

  test('matches every word of the query, ignoring case', () {
    final result = searchLocally(
      items: items,
      query: 'cardio ECG',
      tagIds: [],
      page: 0,
    );
    expect(result.hits, ['ecg']);
    expect(result.hitCount, 1);
  });

  test('empty query returns everything', () {
    final result = searchLocally(
      items: items,
      query: '  ',
      tagIds: [],
      page: 0,
    );
    expect(result.hits, ['cardio', 'ecg', 'renal']);
    expect(result.isLastPage, isTrue);
    expect(result.nextPageKey, isNull);
  });

  test('requires all selected tags and counts tags of the matches', () {
    final result = searchLocally(
      items: items,
      query: '',
      tagIds: ['heart'],
      page: 0,
    );
    expect(result.hits, ['cardio', 'ecg']);
    final counts = {for (final e in result.tagCounts) e.key.id: e.value};
    expect(counts, {'ecg': 1, 'heart': 2, 'kidney': 0});
  });

  test('pages through results', () {
    final many = List.generate(
      45,
      (i) =>
          LocalSearchItem(item: i, text: 'card $i', tagIds: const <String>[]),
    );
    final first = searchLocally(
      items: many,
      query: 'card',
      tagIds: [],
      page: 0,
    );
    expect(first.hits.length, searchPageSize);
    expect(first.nextPageKey, 1);
    final last = searchLocally(items: many, query: 'card', tagIds: [], page: 2);
    expect(last.hits, [40, 41, 42, 43, 44]);
    expect(last.isLastPage, isTrue);
  });
}
