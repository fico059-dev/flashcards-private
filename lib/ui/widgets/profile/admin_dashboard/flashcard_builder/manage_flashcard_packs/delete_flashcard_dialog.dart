import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/delete_flashcard/delete_flashcard_cubit.dart';
import 'package:flashcards/bloc/flashcards/delete_flashcard/delete_flashcard_state.dart';
import 'package:flashcards/data/repositories/flashcards/flashcard_repository.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/ui/widgets/core/bloc_buttons/bloc_button_text.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<bool?> showDeleteFlashcardDialog(
  BuildContext context,
  Flashcard flashcard,
) async {
  return await showDialog<bool?>(
    context: context,
    builder: (context) {
      return BlocProvider(
        create: (context) =>
            DeleteFlashcardCubit(fcRepo: context.read<FlashcardRepository>()),
        child: _Content(flashcard: flashcard),
      );
    },
  );
}

class _Content extends StatelessWidget {
  final Flashcard flashcard;

  const _Content({super.key, required this.flashcard});

  @override
  Widget build(BuildContext context) {
    void onDelete() {
      context.read<DeleteFlashcardCubit>().deleteFlashcard(flashcard);
    }

    return BlocListener<DeleteFlashcardCubit, DeleteFlashcardState>(
      listenWhen: (previous, current) =>
          current is DeleteFlashcardError || current is DeleteFlashcardSuccess,
      listener: (context, state) {
        switch (state) {
          case DeleteFlashcardError(:final error):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(extractErrorMessage(error))));
            context.router.pop(false);
            break;
          case DeleteFlashcardSuccess():
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Successfully deleted flashcard.")),
            );
            context.router.pop(true);
            break;
          case DeleteFlashcardLoading():
          case DeleteFlashcardInitial():
            break;
        }
      },
      child: AlertDialog(
        title: Text("Delete this flashcard?"),
        content: Text(
          "Deleting this flashcard will also remove all user data associated with it.\n"
          "This may take a few moments to complete.",
        ),
        actions: [
          BlocBuilder<DeleteFlashcardCubit, DeleteFlashcardState>(
            builder: (context, state) {
              final isLoading = state is DeleteFlashcardLoading;
              return TextButton(
                onPressed: isLoading ? null : () => context.router.pop(),
                child: Text("Cancel"),
              );
            },
          ),
          BlocButtonText<DeleteFlashcardCubit, DeleteFlashcardState>(
            isLoadingState: (state) => state is DeleteFlashcardLoading,
            onPressed: onDelete,
            textString: "Delete",
          ),
        ],
      ),
    );
  }
}
