import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/osces/admin_osce_getter/admin_osce_getter_bloc.dart';
import 'package:flashcards/bloc/osces/admin_osce_getter/admin_osce_getter_event.dart';
import 'package:flashcards/bloc/osces/osce_dr/osce_dr_cubit.dart';
import 'package:flashcards/bloc/osces/osce_dr/osce_dr_state.dart';
import 'package:flashcards/data/repositories/osces/osce_repository.dart';
import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/bloc_buttons/bloc_button.dart';
import 'package:flashcards/ui/widgets/core/bloc_text_field.dart';
import 'package:flashcards/ui/widgets/core/loading_overlay_listener.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showRenameOsceBottomSheet(
  BuildContext context,
  SimpleOsce osce,
  AdminOsceGetterBloc readBloc,
) async {
  showModalBottomSheet(
    shape: bottomSheetShape,
    showDragHandle: true,
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return KeyboardAwareSheet(
        child: SingleChildScrollView(
          child: _Form(osce: osce, readBloc: readBloc),
        ),
      );
    },
  );
}

class _Form extends StatefulWidget {
  final SimpleOsce osce;
  final AdminOsceGetterBloc readBloc;

  const _Form({super.key, required this.osce, required this.readBloc});

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final TextEditingController _nameCont;
  late final TextEditingController _scenarioCont;

  @override
  void initState() {
    super.initState();
    _nameCont = TextEditingController(text: widget.osce.name);
    _scenarioCont = TextEditingController(text: widget.osce.scenario);
  }

  @override
  void dispose() {
    _nameCont.dispose();
    _scenarioCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (blocContext) =>
          OsceDrCubit(osceRepo: context.read<OsceRepository>()),
      child: Builder(
        builder: (context) {
          void onRename() {
            context.read<OsceDrCubit>().renameOsce(
              osceId: widget.osce.id!,
              name: _nameCont.text,
              scenario: _scenarioCont.text,
            );
          }

          return LoadingOverlayListener<OsceDrCubit, OsceDrState>(
            isLoading: (state) => state is OsceDrLoading,
            child: BlocListener<OsceDrCubit, OsceDrState>(
              listenWhen: (previous, current) =>
                  current is OsceDrSuccess || current is OsceDrError,
              listener: (context, state) {
                switch (state) {
                  case OsceDrSuccess():
                    widget.readBloc.add(AdminOsceGetterCacheRead());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Successfully updated OSCE "${_nameCont.text}"',
                        ),
                      ),
                    );
                    context.router.pop({
                      "name": _nameCont.text,
                      "scenario": _scenarioCont.text,
                    });
                    return;
                  case OsceDrError(:final error):
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(extractErrorMessage(error))),
                    );
                    context.router.pop();
                    return;
                  default:
                }
              },
              child: Padding(
                padding: bottomSheetPadding,
                child: Wrap(
                  children: [
                    Column(
                      spacing: 10,
                      children: [
                        Icon(
                          Icons.drive_file_rename_outline,
                          color: context.colors.primary,
                          size: 35,
                        ),
                        Text(
                          'Edit OSCE "${widget.osce.name}"',
                          style: TextTheme.of(context).titleLarge?.merge(
                            TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        SizedBox(height: 20),

                        BlocTextField<OsceDrCubit, OsceDrState>(
                          labelText: "New Name",
                          textEditingController: _nameCont,
                          // errorSelector:
                          //     (state) =>
                          //         state is OsceCrudFormInvalid
                          //             ? state.errors['name']
                          //             : null,
                          errorSelector: (state) => null,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: BlocTextField<OsceDrCubit, OsceDrState>(
                            minLines: 7,
                            maxLines: 20,
                            labelText: "New Scenario",
                            textEditingController: _scenarioCont,
                            // errorSelector:
                            //     (state) =>
                            //         state is OsceCrudFormInvalid
                            //             ? state.errors['scenario']
                            //             : null,
                            errorSelector: (state) => null,
                          ),
                        ),

                        SizedBox(height: 20),
                        Row(
                          spacing: 30,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: OutlinedButton(
                                  onPressed: () => context.router.pop(null),
                                  child: Text("Cancel"),
                                ),
                              ),
                            ),

                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: FilledButton(
                                  onPressed: onRename,
                                  child: Text("Save"),
                                ),
                                // child: BlocButton<OsceDrCubit, OsceDrState>.small(
                                //   isLoadingState:
                                //       (state) => state is OsceDrLoading,
                                //   onPressed: (_) => onRename(),
                                //   textString: ,
                                // ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
