import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/pack/admin_packs_getter/admin_packs_getter_bloc.dart';
import 'package:flashcards/bloc/pack/admin_packs_getter/admin_packs_getter_event.dart';
import 'package:flashcards/bloc/pack/create_pack/create_pack_cubit.dart';
import 'package:flashcards/bloc/pack/create_pack/create_pack_state.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/domain/models/flashcards/simple_pack/simple_pack.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/core/bloc_buttons/bloc_button.dart';
import 'package:flashcards/ui/widgets/core/bloc_text_field.dart';
import 'package:flashcards/ui/widgets/core/card_factory.dart';
import 'package:flashcards/ui/widgets/core/custom_drag_handle.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<SimplePack?> showCreatePackDialog(BuildContext context) {
  final getterBloc = context.read<AdminPacksGetterBloc>();

  return showModalBottomSheet<SimplePack?>(
    shape: bottomSheetShape,
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return _Form(getterBloc: getterBloc, controller: scrollController);
        },
      );
    },
  );
}

class _Form extends StatefulWidget {
  final AdminPacksGetterBloc getterBloc;
  final ScrollController controller;

  const _Form({super.key, required this.getterBloc, required this.controller});

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final TextEditingController _nameCont;
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    _nameCont = TextEditingController();
  }

  @override
  void dispose() {
    _nameCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              CreatePackCubit(packRepo: context.read<PackRepository>()),
      child: Builder(
        builder: (context) {
          void onCreate() {
            context.read<CreatePackCubit>().createPack(
              _nameCont.text,
              isPaid: _isPaid,
            );
          }

          return BlocListener<CreatePackCubit, CreatePackState>(
            listenWhen:
                (previous, current) =>
                    current is CreatePackSuccessful ||
                    current is CreatePackError,
            listener: (context, state) {
              switch (state) {
                case CreatePackSuccessful(:final pack):
                  widget.getterBloc.add(AdminPacksGetterCacheRead());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Successfully created a pack ${_nameCont.text}",
                      ),
                    ),
                  );
                  context.router.pop(pack);
                  break;
                case CreatePackError(:final error):
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(extractErrorMessage(error))),
                  );
                  context.router.pop();
                  break;
                default:
              }
            },
            child: Padding(
              padding: bottomSheetHorizontalPadding,
              child: Column(
                children: [
                  CustomDragHandle(),
                  Text(
                    "Create new pack",
                    style: TextTheme.of(context).headlineMedium,
                  ),
                  const SizedBox(height: 34,),

                  SingleChildScrollView(
                    controller: widget.controller,
                    child: Column(
                      children: [
                        BlocTextField<CreatePackCubit, CreatePackState>(
                          errorSelector:
                              (state) =>
                                  state is CreatePackFormInvalid
                                      ? state.errors['packName']
                                      : null,
                          labelText: "Pack Name",
                          textEditingController: _nameCont,
                        ),
                        const SizedBox(height: 16),
                        CardFactory.info(
                          isThreeLine: true,
                          subtitle: Text(
                            "You can switch the pack between Free and "
                            "Premium later from the pack's menu.",
                          ),
                        ),
                        const SizedBox(height: 24),
                        SwitchListTile(
                          inactiveTrackColor: Colors.grey[400],
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.lock),
                          title: const Text("Premium"),
                          value: _isPaid,
                          onChanged: (v) => setState(() => _isPaid = v),
                        ),

                        const SizedBox(height: 24,),

                        SizedBox(
                          width: double.infinity,
                          child: BlocButton<
                            CreatePackCubit,
                            CreatePackState
                          >.small(
                            onPressed: (context) => onCreate(),
                            textString: "Create",
                            isLoadingState:
                                (state) => state is CreatePackLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
