import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Picks [count] new cards at random from the pack cards not [seen] yet.
List<String> pickNewCardIds(
  List<String> packIds,
  Set<String> seen,
  int count, {
  Random? random,
}) {
  final unseen = packIds.where((id) => !seen.contains(id)).toList()
    ..shuffle(random ?? Random());
  return unseen.take(count).toList();
}

/// Remembers, per user and pack, which cards the user has already studied,
/// so new cards can be picked at random without reading every progress
/// document each time.
class SeenCardsStore {
  final SharedPreferencesAsync _prefs;

  SeenCardsStore({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();

  String _key(String uid, String packId) => 'seen_cards_${uid}_$packId';

  Future<Set<String>?> load(String uid, String packId) async {
    try {
      final raw = await _prefs.getString(_key(uid, packId));
      if (raw == null) return null;
      return (jsonDecode(raw) as List).cast<String>().toSet();
    } on Object {
      return null;
    }
  }

  Future<void> save(String uid, String packId, Set<String> ids) async {
    try {
      await _prefs.setString(_key(uid, packId), jsonEncode(ids.toList()));
    } on Object {
      // Only a speed-up: without it the list is read from the server.
    }
  }

  Future<void> add(String uid, String packId, String flashcardId) async {
    final ids = await load(uid, packId);
    // Without a saved list there is nothing to keep up to date; the next
    // session reads the full list from the server.
    if (ids == null || !ids.add(flashcardId)) return;
    await save(uid, packId, ids);
  }
}
