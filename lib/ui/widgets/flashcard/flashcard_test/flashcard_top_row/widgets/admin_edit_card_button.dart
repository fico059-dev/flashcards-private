import 'package:flashcards/bloc/profile/profile_reader/profile_reader_cubit.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_state.dart';
import 'package:flashcards/data/repositories/flashcards/flashcard_repository.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/domain/models/profile/profile.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/manage_flashcards/update_flashcard_bottom_sheet.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pencil button shown to admins while studying: opens the card editor and
/// reports the saved card, so the change shows straight away.
class AdminEditCardButton extends StatelessWidget {
  /// The card as stored (cloze not hidden), or null when there is none.
  final Flashcard? flashcard;
  final ValueChanged<Flashcard> onEdited;

  const AdminEditCardButton({
    super.key,
    required this.flashcard,
    required this.onEdited,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<ProfileReaderCubit, bool>((cubit) {
      final state = cubit.state;
      return state is ProfileReaderIsLoaded && state.profile.isAdmin;
    });
    final card = flashcard;
    if (!isAdmin || card == null || card.id == '-1') {
      return const SizedBox.shrink();
    }

    Future<void> edit() async {
      final saved = await showUpdateFlashcardBottomSheet(context, card);
      if (saved != true || !context.mounted) return;
      final result = await context.read<FlashcardRepository>().getFlashcard(
        card.id,
      );
      if (!context.mounted) return;
      switch (result) {
        case Ok<Flashcard>(:final value):
          onEdited(value);
        case Error<Flashcard>(:final error):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Card saved, but couldn't be reloaded: "
                "${extractErrorMessage(error)}",
              ),
            ),
          );
      }
    }

    return IconButton(
      tooltip: "Edit card (admin)",
      onPressed: edit,
      icon: Icon(Icons.edit_note, color: context.colors.primaryContainer),
    );
  }
}
