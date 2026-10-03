import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/manage_flashcards/manage_flashcards_bloc.dart';
import 'package:flashcards/bloc/flashcards/manage_flashcards/manage_flashcards_event.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/flashcard_builder/manage_flashcard_packs/delete_flashcard_dialog.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/manage_flashcards/update_flashcard_bottom_sheet.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showManageFlashcardBottomSheet(
  BuildContext context,
  Flashcard flashcard,
  String packId,
) {
  final bloc = context.read<ManageFlashcardsBloc>();

  void onUpdateDialog() async {
    context.router.pop();
    final isSuccessful = await showUpdateFlashcardBottomSheet(
      context,
      flashcard,
    );
    if (isSuccessful == true) {
      bloc.add(ManageFlashcardRefresh(packId: packId));
    }
  }

  void onDelete() async {
    final isSuccessful = await showDeleteFlashcardDialog(context, flashcard);
    if (isSuccessful == true) {
      bloc.add(ManageFlashcardRefresh(packId: packId));
      if (!context.mounted) return;
      context.router.pop();
    }
  }

  showModalBottomSheet(
    isScrollControlled: true,
    useSafeArea: true,
    context: context,
    showDragHandle: true,
    builder: scrollableSheet((context) {
      return BlocProvider.value(
        value: bloc,
        child: Builder(
          builder: (context) => Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
            height: 250,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.question_answer_outlined,
                    color: context.colors.primary,
                  ),
                  title: Text(
                    flashcard.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Divider(),

                ListTile(
                  onTap: onUpdateDialog,
                  leading: Icon(
                    Icons.edit,
                    color: context.colors.primaryContainer,
                  ),
                  title: Text("Edit Flashcard"),
                ),
                ListTile(
                  onTap: onDelete,
                  leading: Icon(
                    Icons.delete_forever,
                    color: context.colors.error,
                  ),
                  title: Text(
                    "Delete Flashcard",
                    style: TextStyle(color: context.colors.error),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }),
  );
}
