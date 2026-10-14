import 'dart:math';

import 'package:flashcards/ui/widgets/home/card_garden.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flowers grow where the studied cards are', () {
    // 200 cards; cards 40..59 studied and memorized.
    final levels = List.filled(200, 0);
    for (var i = 40; i < 60; i++) {
      levels[i] = 3;
    }
    final plots = gardenPlotsFromCards(levels);
    expect(plots.length, 10);
    expect(plots[2], PlotStatus.mastered);
    expect(plots.where((p) => p == PlotStatus.mastered).length, 1);
    expect(plots.where((p) => p == PlotStatus.unseen).length, 9);
  });

  test('shuffled study scatters the flowers, counts stay right', () {
    final random = Random(1);
    final levels = List.filled(2000, 0);
    final order = List.generate(2000, (i) => i)..shuffle(random);
    for (final i in order.take(600)) {
      levels[i] = 1 + random.nextInt(3);
    }
    final plots = gardenPlotsFromCards(levels);
    final byCounts = gardenPlots(
      GardenCounts(
        unseen: levels.where((l) => l == 0).length,
        learning: levels.where((l) => l == 1).length,
        reviewing: levels.where((l) => l == 2).length,
        mastered: levels.where((l) => l == 3).length,
      ),
    );
    for (final status in PlotStatus.values) {
      expect(
        plots.where((p) => p == status).length,
        byCounts.where((p) => p == status).length,
      );
    }
    // Not all at the start any more.
    final firstUnseen = plots.indexOf(PlotStatus.unseen);
    expect(plots.skip(firstUnseen).any((p) => p != PlotStatus.unseen), isTrue);
  });
}
