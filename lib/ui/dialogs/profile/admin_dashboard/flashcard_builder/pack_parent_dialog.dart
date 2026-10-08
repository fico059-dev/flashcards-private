import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/domain/models/flashcards/pack/pack_tree.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "Put inside another pack" entry of the admin pack menus.
class PackParentTile extends StatelessWidget {
  final AdminPack pack;
  final VoidCallback onTap;

  const PackParentTile({super.key, required this.pack, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        Icons.create_new_folder_outlined,
        color: context.colors.primaryContainer,
      ),
      title: const Text("Put inside another pack"),
      subtitle: Text(
        pack.parentId == null
            ? "Makes it a sub-pack, like Anki subdecks"
            : "It's a sub-pack now · change or move out",
      ),
    );
  }
}

/// Lets the admin choose the pack [pack] is shown inside, then saves it.
/// Returns true when it changed.
Future<bool> showPackParentDialog(BuildContext context, AdminPack pack) async {
  final repo = context.read<PackRepository>();
  final messenger = ScaffoldMessenger.of(context);

  final packsResult = await repo.getAllAdminPacks();
  if (!context.mounted) return false;
  final allPacks = switch (packsResult) {
    Ok(:final value) => value,
    Error(:final error) => () {
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(error))),
      );
      return null;
    }(),
  };
  if (allPacks == null) return false;

  // A pack can't go inside itself or one of its own sub-packs.
  final blocked = packAndDescendantIds(pack.packId, {
    for (final p in allPacks) p.packId: p.parentId,
  });
  final choices = allPacks.where((p) => !blocked.contains(p.packId)).toList()
    ..sort(
      (a, b) => a.packName.toLowerCase().compareTo(b.packName.toLowerCase()),
    );
  final names = {for (final p in allPacks) p.packId: p.packName};

  // "" means: top level.
  final chosen = await showDialog<String>(
    context: context,
    builder: (context) => _ParentPicker(
      pack: pack,
      choices: choices,
      currentParentName: names[pack.parentId],
    ),
  );
  if (chosen == null || !context.mounted) return false;
  final parentId = chosen.isEmpty ? null : chosen;
  if (parentId == pack.parentId) return false;

  final result = await repo.setPackParent(pack.packId, parentId);
  switch (result) {
    case Ok<void>():
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            parentId == null
                ? '"${pack.packName}" is now a main pack'
                : '"${pack.packName}" is now inside "${names[parentId]}"',
          ),
        ),
      );
      return true;
    case Error<void>(:final error):
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(error))),
      );
      return false;
  }
}

class _ParentPicker extends StatefulWidget {
  final AdminPack pack;
  final List<AdminPack> choices;
  final String? currentParentName;

  const _ParentPicker({
    required this.pack,
    required this.choices,
    required this.currentParentName,
  });

  @override
  State<_ParentPicker> createState() => _ParentPickerState();
}

class _ParentPickerState extends State<_ParentPicker> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final shown = widget.choices
        .where((p) => p.packName.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    return AlertDialog(
      title: Text('Put "${widget.pack.packName}" inside…'),
      content: SizedBox(
        width: 440,
        height: 420,
        child: Column(
          children: [
            if (widget.currentParentName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text("Now inside: ${widget.currentParentName}"),
              ),
            TextField(
              decoration: const InputDecoration(
                hintText: "Find a pack",
                prefixIcon: Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.vertical_align_top),
                    title: const Text("No parent (main pack)"),
                    selected: widget.pack.parentId == null,
                    onTap: () => Navigator.of(context).pop(''),
                  ),
                  const Divider(height: 1),
                  for (final p in shown)
                    ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(p.packName),
                      subtitle: p.parentId != null
                          ? const Text("Itself a sub-pack")
                          : null,
                      selected: p.packId == widget.pack.parentId,
                      onTap: () => Navigator.of(context).pop(p.packId),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
