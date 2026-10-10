import 'package:flashcards/domain/models/flashcards/pack/pack.dart';
import 'package:flashcards/domain/models/flashcards/pack/pack_tree.dart';
import 'package:flutter_test/flutter_test.dart';

Pack pack(
  String id, {
  String? parent,
  int cards = 10,
  int due = 1,
  int fresh = 5,
  int learning = 0,
}) => Pack(
  id: id,
  name: id,
  flashcardsCount: cards,
  dueCount: due,
  newCount: fresh,
  learningCount: learning,
  parentId: parent,
);

void main() {
  test('sub-packs sit inside their pack, Anki style', () {
    final tree = buildPackTree([
      pack('Foundation R1', cards: 0, due: 0, fresh: 0),
      pack('Neonatal essential', parent: 'Foundation R1'),
      pack('Pediatric essential', parent: 'Foundation R1'),
      pack('Oncall essential', parent: 'Foundation R1'),
      pack('Other pack'),
    ]);
    expect(tree.map((n) => n.pack.id), ['Foundation R1', 'Other pack']);
    expect(tree.first.children.map((n) => n.pack.id), [
      'Neonatal essential',
      'Pediatric essential',
      'Oncall essential',
    ]);
  });

  test('the parent studies and counts everything inside it', () {
    final tree = buildPackTree([
      pack('F', cards: 2, due: 0, fresh: 2),
      pack('A', parent: 'F', cards: 10, due: 3, fresh: 4, learning: 1),
      pack('B', parent: 'F', cards: 20, due: 1, fresh: 6),
      pack('B1', parent: 'B', cards: 5, due: 2, fresh: 1),
    ]);
    final combined = tree.single.combined;
    expect(combined.flashcardsCount, 37);
    expect(combined.dueCount, 6);
    expect(combined.newCount, 13);
    expect(combined.learningCount, 1);
    expect(combined.subPacks.map((p) => p.id), ['A', 'B', 'B1']);
    // A pack without sub-packs is unchanged.
    expect(tree.single.children.first.combined.subPacks, isEmpty);
  });

  test('unknown counts (premium without access) are left out of sums', () {
    final tree = buildPackTree([
      pack('F', due: -1, fresh: -1),
      pack('A', parent: 'F', due: 2, fresh: 3),
    ]);
    expect(tree.single.combined.dueCount, 2);
    expect(tree.single.combined.newCount, 3);
  });

  test('a sub-pack whose parent is hidden or deleted shows at the top', () {
    final tree = buildPackTree([pack('A', parent: 'gone')]);
    expect(tree.single.pack.id, 'A');
  });

  test('a loop of parents never hangs or loses packs', () {
    final tree = buildPackTree([
      pack('A', parent: 'B'),
      pack('B', parent: 'A'),
    ]);
    final all = <String>{};
    void walk(List<PackNode> nodes) {
      for (final n in nodes) {
        all.add(n.pack.id);
        walk(n.children);
      }
    }

    walk(tree);
    expect(all, {'A', 'B'});
  });

  test('a pack can\'t be put inside itself or its own sub-packs', () {
    final blocked = packAndDescendantIds('F', {
      'F': null,
      'A': 'F',
      'A1': 'A',
      'Other': null,
    });
    expect(blocked, {'F', 'A', 'A1'});
  });
}
