import 'package:flashcards/bloc/osce_performance_blocs/save_osce_attempt/save_osce_attempt_cubit.dart';
import 'package:flashcards/bloc/osce_performance_blocs/save_osce_attempt/save_osce_attempt_state.dart';
import 'package:flashcards/ui/dialogs/osce_performance/osce_attemps_botton_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OsceSubmitFloatingButton extends StatelessWidget {
  final String osceId;

  const OsceSubmitFloatingButton({super.key, required this.osceId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaveOsceAttemptCubit, SaveOsceAttemptState>(
      builder: (context, state) {
        switch (state) {
          case SaveOsceAttemptInitial():
          case SaveOsceAttemptLoading():
            return FloatingActionButton(
              tooltip:
                  "Previous attempts for this OSCE test. Currently loading...",
              onPressed: null,
              backgroundColor: Colors.grey,
              child: Icon(Icons.bar_chart),
            );
          case SaveOsceAttemptError():
          case SaveOsceAttemptSuccess():
            return FloatingActionButton(
              tooltip: "Previous attempts for this OSCE test.",
              onPressed: () =>
                  showOsceAttemptsBottomSheet(context: context, osceId: osceId),
              child: Icon(Icons.bar_chart),
            );
        }
      },
    );
  }
}
