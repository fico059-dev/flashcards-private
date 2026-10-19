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
      title: Text("تصفير تقدّمك في حزمة $packName؟"),
      content: Text(
        "سيتم مسح كل بياناتك المتعلقة بهذه الحزمة، "
        "وستفقد تقدّمك السابق في بطاقاتها.\n\n"
        "ما يمكن التراجع عن هذا الإجراء، تبي تكمل؟",
      ),
      actions: [
        TextButton(
          onPressed: () => context.router.pop(),
          child: Text("إلغاء"),
        ),
        TextButton(
          onPressed: () {
            onDelete.call();
            context.router.pop();
          },
          child: Text("تصفير التقدّم", style: TextStyle(color: context.colors.error)),
        ),
      ],
    );
  }
}
