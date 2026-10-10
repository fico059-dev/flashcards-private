import 'dart:math';

import 'package:flashcards/data/services/local/seen_cards_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final pack = [for (var i = 1; i <= 200; i++) 'c$i'];

  test('new cards are only cards not studied yet', () {
    final seen = {for (var i = 1; i <= 150; i++) 'c$i'};
    final picked = pickNewCardIds(pack, seen, 20, random: Random(1));
    expect(picked, hasLength(20));
    expect(picked.toSet(), hasLength(20));
    expect(picked.any(seen.contains), isFalse);
  });

  test('new cards are not taken in pack order', () {
    final picked = pickNewCardIds(pack, {}, 20, random: Random(7));
    expect(picked, isNot(pack.take(20).toList()));
    // Cards come from all over the pack, not just the start.
    expect(picked.any((id) => int.parse(id.substring(1)) > 100), isTrue);
  });

  test('different sessions get different cards', () {
    final a = pickNewCardIds(pack, {}, 20, random: Random(1));
    final b = pickNewCardIds(pack, {}, 20, random: Random(2));
    expect(a, isNot(b));
  });

  test('asks for more than are left: gives what is left', () {
    final seen = {for (var i = 1; i <= 195; i++) 'c$i'};
    expect(
      pickNewCardIds(pack, seen, 20).toSet(),
      {'c196', 'c197', 'c198', 'c199', 'c200'},
    );
  });
}
