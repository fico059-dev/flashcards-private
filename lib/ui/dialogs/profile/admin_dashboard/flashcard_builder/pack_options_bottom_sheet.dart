import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/pack/delete_pack/delete_pack_cubit.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/delete_pack_dialog.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/rename_pack_dialog.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showPackOptionsBottomSheet(BuildContext context, AdminPack pack) {
  showModalBottomSheet(
    showDragHandle: true,
    backgroundColor: Colors.grey.shade100,
    context: context,
    shape: bottomSheetShape,
    //
    builder: (context) {
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
                  subtitle: Text("عدد البطاقات: ${pack.flashcardsCount}"),
                ),

                Divider(),

                ListTile(
                  onTap: () => navigateTo(CreateFlashcardRoute(pack: pack)),
                  leading: Icon(
                    Icons.add_circle_outline,
                    color: context.colors.primary,
                  ),
                  title: Text("إضافة بطاقات"),
                ),
                ListTile(
                  onTap: () => navigateTo(AnkiImportRoute(pack: pack)),
                  leading: Icon(
                    Icons.upload_file,
                    color: context.colors.primary,
                  ),
                  title: Text("استيراد من Anki"),
                  subtitle: Text("أضف حزمة كاملة بملف .apkg أو .txt"),
                ),
                ListTile(
                  onTap:
                      () => navigateTo(ManagePackFlashcardsRoute(pack: pack)),
                  leading: Icon(Icons.edit_note, color: context.colors.primaryContainer),
                  title: Text("تعديل/حذف البطاقات"),
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
                  title: Text("إعادة تسمية الحزمة"),
                ),
                ListTile(
                  onTap: () async {
                    context.router.pop();
                    final cubit = DeletePackCubit(
                      packRepo: context.read<PackRepository>(),
                    );
                    await showDeletePackDialog(context, pack, cubit, null);
                    cubit.close();
                  },
                  leading: Icon(Icons.delete_forever, color: context.colors.error),
                  title: Text("حذف الحزمة"),
                  subtitle: Text("يمكن حذف الحزمة فقط إذا كانت فارغة"),
                  subtitleTextStyle: TextStyle(color: context.colors.primaryContainer),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
