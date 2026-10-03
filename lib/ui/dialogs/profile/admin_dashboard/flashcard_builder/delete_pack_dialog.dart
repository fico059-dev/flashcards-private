import 'package:flashcards/bloc/pack/admin_packs_getter/admin_packs_getter_bloc.dart';
import 'package:flashcards/bloc/pack/admin_packs_getter/admin_packs_getter_event.dart';
import 'package:flashcards/bloc/pack/delete_pack/delete_pack_cubit.dart';
import 'package:flashcards/bloc/pack/delete_pack/delete_pack_state.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/ui/widgets/core/bloc_buttons/bloc_button_text.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<bool?> showDeletePackDialog(
  BuildContext context,
  AdminPack pack,
  DeletePackCubit cubit,
  AdminPacksGetterBloc? getterBloc,
) {
  return showDialog<bool?>(
    context: context,
    // Deleting a big pack takes a while, keep the dialog until it's done.
    barrierDismissible: false,
    builder: (context) {
      return BlocProvider.value(
        value: cubit,
        child: BlocListener<DeletePackCubit, DeletePackState>(
          listenWhen: (previous, current) =>
              current is DeletePackSuccessful || current is DeletePackError,
          listener: (context, state) {
            switch (state) {
              case DeletePackError(:final error):
                Navigator.of(context).pop(false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(extractErrorMessage(error))),
                );
                break;
              case DeletePackSuccessful():
                getterBloc?.add(AdminPacksGetterCacheRead());
                Navigator.of(context).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Successfully deleted pack "${pack.packName}"',
                    ),
                  ),
                );
                break;
              default:
            }
          },
          child: AlertDialog(
            title: Text('Delete "${pack.packName}" pack?'),
            content: Text(
              pack.flashcardsCount == 0
                  ? "This empty pack will be deleted."
                  : "This permanently deletes the pack, its "
                        "${pack.flashcardsCount} flashcards with their images, "
                        "and every user's progress on them. "
                        "This can't be undone.",
            ),
            actions: [
              BlocBuilder<DeletePackCubit, DeletePackState>(
                builder: (context, state) {
                  return TextButton(
                    onPressed: state is DeletePackLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text("Cancel"),
                  );
                },
              ),
              BlocButtonText<DeletePackCubit, DeletePackState>(
                textString: pack.flashcardsCount == 0
                    ? "Delete pack"
                    : "Delete pack and ${pack.flashcardsCount} cards",
                onPressed: () => cubit.deletePack(pack.packId),
                isLoadingState: (state) => state is DeletePackLoading,
              ),
            ],
          ),
        ),
      );
    },
  );
}
