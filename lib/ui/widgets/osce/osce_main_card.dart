import 'package:flashcards/ui/widgets/core/images/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/bloc/osces/osce/osce_bloc.dart';
import 'package:flashcards/bloc/osces/osce/osce_state.dart';

class OsceMainCard extends StatelessWidget {
  const OsceMainCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(screenSize.width / 8),
            child: BlocSelector<OsceBloc, OsceState, (String, String, String?)>(
              selector: (state) {
                if (state is! OsceLoaded) {
                  throw Exception("Osce state is not loaded");
                }

                final osce = state.osce;
                return (osce.name, osce.scenario, osce.scenarioImageUrl);
              },
              builder: (context, tuple) {
                final name = tuple.$1;
                final scenario = tuple.$2;
                final imageUrl = tuple.$3;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.black, fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scenario,
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    if (imageUrl != null && imageUrl.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ImagePreview(downloadUrl: imageUrl, height: 160),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
