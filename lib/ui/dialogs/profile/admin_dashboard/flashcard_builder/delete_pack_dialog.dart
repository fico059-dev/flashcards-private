import 'package:auto_route/auto_route.dart';
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
    builder: (context) {
      return BlocProvider.value(
        value: cubit,
        child: BlocListener<DeletePackCubit, DeletePackState>(
          listenWhen:
              (previous, current) =>
                  current is DeletePackSuccessful || current is DeletePackError,
          listener: (context, state) {
            switch (state) {
              case DeletePackError(:final error):
                context.router.pop(false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(extractErrorMessage(error))),
                );
                break;
              case DeletePackSuccessful():
                getterBloc?.add(AdminPacksGetterCacheRead());
                context.router.pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم حذف الحزمة "${pack.packName}"',
                    ),
                  ),
                );
                break;
              default:
            }
          },
          child: AlertDialog(
            title: Text('حذف حزمة "${pack.packName}"؟'),
            content: Text("يمكن حذف الحزمة فقط إذا كانت فارغة"),
            actions: [
              BlocBuilder<DeletePackCubit, DeletePackState>(
                builder: (context, state) {
                  return TextButton(
                    onPressed:
                        state is DeletePackLoading
                            ? null
                            : () => context.router.pop(),
                    child: Text("إلغاء"),
                  );
                },
              ),
              BlocButtonText<DeletePackCubit, DeletePackState>(
                textString: "حذف الحزمة",
                onPressed: () => cubit.deletePackIfEmpty(pack.packId),
                isLoadingState: (state) => state is DeletePackLoading,
              ),
            ],
          ),
        ),
      );
    },
  );
}
