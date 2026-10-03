import 'package:flutter/material.dart';

/// Max length, matches the renameCustomSession function.
const maxSessionNameLength = 60;

/// Asks for a new session name. Returns null when cancelled or unchanged.
Future<String?> showRenameSessionDialog(
  BuildContext context, {
  required String currentName,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _RenameSessionDialog(currentName: currentName),
  );
}

class _RenameSessionDialog extends StatefulWidget {
  final String currentName;

  const _RenameSessionDialog({required this.currentName});

  @override
  State<_RenameSessionDialog> createState() => _RenameSessionDialogState();
}

class _RenameSessionDialogState extends State<_RenameSessionDialog> {
  late final _controller = TextEditingController(text: widget.currentName)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.currentName.length,
    );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    Navigator.of(
      context,
    ).pop(name.isEmpty || name == widget.currentName ? null : name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename session'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: maxSessionNameLength,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        decoration: const InputDecoration(
          labelText: 'Session name',
          hintText: 'e.g. Neoreview 2025',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
