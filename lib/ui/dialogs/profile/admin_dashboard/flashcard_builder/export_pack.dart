import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flashcards/data/repositories/flashcards/flashcard_repository.dart';
import 'package:flashcards/data/services/anki/anki_exporter.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Menu entry that exports the pack as an Anki compatible .txt file.
class ExportPackTile extends StatelessWidget {
  final AdminPack pack;

  const ExportPackTile({super.key, required this.pack});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // The menu closes, so keep what's needed from above it.
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        final repo = context.read<FlashcardRepository>();
        navigator.pop();
        exportPack(navigator.context, messenger, repo, pack);
      },
      leading: Icon(Icons.ios_share, color: context.colors.primaryContainer),
      title: const Text("Export Pack"),
      subtitle: const Text("Save all cards as an Anki file (.txt)"),
    );
  }
}

Future<void> exportPack(
  BuildContext context,
  ScaffoldMessengerState messenger,
  FlashcardRepository repo,
  AdminPack pack,
) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text("Preparing export…")),
          ],
        ),
      ),
    ),
  );

  final result = await repo.getAllFlashcardsInPack(pack.packId);
  if (context.mounted) Navigator.of(context).pop();

  switch (result) {
    case Error(:final error):
      messenger.showSnackBar(
        SnackBar(content: Text("Export failed: ${extractErrorMessage(error)}")),
      );
      return;
    case Ok(:final value) when value.isEmpty:
      messenger.showSnackBar(
        const SnackBar(content: Text("This pack has no flashcards to export")),
      );
      return;
    case Ok():
  }

  final cards = result.value;
  final content = buildAnkiExport(packName: pack.packName, cards: cards);
  try {
    final savedTo = await FilePicker.platform.saveFile(
      dialogTitle: 'Export "${pack.packName}"',
      fileName: ankiExportFileName(pack.packName),
      bytes: utf8.encode(content),
    );
    if (savedTo == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text("Exported ${cards.length} flashcards")),
    );
  } on Exception catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text("Export failed: ${extractErrorMessage(error)}")),
    );
  }
}
