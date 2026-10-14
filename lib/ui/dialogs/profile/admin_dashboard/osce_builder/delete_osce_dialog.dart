import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/osces/admin_osce_getter/admin_osce_getter_bloc.dart';
import 'package:flashcards/bloc/osces/admin_osce_getter/admin_osce_getter_event.dart';
import 'package:flashcards/bloc/osces/osce_dr/osce_dr_cubit.dart';
import 'package:flashcards/bloc/osces/osce_dr/osce_dr_state.dart';
import 'package:flashcards/data/repositories/osces/osce_repository.dart';
import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';
import 'package:flashcards/ui/widgets/core/bloc_buttons/bloc_button_text.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showDeleteOsceDialog(
  BuildContext context,
  SimpleOsce osce,
  AdminOsceGetterBloc readBloc,
) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return BlocProvider(
        create: (context) =>
            OsceDrCubit(osceRepo: context.read<OsceRepository>()),
        child: _Content(readBloc: readBloc, osce: osce),
      );
    },
  );
}

class _Content extends StatelessWidget {
  final AdminOsceGetterBloc readBloc;
  final SimpleOsce osce;

  const _Content({super.key, required this.readBloc, required this.osce});

  @override
  Widget build(BuildContext context) {
    void onDelete() {
      context.read<OsceDrCubit>().deleteOsce(osce.id);
    }

    return BlocListener<OsceDrCubit, OsceDrState>(
      listenWhen: (previous, current) =>
          current is OsceDrSuccess || current is OsceDrError,
      listener: (context, state) {
        switch (state) {
          case OsceDrError(:final error):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(extractErrorMessage(error))));
            break;
          case OsceDrSuccess():
            readBloc.add(AdminOsceGetterCacheRead());
            context.router.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully deleted OSCE "${osce.name}"'),
              ),
            );
            break;
          default:
        }
      },
      child: AlertDialog(
        title: Text('Delete "${osce.name}" OSCE?'),
        content: Text(
          "All the data of ${osce.name} will be permanently removed!",
        ),
        actions: [
          TextButton(
            onPressed: () => context.router.pop(),
            child: Text("Cancel"),
          ),
          BlocButtonText<OsceDrCubit, OsceDrState>(
            textString: "Delete OSCE",
            onPressed: onDelete,
            isLoadingState: (state) => state is OsceDrLoading,
          ),
        ],
      ),
    );
  }
}
