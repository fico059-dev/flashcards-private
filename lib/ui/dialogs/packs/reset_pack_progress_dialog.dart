import 'package:auto_route/auto_route.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

void showResetPackProgressDialog(
  BuildContext context,
  String packName,
  VoidCallback onDelete,
) {
  showDialog(
    context: context,
    builder: (context) => _View(onDelete: onDelete, packName: packName),
  );
}

class _View extends StatelessWidget {
  final String packName;
  final VoidCallback onDelete;

  const _View({super.key, required this.packName, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Reset progress for pack $packName?"),
      content: Text(
        "This will erase all of your data related to this pack, "
        "losing all of your previous progress with flashcards from this pack.\n\n"
        "This action can't be undone, do you still want to proceed?",
      ),
      actions: [
        TextButton(
          onPressed: () => context.router.pop(),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            onDelete.call();
            context.router.pop();
          },
          child: Text(
            "Reset Progress",
            style: TextStyle(color: context.colors.error),
          ),
        ),
      ],
    );
  }
}
