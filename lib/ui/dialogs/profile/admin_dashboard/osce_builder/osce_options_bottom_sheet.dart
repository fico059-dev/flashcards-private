import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/osces/admin_osce_getter/admin_osce_getter_bloc.dart';
import 'package:flashcards/bloc/osces/admin_osce_getter/admin_osce_getter_event.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/osce_builder/osce_library_admin.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/osce/rename_osce_bottom_sheet.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/osce_builder/delete_osce_dialog.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showOsceOptionsBottomSheet(BuildContext context, SimpleOsce osce) {
  final readBloc = context.read<AdminOsceGetterBloc>();

  showModalBottomSheet(
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    context: context,
    builder: scrollableSheet((context) {
      void navigateTo(PageRouteInfo route) {
        context.router.pop();
        context.router.push(route);
      }

      return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
        child: Column(
          children: [
            ListTile(leading: Icon(Icons.folder), title: Text(osce.name)),
            Divider(),
            ListTile(
              onTap: () => navigateTo(QuestionEditorRoute(osceId: osce.id)),
              leading: Icon(
                Icons.edit_note,
                color: context.colors.primaryContainer,
              ),
              title: Text("Edit Questions"),
            ),
            ListTile(
              onTap: () {
                context.router.pop();
                showRenameOsceBottomSheet(context, osce, readBloc);
              },
              leading: Icon(
                Icons.drive_file_rename_outline,
                color: context.colors.primaryContainer,
              ),
              title: Text("Edit OSCE Description"),
            ),
            OsceStationAdminOptions(
              osce: osce,
              onChanged: () =>
                  readBloc.add(AdminOsceGetterRefresh(completer: null)),
            ),
            ListTile(
              onTap: () async {
                context.router.pop();
                await showDeleteOsceDialog(context, osce, readBloc);
              },
              leading: Icon(Icons.delete_forever, color: context.colors.error),
              title: Text("Delete OSCE"),
              subtitle: Text("Deleted items can not be recovered!"),
              subtitleTextStyle: TextStyle(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }),
  );
}
