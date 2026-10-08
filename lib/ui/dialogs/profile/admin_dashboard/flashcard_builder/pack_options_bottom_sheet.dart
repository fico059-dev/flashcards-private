import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/pack/admin_packs_getter/admin_packs_getter_bloc.dart';
import 'package:flashcards/bloc/pack/admin_packs_getter/admin_packs_getter_event.dart';
import 'package:flashcards/bloc/pack/delete_pack/delete_pack_cubit.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/delete_pack_dialog.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/export_pack.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/pack_access_page.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/pack_premium_dialog.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/rename_pack_dialog.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showPackOptionsBottomSheet(BuildContext context, AdminPack pack) {
  showModalBottomSheet(
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.grey.shade100,
    context: context,
    shape: bottomSheetShape,
    //
    builder: scrollableSheet((context) {
      void navigateTo(PageRouteInfo route) {
        context.router.pop();
        context.router.push(route);
      }

      return Padding(
        padding: bottomSheetPadding,
        child: Wrap(
          children: [
            Column(
              children: [
                ListTile(
                  leading: Icon(Icons.folder),
                  title: Text(pack.packName),
                  subtitle: Text("Flashcards: ${pack.flashcardsCount}"),
                ),

                Divider(),

                ListTile(
                  onTap: () => navigateTo(CreateFlashcardRoute(pack: pack)),
                  leading: Icon(
                    Icons.add_circle_outline,
                    color: context.colors.primary,
                  ),
                  title: Text("Add Flashcards"),
                ),
                ListTile(
                  onTap: () => navigateTo(AnkiImportRoute(pack: pack)),
                  leading: Icon(
                    Icons.upload_file,
                    color: context.colors.primary,
                  ),
                  title: Text("Import from Anki"),
                  subtitle: Text("Add a whole .apkg or .txt deck at once"),
                ),
                ListTile(
                  onTap: () =>
                      navigateTo(ManagePackFlashcardsRoute(pack: pack)),
                  leading: Icon(
                    Icons.edit_note,
                    color: context.colors.primaryContainer,
                  ),
                  title: Text("Edit/Delete Flashcards"),
                ),
                ListTile(
                  onTap: () {
                    context.router.pop();
                    showRenamePackDialog(context, pack, null);
                  },
                  leading: Icon(
                    Icons.drive_file_rename_outline,
                    color: context.colors.primaryContainer,
                  ),
                  title: Text("Rename Pack"),
                ),
                PackPremiumTile(
                  isPaid: pack.isPaid,
                  onTap: () async {
                    final getterBloc = context.read<AdminPacksGetterBloc>();
                    context.router.pop();
                    final isPaid = await showChangePackPremiumDialog(
                      context,
                      pack,
                    );
                    if (isPaid != null) {
                      getterBloc.add(AdminPacksGetterCacheRead());
                    }
                  },
                ),
                ListTile(
                  onTap: () async {
                    final getterBloc = context.read<AdminPacksGetterBloc>();
                    context.router.pop();
                    final saved = await showPackAccessPage(context, pack);
                    if (saved != null) {
                      getterBloc.add(AdminPacksGetterCacheRead());
                    }
                  },
                  leading: Icon(
                    pack.restricted ? Icons.lock_person : Icons.lock_open,
                    color: context.colors.primaryContainer,
                  ),
                  title: Text("Who can see this pack"),
                  subtitle: Text(
                    pack.restricted ? "Only chosen users" : "Everyone",
                  ),
                ),
                ExportPackTile(pack: pack),
                ListTile(
                  onTap: () async {
                    context.router.pop();
                    final cubit = DeletePackCubit(
                      packRepo: context.read<PackRepository>(),
                    );
                    await showDeletePackDialog(context, pack, cubit, null);
                    cubit.close();
                  },
                  leading: Icon(
                    Icons.delete_forever,
                    color: context.colors.error,
                  ),
                  title: Text("Delete Pack"),
                  subtitle: Text("Deletes the pack and all its flashcards"),
                  subtitleTextStyle: TextStyle(
                    color: context.colors.primaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }),
  );
}
