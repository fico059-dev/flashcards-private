import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

enum Menu { ignore, report }

class PopupMenuButtonTopRow extends StatelessWidget {
  final VoidCallback? onIgnore;
  final VoidCallback? onReport;
  final bool enabled;

  const PopupMenuButtonTopRow({
    super.key,
    required this.onReport,
    required this.enabled,
    this.onIgnore,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
      enabled: enabled,
      icon: Icon(Icons.more_vert, color: context.colors.primaryContainer),
      itemBuilder:
          (context) => <PopupMenuEntry<Menu>>[
            if (onIgnore != null)
              PopupMenuItem(
                onTap: () => _showIgnoreDialog(context, onIgnore!),
                child: ListTile(
                  leading: Icon(
                    Icons.visibility_off,
                    color: context.colors.primary,
                  ),
                  title: Text("تجاهل"),
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: context.colors.primary,
                  ),
                ),
              ),
            PopupMenuItem(
              onTap: onReport,
              child: ListTile(
                leading: Icon(Icons.flag, color: context.colors.primary),
                title: Text("إبلاغ"),
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
    );
  }
}

void _showIgnoreDialog(BuildContext context, VoidCallback onIgnore) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text("تجاهل هذه البطاقة؟"),
          content: Text(
            "البطاقات المتجاهَلة ما تظهر في جلسات المراجعة القادمة. "
            "تقدر تسترجعها لاحقاً من الإعدادات.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("إلغاء"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("تجاهل"),
            ),
          ],
        ),
  );

  if (confirmed == true) onIgnore();
}
