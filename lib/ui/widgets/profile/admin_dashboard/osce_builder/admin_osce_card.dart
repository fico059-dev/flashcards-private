import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/osce_builder/osce_options_bottom_sheet.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/subs_status_icon.dart';
import 'package:flutter/material.dart';

class AdminOsceCard extends StatelessWidget {
  final SimpleOsce osce;

  const AdminOsceCard({super.key, required this.osce});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => showOsceOptionsBottomSheet(context, osce),
        tileColor: context.colors.secondaryContainer.withValues(alpha: 0.6),
        leading: Icon(
          Icons.assignment_outlined,
          color: context.colors.onSecondaryContainer,
        ),
        title: Text(
          osce.name,
          style: TextStyle(color: context.colors.onSecondaryContainer),
        ),
        trailing: SubsStatusIcon(
          isPaid: osce.isPaid,
          hasAccess: false,
          size: 20,
        ),
      ),
    );
  }
}
