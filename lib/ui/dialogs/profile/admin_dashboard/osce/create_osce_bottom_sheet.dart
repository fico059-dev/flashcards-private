import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/osces/admin_osce_getter/admin_osce_getter_bloc.dart';
import 'package:flashcards/bloc/osces/admin_osce_getter/admin_osce_getter_event.dart';
import 'package:flashcards/bloc/osces/osce_dr/osce_dr_cubit.dart';
import 'package:flashcards/bloc/osces/osce_dr/osce_dr_state.dart';
import 'package:flashcards/data/repositories/osces/osce_repository.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/bloc_buttons/bloc_button.dart';
import 'package:flashcards/ui/widgets/core/bloc_text_field.dart';
import 'package:flashcards/ui/widgets/core/card_factory.dart';
import 'package:flashcards/ui/widgets/core/custom_drag_handle.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showCreateOsceDialog(BuildContext context) {
  final readBloc = context.read<AdminOsceGetterBloc>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return KeyboardAwareSheet(
        child: DraggableScrollableSheet(
          minChildSize: 0.6,
          maxChildSize: 0.95,
          initialChildSize: 0.75,
          expand: false,
          builder: (context, scrollController) {
            return _Form(readBloc: readBloc, controller: scrollController);
          },
        ),
      );
    },
  );
}

class _Form extends StatefulWidget {
  final ScrollController controller;
  final AdminOsceGetterBloc readBloc;

  const _Form({super.key, required this.readBloc, required this.controller});

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final TextEditingController _nameCont;
  late final TextEditingController _scenarioCont;

  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    _nameCont = TextEditingController();
    _scenarioCont = TextEditingController();
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
      create: (context) =>
          OsceDrCubit(osceRepo: context.read<OsceRepository>()),
      child: Builder(
        builder: (context) {
          void onCreate() {
            context.read<OsceDrCubit>().createOsce(
              _nameCont.text.trim(),
              _scenarioCont.text.trim(),
              isPaid: _isPaid, // <── NOVO
            );
          }

          return BlocListener<OsceDrCubit, OsceDrState>(
            listenWhen: (previous, current) =>
                current is OsceDrSuccess || current is OsceDrError,
            listener: (context, state) {
              switch (state) {
                case OsceDrSuccess():
                  widget.readBloc.add(AdminOsceGetterCacheRead());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Successfully created OSCE - ${_nameCont.text}",
                      ),
                    ),
                  );
                  context.router.pop();
                  break;
                case OsceDrError(:final error):
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
                  const CustomDragHandle(),
                  Text(
                    "Create new OSCE",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  SingleChildScrollView(
                    controller: widget.controller,
                    child: Column(
                      children: [
                        BlocTextField<OsceDrCubit, OsceDrState>(
                          errorSelector: (state) => null,
                          labelText: "OSCE Name",
                          textEditingController: _nameCont,
                        ),
                        const SizedBox(height: 16),
                        BlocTextField<OsceDrCubit, OsceDrState>(
                          minLines: 3,
                          maxLines: 10,
                          errorSelector: (state) => null,
                          labelText: "OSCE Scenario",
                          textEditingController: _scenarioCont,
                        ),
                        const SizedBox(height: 24),
                        CardFactory.warning(
                          isThreeLine: true,
                          subtitle: Text(
                            "Once OSCE is created, its premium status cannot "
                            "be changed. You cannot switch OSCE from Free "
                            "to Paid or from Paid to Free.",
                          ),
                        ),

                        const SizedBox(height: 16),

                        SwitchListTile(
                          inactiveTrackColor: context.colors.outlineVariant,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Premium'),
                          value: _isPaid,
                          secondary: const Icon(Icons.lock),
                          onChanged: (v) => setState(() => _isPaid = v),
                        ),

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: BlocButton<OsceDrCubit, OsceDrState>.small(
                            onPressed: (context) => onCreate(),
                            textString: "Create",
                            isLoadingState: (state) => state is OsceDrLoading,
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
