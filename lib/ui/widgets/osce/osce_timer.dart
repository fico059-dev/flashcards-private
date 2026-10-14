import 'package:flashcards/bloc/osces/osce/osce_bloc.dart';
import 'package:flashcards/bloc/osces/osce/osce_event.dart';
import 'package:flashcards/bloc/osces/osce/osce_state.dart';
import 'package:flashcards/domain/models/osce/osce.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/timer_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OsceTimer extends StatelessWidget {
  const OsceTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OsceBloc, OsceState, Osce>(
      selector: (state) {
        if (state is! OsceLoaded) {
          throw Exception("Osce is not in loaded state");
        }

        return state.osce;
      },
      builder: (context, osce) {
        return TimerContainer<OsceBloc, OsceState>(
          key: const ValueKey('osce-timer'),
          // listenWhen:
          //     (previous, current) =>
          //         current is OsceLoaded && current.status.isLoaded,
          // shouldStartTimer:
          //     (state) => state is OsceLoaded && state.status.isLoaded,
          listenWhen: (previous, current) =>
              current is OsceLoaded && previous is! OsceLoaded,
          shouldStartTimer: (state) => state is OsceLoaded,
          mode: false,
          initialDuration: Duration(minutes: 10),
          onFinished: () {
            context.read<OsceBloc>().add(OsceChecklistOpened());
          },
        );
      },
    );
  }
}
