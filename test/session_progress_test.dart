import 'package:flashcards/data/services/local/session_progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryPrefs implements SharedPreferencesAsync {
  final values = <String, String>{};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async =>
      values[key] = value;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('the session count continues today and starts over tomorrow', () async {
    var now = DateTime(2026, 10, 13, 9);
    final prefs = _MemoryPrefs();
    final store = SessionProgressStore(prefs: prefs, now: () => now);

    expect(await store.doneToday('u1', 'neo'), 0);
    for (var i = 0; i < 6; i++) {
      await store.add('u1', 'neo');
    }
    await store.add('u1', 'onc');

    // Closing and opening the pack later the same day.
    now = DateTime(2026, 10, 13, 22);
    expect(
      await SessionProgressStore(
        prefs: prefs,
        now: () => now,
      ).doneToday('u1', 'neo'),
      6,
    );
    expect(await store.doneToday('u1', 'onc'), 1);
    expect(await store.doneToday('u2', 'neo'), 0);

    now = DateTime(2026, 10, 14, 7);
    expect(await store.doneToday('u1', 'neo'), 0);
    await store.add('u1', 'neo');
    expect(await store.doneToday('u1', 'neo'), 1);
  });

  test('each pack can have its own session target', () async {
    final store = SessionProgressStore(prefs: _MemoryPrefs());
    expect(await store.packTarget('u1', 'neo'), isNull);
    await store.setPackTarget('u1', 'neo', 30);
    expect(await store.packTarget('u1', 'neo'), 30);
    expect(await store.packTarget('u1', 'onc'), isNull);
    expect(await store.packTarget('u2', 'neo'), isNull);
    await store.setPackTarget('u1', 'neo', null);
    expect(await store.packTarget('u1', 'neo'), isNull);
  });
}
