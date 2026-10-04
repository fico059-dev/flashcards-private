import 'package:file_picker/file_picker.dart';
import 'package:flashcards/data/repositories/osces/osce_library_repository.dart';
import 'package:flashcards/domain/models/osce/osce_folder/osce_library.dart';
import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Runs an admin change with a progress dialog; shows [done] or the error.
/// Returns whether it worked.
Future<bool> runOsceAdminChange(
  BuildContext context,
  Future<Result<void>> Function() change, {
  required String done,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator()),
    ),
  );
  final result = await change();
  navigator.pop();
  switch (result) {
    case Ok():
      messenger.showSnackBar(SnackBar(content: Text(done)));
      return true;
    case Error(:final error):
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(error))),
      );
      return false;
  }
}

/// Folders in display order, each with its depth, for tree lists.
List<(OsceFolder folder, int depth)> folderTree(OsceLibrary library) {
  final rows = <(OsceFolder, int)>[];
  void add(String? parentId, int depth) {
    for (final folder in library.subfolders(parentId)) {
      rows.add((folder, depth));
      add(folder.id, depth + 1);
    }
  }

  add(null, 0);
  return rows;
}

/// Result of [pickOsceFolder]: [folderId] null means "no folder".
class FolderChoice {
  final String? folderId;
  const FolderChoice(this.folderId);
}

/// Lets the admin choose a folder (or none). Null when cancelled.
Future<FolderChoice?> pickOsceFolder(
  BuildContext context,
  OsceLibrary library, {
  String? currentFolderId,
  String title = 'Move to folder',
  String? excludeFolderId,
}) {
  final rows = folderTree(library).where(
    (row) =>
        excludeFolderId == null ||
        !library.isInside(row.$1.id, excludeFolderId),
  );
  return showDialog<FolderChoice>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(title),
      children: [
        _FolderOption(
          icon: Icons.folder_off_outlined,
          label: 'No folder (top level)',
          depth: 0,
          selected: currentFolderId == null,
          onTap: () => Navigator.of(context).pop(const FolderChoice(null)),
        ),
        for (final (folder, depth) in rows)
          _FolderOption(
            icon: Icons.folder_outlined,
            label: folder.name,
            depth: depth,
            selected: currentFolderId == folder.id,
            onTap: () => Navigator.of(context).pop(FolderChoice(folder.id)),
          ),
        if (rows.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No folders yet. Create them with "Manage folders" on the OSCE '
              'builder page.',
            ),
          ),
      ],
    ),
  );
}

class _FolderOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final int depth;
  final bool selected;
  final VoidCallback onTap;

  const _FolderOption({
    required this.icon,
    required this.label,
    required this.depth,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onTap,
      padding: EdgeInsets.fromLTRB(24.0 + depth * 20, 10, 24, 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.colors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          if (selected) Icon(Icons.check, color: context.colors.primary),
        ],
      ),
    );
  }
}

/// Asks for a folder name. Null when cancelled.
Future<String?> askFolderName(
  BuildContext context, {
  required String title,
  String initial = '',
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) {
      void save() {
        final name = controller.text.trim();
        if (name.isNotEmpty) Navigator.of(context).pop(name);
      }

      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Folder name',
            hintText: 'e.g. Paediatrics',
          ),
          onSubmitted: (_) => save(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(onPressed: save, child: const Text('Save')),
        ],
      );
    },
  ).whenComplete(controller.dispose);
}

/// Admin page to create, rename, nest and delete speciality folders.
class OsceFoldersAdminPage extends StatefulWidget {
  const OsceFoldersAdminPage({super.key});

  @override
  State<OsceFoldersAdminPage> createState() => _OsceFoldersAdminPageState();
}

class _OsceFoldersAdminPageState extends State<OsceFoldersAdminPage> {
  OsceLibrary? _library;
  Object? _error;

