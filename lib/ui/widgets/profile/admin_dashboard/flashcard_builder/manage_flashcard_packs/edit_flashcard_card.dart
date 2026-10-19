import 'package:flashcards/domain/models/flashcards/card_markup/card_markup.dart';
import 'package:flashcards/bloc/flashcards/manage_flashcards/manage_flashcards_bloc.dart';
import 'package:flashcards/bloc/flashcards/manage_flashcards/manage_flashcards_event.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/flashcard_builder/manage_flashcard_packs/delete_flashcard_dialog.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/flashcard_builder/manage_flashcard_packs/manage_flashcard_bottom_sheet.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/manage_flashcards/update_flashcard_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class EditFlashcardCard extends StatelessWidget {
  final Flashcard flashcard;
  final String packId;

  const EditFlashcardCard({
    super.key,
    required this.flashcard,
    required this.packId,
  });

  @override
  Widget build(BuildContext context) {
    void onUpdateDialog() async {
      final isSuccessful = await showUpdateFlashcardBottomSheet(
        context,
        flashcard,
      );
      if (isSuccessful == true) {
        if (!context.mounted) return;
        context.read<ManageFlashcardsBloc>().add(
          ManageFlashcardRefresh(packId: packId),
        );
      }
    }

    void onDelete() async {
      final isSuccessful = await showDeleteFlashcardDialog(context, flashcard);
      if (isSuccessful == true) {
        if (!context.mounted) return;
        context.read<ManageFlashcardsBloc>().add(
          ManageFlashcardRefresh(packId: packId),
        );
      }
    }

    return Slidable(
      key: ValueKey(flashcard.id),
      endActionPane: ActionPane(
        extentRatio: 0.6,
        motion: DrawerMotion(),
        children: [
          SlidableAction(
            backgroundColor: context.colors.error,
            onPressed: (context) => onDelete(),
            icon: Icons.delete_forever,
            label: 'Delete',
          ),
          SlidableAction(
            backgroundColor: context.customColors.info,
            onPressed: (context) => onUpdateDialog(),
            icon: Icons.edit,
            label: "Edit",
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: context.colors.secondaryContainer.withValues(alpha: 0.6),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onLongPress: () =>
              showManageFlashcardBottomSheet(context, flashcard, packId),
          child: Column(
            children: [
              ListTile(
                iconColor: context.colors.primaryContainer,
                leading: Icon(Icons.question_answer_outlined),
                title: Text(
                  plainCardText(flashcard.question),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: context.colors.onSecondaryContainer),
                ),
              ),
              ListTile(
                iconColor: context.colors.primaryContainer,
                leading: Icon(Icons.check_circle_outline),
                title: Text(
                  plainCardText(flashcard.answer),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: context.colors.onSecondaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
