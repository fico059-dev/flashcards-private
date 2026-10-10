import 'package:flashcards/domain/models/osce/osce_text_format.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

/// A large text box for writing or pasting OSCE content, with a live count of
/// what will be created. Returns the text, or null when cancelled.
Future<String?> showOsceTextDialog({
  required BuildContext context,
  required String title,
  required String actionLabel,
  required String Function(String text) describe,
  String initialText = '',
  String hint = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _OsceTextDialog(
      title: title,
      actionLabel: actionLabel,
      describe: describe,
      initialText: initialText,
      hint: hint,
    ),
  );
}

/// "2 questions, 9 checks" for [parseOsceText].
String describeOsceText(String text) {
  final questions = parseOsceText(text);
  final checks = questions.fold(
    0,
    (sum, q) => sum + q.checks.where((c) => !c.isTitle).length,
  );
  return '${_plural(questions.length, 'question')}, '
      '${_plural(checks, 'check')}';
}

/// "9 checks, 2 titles, 11 marks" for [parseChecklist].
String describeChecklistText(String text) {
  final parsed = parseChecklist(text);
  final checks = parsed.where((c) => !c.isTitle).toList();
  final titles = parsed.length - checks.length;
  final marks = checks.fold(0, (sum, c) => sum + c.score);
  return [
    _plural(checks.length, 'check'),
    if (titles > 0) _plural(titles, 'title'),
    _plural(marks, 'mark'),
  ].join(', ');
}

String _plural(int count, String word) =>
    '$count $word${count == 1 ? '' : 's'}';

class _OsceTextDialog extends StatefulWidget {
  final String title;
  final String actionLabel;
  final String Function(String text) describe;
  final String initialText;
  final String hint;

  const _OsceTextDialog({
    required this.title,
    required this.actionLabel,
    required this.describe,
    required this.initialText,
    required this.hint,
  });

  @override
  State<_OsceTextDialog> createState() => _OsceTextDialogState();
}

class _OsceTextDialogState extends State<_OsceTextDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return AlertDialog(
      title: Text(widget.title),
      insetPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: 640,
        height: size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              osceTextFormatHelp,
              style: TextTheme.of(
                context,
              ).bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                expands: true,
                maxLines: null,
                minLines: null,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.describe(_controller.text),
              style: TextTheme.of(context).labelLarge,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }
}

const osceTextExample =
    'Q: Take a focused history from the mother\n'
    'History:\n'
    '- Introduces self and confirms identity\n'
    '- Asks about onset of fever (2)\n'
    '- Asks about feeding and wet nappies\n'
    'Q: Explain the management plan\n'
    '- Explains need for admission (2)\n'
    '- Checks understanding';

const checklistTextExample =
    'History:\n'
    '- Introduces self\n'
    '- Asks about fever (2)\n'
    'Examination:\n'
    '- Checks fontanelle';
