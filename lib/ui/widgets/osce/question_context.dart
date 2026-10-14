import 'package:flashcards/bloc/osces/osce/osce_bloc.dart';
import 'package:flashcards/bloc/osces/osce/osce_state.dart';
import 'package:flashcards/domain/models/osce/question/question.dart';
import 'package:flashcards/ui/widgets/core/images/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuestionContext extends StatelessWidget {
  const QuestionContext({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OsceBloc, OsceState, Question>(
      selector: (state) {
        if (state is! OsceLoaded) {
          throw Exception("Osce is not in loaded state");
        }

        return state.currentQuestion;
      },
      builder: (context, question) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Center(
              child: ImagePreview(
                downloadUrl: question.imageDownloadUrl,
                height: 250,
                onTap: () => onUrlTap(context, question.imageDownloadUrl!),
                showTextWhenEmpty: false,
              ),
            ),
          ],
        );
      },
    );
  }
}
