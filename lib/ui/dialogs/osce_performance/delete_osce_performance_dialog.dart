import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/osce_performance_blocs/delete_osce_perf/delete_osce_perf_cubit.dart';
import 'package:flashcards/bloc/osce_performance_blocs/delete_osce_perf/delete_osce_perf_state.dart';
import 'package:flashcards/data/repositories/osces/osce_performance_repository.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/loading_overlay_listener.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<bool?> showDeleteOscePerformanceDialog({
  required BuildContext context,
  required String osceId,
}) async {
  return await showDialog(
    context: context,
    builder: (context) => BlocProvider(
      create: (context) => DeleteOscePerfCubit(
        perfRepo: context.read<OscePerformanceRepository>(),
      ),
      child: _Content(osceId: osceId),
    ),
  );
}

class _Content extends StatelessWidget {
  final String osceId;

  const _Content({super.key, required this.osceId});

  @override
  Widget build(BuildContext context) {
    void onDelete() {
      context.read<DeleteOscePerfCubit>().deleteEntirePerformance(
        osceId: osceId,
      );
    }

    return LoadingOverlayListener<DeleteOscePerfCubit, DeleteOscePerfState>(
      isLoading: (state) => state is DeleteOscePerfLoading,
      child: BlocListener<DeleteOscePerfCubit, DeleteOscePerfState>(
        listenWhen: (previous, current) =>
            current is DeleteOscePerfSuccess || current is DeleteOscePerfError,
        listener: (context, state) {
          switch (state) {
            case DeleteOscePerfSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Successfully deleted OSCE performance and all attempts.",
                  ),
                ),
              );
              context.router.pop(true);
              break;
            case DeleteOscePerfError(:final error):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(extractErrorMessage(error))),
              );
              context.router.pop(false);
              break;
            case DeleteOscePerfInitial():
            case DeleteOscePerfLoading():
              break;
          }
        },
        child: AlertDialog(
          icon: Icon(Icons.delete_forever),
          title: Text("Delete OSCE performance?"),
          content: Text(
            "Deleting this OSCE performance will permanently remove all saved attempts, "
            "including your best score and the date of your first attempt.\n\n"
            "If you want to keep your best score and first attempt date, you can manually "
            "delete individual attempts instead of the entire performance.\n\n"
            "This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => context.router.pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: onDelete,
              child: Text(
                "Delete performance and attempts",
                style: TextStyle(color: context.colors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
