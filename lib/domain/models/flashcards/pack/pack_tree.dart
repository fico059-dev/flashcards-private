import 'package:flashcards/domain/models/flashcards/pack/pack.dart';

/// A pack with the packs shown inside it (like Anki subdecks).
class PackNode {
  final Pack pack;
  final List<PackNode> children;

  const PackNode(this.pack, this.children);

  /// Every pack below this one, all levels.
  List<Pack> get descendants => [
    for (final child in children) ...[child.pack, ...child.descendants],
  ];

  /// The pack as studied from the list: its own cards plus every sub-pack's,
  /// with the counts added up.
  Pack get combined {
    if (children.isEmpty) return pack;
    final all = [pack, ...descendants];
    return pack.copyWith(
      flashcardsCount: all.fold(0, (sum, p) => sum + p.flashcardsCount),
      dueCount: _sumKnown(all.map((p) => p.dueCount)),
      newCount: _sumKnown(all.map((p) => p.newCount)),
      learningCount: _sumKnown(all.map((p) => p.learningCount)),
      subPacks: descendants,
    );
  }

  /// Counts are -1 when unknown (premium pack without access).
  static int _sumKnown(Iterable<int> counts) {
    final known = counts.where((c) => c >= 0);
    return known.isEmpty ? -1 : known.fold(0, (sum, c) => sum + c);
  }
}

/// Arranges [packs] by their parent. A pack whose parent isn't in the list
/// (deleted, or hidden from this user) is shown at the top level. Order
/// follows [packs].
List<PackNode> buildPackTree(List<Pack> packs) {
  final byId = {for (final p in packs) p.id: p};
  final childrenOf = <String, List<Pack>>{};
  final topLevel = <Pack>[];

  for (final pack in packs) {
    final parent = pack.parentId;
    if (parent == null ||
        !byId.containsKey(parent) ||
        _inCycle(pack.id, byId)) {
      topLevel.add(pack);
    } else {
      childrenOf.putIfAbsent(parent, () => []).add(pack);
    }
  }

  PackNode node(Pack pack, Set<String> path) {
    final kids = [
      for (final child in childrenOf[pack.id] ?? const <Pack>[])
        if (!path.contains(child.id)) node(child, {...path, child.id}),
    ];
    return PackNode(pack, kids);
  }

  return [
    for (final pack in topLevel) node(pack, {pack.id}),
  ];
}

bool _inCycle(String id, Map<String, Pack> byId) {
  final seen = <String>{id};
  var current = byId[id]?.parentId;
  while (current != null && byId.containsKey(current)) {
    if (!seen.add(current)) return true;
    current = byId[current]!.parentId;
  }
  return false;
}

/// Ids of [packId] and every pack below it, given each pack's parent.
/// Used so a pack can't be put inside itself or its own sub-packs.
Set<String> packAndDescendantIds(String packId, Map<String, String?> parentOf) {
  final result = {packId};
  var added = true;
  while (added) {
    added = false;
    parentOf.forEach((id, parent) {
      if (parent != null && result.contains(parent) && result.add(id)) {
        added = true;
      }
    });
  }
  return result;
}
