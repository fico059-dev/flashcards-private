import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/pack/admin_packs_getter/admin_packs_getter_bloc.dart';
import 'package:flashcards/bloc/pack/admin_packs_getter/admin_packs_getter_event.dart';
import 'package:flashcards/bloc/pack/rename_pack/rename_pack_cubit.dart';
import 'package:flashcards/bloc/pack/rename_pack/rename_pack_state.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/bloc_buttons/bloc_button_text.dart';
import 'package:flashcards/ui/widgets/core/bloc_text_field.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// returns new name if it's updated successfully
Future<String?> showRenamePackDialog(
  BuildContext context,
  AdminPack pack,
  AdminPacksGetterBloc? getterBloc,
) async {
  return showDialog<String?>(
    context: context,
    builder: (context) {
      return _Form(pack: pack, getterBloc: getterBloc);
    },
  );
}

class _Form extends StatefulWidget {
  final AdminPack pack;
  final AdminPacksGetterBloc? getterBloc;

  const _Form({super.key, required this.pack, required this.getterBloc});

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final TextEditingController _nameCont;

  @override
  void initState() {
    super.initState();
    _nameCont = TextEditingController(text: widget.pack.packName);
  }

  @override
  void dispose() {
    _nameCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (blocContext) =>
          RenamePackCubit(packRepo: context.read<PackRepository>()),
      child: Builder(
        builder: (context) {
          void onRename() {
            context.read<RenamePackCubit>().renamePack(
              widget.pack.packId,
              _nameCont.text,
            );
          }

          return BlocListener<RenamePackCubit, RenamePackState>(
            listenWhen: (previous, current) =>
                current is RenamePackSuccess || current is RenamePackError,
            listener: (context, state) {
              switch (state) {
                case RenamePackSuccess(:final newName):
                  widget.getterBloc?.add(AdminPacksGetterCacheRead());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Successfully changed pack name to "${_nameCont.text}"',
                      ),
                    ),
                  );
                  context.router.pop(newName);
                  return;
                case RenamePackError(:final error):
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(extractErrorMessage(error))),
                  );
                  context.router.pop();
                  return;
                default:
              }
            },
            child: AlertDialog(
              title: Text('Rename pack "${widget.pack.packName}"'),
              icon: Icon(
                Icons.drive_file_rename_outline,
                color: context.colors.primary,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocTextField<RenamePackCubit, RenamePackState>(
                    errorSelector: (state) => state is RenamePackFormInvalid
                        ? state.errors['name']
                        : null,
                    textEditingController: _nameCont,
                    labelText: "New Name",
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => context.router.pop(null),
                  child: Text("Cancel"),
                ),
                SizedBox(
                  width: 80,
                  child: BlocButtonText<RenamePackCubit, RenamePackState>(
                    isLoadingState: (state) => state is RenamePackLoading,
                    onPressed: onRename,
                    textString: "Rename",
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
