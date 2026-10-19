import 'package:flashcards/domain/models/progress/card_progress.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

/// A pack in the picker, with how deep it sits under other packs.
class GoalPackRow {
  final PackInfo pack;
  final int depth;

  /// Every pack below this one.
  final List<String> descendantIds;

  const GoalPackRow(this.pack, this.depth, this.descendantIds);
}

/// [packs] in tree order: each pack followed by its sub-packs.
List<GoalPackRow> goalPackRows(List<PackInfo> packs) {
  final ids = {for (final p in packs) p.id};
  final childrenOf = <String, List<PackInfo>>{};
  final top = <PackInfo>[];
  for (final pack in packs) {
    final parent = pack.parentId;
    if (parent == null || !ids.contains(parent) || parent == pack.id) {
      top.add(pack);
    } else {
      childrenOf.putIfAbsent(parent, () => []).add(pack);
    }
  }

  final rows = <GoalPackRow>[];
  final placed = <String>{};
  List<String> add(PackInfo pack, int depth) {
    if (!placed.add(pack.id)) return const [];
    final index = rows.length;
    rows.add(GoalPackRow(pack, depth, const []));
    final below = <String>[];
    for (final child in childrenOf[pack.id] ?? const <PackInfo>[]) {
      if (placed.contains(child.id)) continue;
      below
        ..add(child.id)
        ..addAll(add(child, depth + 1));
    }
    rows[index] = GoalPackRow(pack, depth, below);
    return below;
  }

  for (final pack in top) {
    add(pack, 0);
  }
  // Packs caught in a loop of parents.
  for (final pack in packs) {
    add(pack, 0);
  }
  return rows;
}

/// Lets the student pick the packs for the exam. Returns the chosen ids
/// (empty for every pack), or null when cancelled.
Future<List<String>?> showGoalPacksDialog(
  BuildContext context, {
  required List<PackInfo> packs,
  required List<String> selected,
}) {
  return showDialog<List<String>>(
    context: context,
    builder: (context) => _GoalPacksDialog(packs: packs, selected: selected),
  );
}

class _GoalPacksDialog extends StatefulWidget {
  final List<PackInfo> packs;
  final List<String> selected;

  const _GoalPacksDialog({required this.packs, required this.selected});

  @override
  State<_GoalPacksDialog> createState() => _GoalPacksDialogState();
}

class _GoalPacksDialogState extends State<_GoalPacksDialog> {
  late final rows = goalPackRows(widget.packs);
  late final Set<String> _selected = widget.selected.toSet();
  String _search = '';

  int get _cards => widget.packs
      .where((p) => _selected.contains(p.id))
      .fold(0, (sum, p) => sum + p.totalCards);

  void _toggle(GoalPackRow row, bool value) {
    setState(() {
      // A pack comes with its sub-packs, like studying it does.
      for (final id in [row.pack.id, ...row.descendantIds]) {
        if (value) {
          _selected.add(id);
        } else {
          _selected.remove(id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.trim().toLowerCase();
    final shown = query.isEmpty
        ? rows
        : rows.where((r) => r.pack.name.toLowerCase().contains(query)).toList();

    return AlertDialog(
      title: const Text('Packs for this exam'),
      insetPadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: SizedBox(
        width: 520,
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search packs',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: shown.isEmpty
                  ? const Center(child: Text('No packs found'))
                  : ListView.builder(
                      itemCount: shown.length,
                      itemBuilder: (context, index) {
                        final row = shown[index];
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.only(
                            left: query.isEmpty ? row.depth * 20.0 : 0,
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          value: _selected.contains(row.pack.id),
                          onChanged: (value) => _toggle(row, value ?? false),
                          title: Text(row.pack.name),
                          subtitle: Text('${row.pack.totalCards} cards'),
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _selected.isEmpty
                    ? 'No packs chosen: the goal counts every pack'
                    : '${_selected.length} packs · $_cards cards',
                style: context.text.labelLarge,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(const <String>[]),
          child: const Text('All packs'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(rows.map((r) => r.pack.id).where(_selected.contains).toList()),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