  OsceLibraryRepository get _repo => context.read<OsceLibraryRepository>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = true}) async {
    final result = await _repo.getLibrary(refresh: refresh);
    if (!mounted) return;
    setState(() {
      switch (result) {
        case Ok(:final value):
          _library = value;
          _error = null;
        case Error(:final error):
          _error = error;
      }
    });
  }

  Future<void> _change(
    Future<Result<void>> Function() change,
    String done,
  ) async {
    if (await runOsceAdminChange(context, change, done: done)) await _load();
  }

  Future<void> _create(String? parentId) async {
    final name = await askFolderName(
      context,
      title: parentId == null ? 'New folder' : 'New sub-folder',
    );
    if (name == null || !mounted) return;
    await _change(
      () => _repo.saveFolder(name: name, parentId: parentId),
      'Folder "$name" created',
    );
  }

  Future<void> _rename(OsceFolder folder) async {
    final name = await askFolderName(
      context,
      title: 'Rename folder',
      initial: folder.name,
    );
    if (name == null || !mounted) return;
    await _change(
      () => _repo.saveFolder(
        id: folder.id,
        name: name,
        parentId: folder.parentId,
      ),
      'Folder renamed',
    );
  }

  Future<void> _move(OsceFolder folder) async {
    final choice = await pickOsceFolder(
      context,
      _library!,
      currentFolderId: folder.parentId,
      title: 'Move "${folder.name}" into',
      excludeFolderId: folder.id,
    );
    if (choice == null || !mounted) return;
    await _change(
      () => _repo.saveFolder(
        id: folder.id,
        name: folder.name,
        parentId: choice.folderId,
      ),
      'Folder moved',
    );
  }

  Future<void> _delete(OsceFolder folder) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${folder.name}"?'),
        content: const Text(
          'Its stations and sub-folders are not deleted; they move up one '
          'level.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete folder'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _change(() => _repo.deleteFolder(folder.id), 'Folder deleted');
  }

  @override
  Widget build(BuildContext context) {
    final library = _library;
    return Scaffold(
      appBar: AppBar(title: const Text('OSCE folders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: library == null ? null : () => _create(null),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('New folder'),
      ),
      body: library == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : Text(extractErrorMessage(_error!)),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 12),
                    child: Text(
                      'Create a folder for each speciality, and sub-folders '
                      'inside them if you like. Put stations in folders from '
                      'each OSCE\'s menu ("Move to folder").',
                    ),
                  ),
                  for (final (folder, depth) in folderTree(library))
                    Padding(
                      padding: EdgeInsets.only(left: depth * 24.0),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            depth == 0 ? Icons.folder : Icons.folder_outlined,
                            color: context.colors.primary,
                          ),
                          title: Text(folder.name),
                          subtitle: Text(
                            stationCountLabel(
                              library.allStationsUnder(folder.id).length,
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            tooltip: 'Folder options',
                            onSelected: (action) => switch (action) {
                              'sub' => _create(folder.id),
                              'rename' => _rename(folder),
                              'move' => _move(folder),
                              _ => _delete(folder),
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'sub',
                                child: Text('Add sub-folder'),
                              ),
                              PopupMenuItem(
                                value: 'rename',
                                child: Text('Rename'),
                              ),
                              PopupMenuItem(value: 'move', child: Text('Move')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (library.folders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No folders yet. Tap "New folder" to create one.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

/// Options for one station: folder, premium and description image.
class OsceStationAdminOptions extends StatelessWidget {
  final SimpleOsce osce;

  /// Called after a change, e.g. to refresh the list.
  final VoidCallback onChanged;

  const OsceStationAdminOptions({
    super.key,
    required this.osce,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.read<OsceLibraryRepository>();
    final hasImage = osce.scenarioImageUrl?.isNotEmpty ?? false;

    Future<void> closeAndRun(
      Future<Result<void>> Function() change,
      String done,
    ) async {
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      Navigator.of(context).pop();
      if (await runOsceAdminChange(rootContext, change, done: done)) {
        onChanged();
      }
    }

    Future<void> move() async {
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      Navigator.of(context).pop();
      final libraryResult = await repo.getLibrary();
      if (!rootContext.mounted) return;
      final library = switch (libraryResult) {
        Ok(:final value) => value,
        Error() => null,
      };
      if (library == null) {
        ScaffoldMessenger.of(rootContext).showSnackBar(
          const SnackBar(content: Text("Folders couldn't be loaded")),
        );
        return;
      }
      final choice = await pickOsceFolder(
        rootContext,
        library,
        currentFolderId: library.folder(osce.folderId)?.id,
      );
      if (choice == null || !rootContext.mounted) return;
      final where = choice.folderId == null
          ? 'the top level'
          : library.pathName(choice.folderId);
      if (await runOsceAdminChange(
        rootContext,
        () => repo.moveStation(osce.id, choice.folderId),
        done: '"${osce.name}" moved to $where',
      )) {
        onChanged();
      }
    }

    Future<void> pickImage() async {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      final bytes = picked?.files.single.bytes;
      if (bytes == null || !context.mounted) return;
      await closeAndRun(
        () => repo.setScenarioImage(osce.id, bytes),
        'Description image saved',
      );
    }

    return Column(
      children: [
        ListTile(
          onTap: move,
          leading: Icon(
            Icons.drive_file_move_outline,
            color: context.colors.primaryContainer,
          ),
          title: const Text('Move to folder'),
          subtitle: const Text('Speciality folder for this station'),
        ),
        SwitchListTile(
          secondary: Icon(
            osce.isPaid ? Icons.workspace_premium : Icons.lock_open,
            color: context.colors.primaryContainer,
          ),
          title: const Text('Premium'),
          subtitle: Text(
            osce.isPaid ? 'Only for subscribers' : 'Free for everyone',
          ),
          value: osce.isPaid,
          onChanged: (isPaid) => closeAndRun(
            () => repo.setPremium(osce.id, isPaid),
            isPaid
                ? '"${osce.name}" is now Premium'
                : '"${osce.name}" is now free',
          ),
        ),
        ListTile(
          onTap: pickImage,
          leading: Icon(
            Icons.image_outlined,
            color: context.colors.primaryContainer,
          ),
          title: Text(
            hasImage ? 'Replace description image' : 'Add description image',
          ),
          subtitle: const Text('Shown with the station\'s description'),
          trailing: hasImage
              ? IconButton(
                  tooltip: 'Remove image',
                  icon: Icon(Icons.delete_outline, color: context.colors.error),
                  onPressed: () => closeAndRun(
                    () => repo.setScenarioImage(osce.id, null),
                    'Description image removed',
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

String stationCountLabel(int count) =>
    '$count ${count == 1 ? 'station' : 'stations'}';
