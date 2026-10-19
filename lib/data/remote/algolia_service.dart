import 'package:algoliasearch/algoliasearch_lite.dart';

/// هل ميزة البحث (Algolia) مفعّلة في هذا البناء؟
const bool kSearchEnabled =
    String.fromEnvironment('ALGOLIA_APP_ID') != '' &&
    String.fromEnvironment('ALGOLIA_SEARCH_KEY') != '';

class AlgoliaService {
  static const _appId = String.fromEnvironment('ALGOLIA_APP_ID');
  // مفتاح البحث (Search-Only API Key) فقط، وليس مفتاح الإدارة.
  // مرّره عند التشغيل:
  //   --dart-define=ALGOLIA_APP_ID=... --dart-define=ALGOLIA_SEARCH_KEY=...
  static const _searchKey = String.fromEnvironment('ALGOLIA_SEARCH_KEY');

  SearchClient? _client;

  final String packsIndex = const String.fromEnvironment(
    'ALGOLIA_PACKS_INDEX',
    defaultValue: 'taqdir_packs',
  );
  final List<String> packsFacets = const ['tags'];

  final String flashcardsIndex = const String.fromEnvironment(
    'ALGOLIA_FLASHCARDS_INDEX',
    defaultValue: 'taqdir_flashcards',
  );
  final List<String> flashcardsFacets = const ['tags'];

  AlgoliaService({required bool isDev});

  /// هل تم ضبط مفاتيح Algolia؟ (البحث اختياري)
  bool get isConfigured => kSearchEnabled;

  SearchClient get client {
    if (!isConfigured) {
      throw Exception('البحث غير مفعّل: لم يتم ضبط مفاتيح Algolia.');
    }
    return _client ??= SearchClient(appId: _appId, apiKey: _searchKey);
  }

  void dispose() {
    _client?.dispose();
  }
}

extension TagStringListX on List<String> {
  /// It gives you algolia facet query where it combines every element of the list with the AND logic operator
  ///
  /// You just give it the name of the facet in the algolia index.
  List<List<String>> buildTagsAndQuery(String facetName) {
    // facetFilters can be list of lists [[tag1, tag2], [category1, category2]];
    // inner lists are combined with OR and outer with AND operator
    // resulting with this ((tag1 OR tag2) AND (category1 OR category2))
    // here we want to combine everything with AND so each item in the list
    // needs to be a list of 1 item resulting in [[tag1], [tag2], [tag3]].
    // to be (tag1 AND tag2 AND tag3)
    return map((id) => ['$facetName:$id']).toList();
  }
}
