import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Splits pasted text into emails: commas, semicolons, spaces or new lines
/// between them. Returns the valid ones (lower case) and the rest.
(List<String>, List<String>) parseEmails(String text) {
  final valid = <String>[];
  final invalid = <String>[];
  for (final part in text.split(RegExp(r'[\s,;]+'))) {
    final email = part.trim().toLowerCase();
    if (email.isEmpty) continue;
    if (_emailPattern.hasMatch(email)) {
      if (!valid.contains(email)) valid.add(email);
    } else {
      invalid.add(part.trim());
    }
  }
  return (valid, invalid);
}

/// Opens the page where the admin chooses who can see [pack].
/// Returns the saved email list, or null if nothing was saved.
Future<List<String>?> showPackAccessPage(BuildContext context, AdminPack pack) {
  return Navigator.of(context).push<List<String>>(
    MaterialPageRoute(builder: (_) => PackAccessPage(pack: pack)),
  );
}

class PackAccessPage extends StatefulWidget {
  final AdminPack pack;

  const PackAccessPage({super.key, required this.pack});

  @override
  State<PackAccessPage> createState() => _PackAccessPageState();
}

class _PackAccessPageState extends State<PackAccessPage> {
  final _input = TextEditingController();
  final List<String> _emails = [];
  late bool _limited = widget.pack.restricted;
  String _search = '';
  bool _saving = false;
  bool _loading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final result = await context.read<PackRepository>().getPackAccess(
      widget.pack.packId,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Ok<List<String>>(:final value):
          _emails
            ..clear()
            ..addAll(value);
          if (value.isNotEmpty) _limited = true;
        case Error<List<String>>(:final error):
          _loadError = error;
      }
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _addFromInput() {
    final (valid, invalid) = parseEmails(_input.text);
    final added = valid.where((e) => !_emails.contains(e)).toList();
    setState(() {
      _emails.addAll(added);
      _emails.sort();
      _input.text = invalid.join(', ');
    });
    if (invalid.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Not valid emails, left in the box: ${invalid.join(', ')}",
          ),
        ),
      );
    } else if (added.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added ${added.length} email(s). Press Save.")),
      );
    }
  }

  Future<void> _save() async {
    if (_limited && _input.text.trim().isNotEmpty) _addFromInput();
    final emails = _limited ? _emails : <String>[];
    if (_limited && emails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Add at least one email, or choose \"Everyone\" to open the pack.",
          ),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final result = await context.read<PackRepository>().setPackAccess(
      widget.pack.packId,
      emails,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    switch (result) {
      case Ok<List<String>>(:final value):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value.isEmpty
                  ? '"${widget.pack.packName}" is open to everyone'
                  : '"${widget.pack.packName}" is limited to '
                        '${value.length} user(s)',
            ),
          ),
        );
        Navigator.of(context).pop(value);
      case Error<List<String>>(:final error):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(extractErrorMessage(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = _emails
        .where((e) => e.contains(_search.trim().toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Who can see this pack"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _saving || _loading || _loadError != null
                  ? null
                  : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Save"),
            ),
          ),
        ],
      ),
      body: ReadableWidth(
        maxWidth: 720,
        child: ListView(
          padding: EdgeInsets.all(horizontalScreenPadding),
          children: [
            Text(widget.pack.packName, style: TextTheme.of(context).titleLarge),
            const SizedBox(height: 12),
            RadioGroup<bool>(
              groupValue: _limited,
              onChanged: (value) => setState(() => _limited = value ?? false),
              child: const Column(
                children: [
                  RadioListTile<bool>(
                    value: false,
                    title: Text("Everyone"),
                    subtitle: Text(
                      "All users see this pack (premium rules still apply).",
                    ),
                  ),
                  RadioListTile<bool>(
                    value: true,
                    title: Text("Only the users below"),
                    subtitle: Text(
                      "Other users don't see the pack at all. Admins always "
                      "see it.",
                    ),
                  ),
                ],
              ),
            ),
            if (_limited) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _input,
                minLines: 1,
                maxLines: 6,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Add emails",
                  helperText:
                      "One or many: separate with commas, spaces or new lines",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: "Add",
                    icon: const Icon(Icons.person_add_alt_1),
                    onPressed: _addFromInput,
                  ),
                ),
                onSubmitted: (_) => _addFromInput(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    "${_emails.length} user(s) can see this pack",
                    style: TextTheme.of(context).titleSmall,
                  ),
                  const Spacer(),
                  if (_emails.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(_emails.clear),
                      child: const Text("Remove all"),
                    ),
                ],
              ),
              if (_emails.length > 8)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Find an email",
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _search = value),
                  ),
                ),
              for (final email in shown)
                ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.person_outline,
                    color: context.colors.primary,
                  ),
                  title: Text(email),
                  trailing: IconButton(
                    tooltip: "Remove",
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _emails.remove(email)),
                  ),
                ),
              if (_emails.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text("No users added yet."),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
