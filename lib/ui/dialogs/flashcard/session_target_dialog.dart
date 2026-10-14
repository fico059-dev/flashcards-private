import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// What the student chose in [showSessionTargetDialog].
sealed class SessionTargetChoice {
  const SessionTargetChoice();
}

class SessionTargetSet extends SessionTargetChoice {
  final int target;

  const SessionTargetSet(this.target);
}

class SessionTargetDefault extends SessionTargetChoice {
  const SessionTargetDefault();
}

/// Asks how many cards a session of this pack should have.
Future<SessionTargetChoice?> showSessionTargetDialog({
  required BuildContext context,
  required String packName,
  required int current,
}) {
  final controller = TextEditingController(text: '$current');
  return showDialog<SessionTargetChoice>(
    context: context,
    builder: (context) {
      void save() {
        final value = int.tryParse(controller.text.trim());
        if (value == null || value < 1 || value > 1000) return;
        Navigator.of(context).pop(SessionTargetSet(value));
      }

      return AlertDialog(
        title: const Text('Cards per session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How many cards to study each day in "$packName". '
              'Cards already studied today still count.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Cards for this pack',
                helperText: 'Between 1 and 1000',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => save(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(const SessionTargetDefault()),
            child: const Text('Use default'),
          ),
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
