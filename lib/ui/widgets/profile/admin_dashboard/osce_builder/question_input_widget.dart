import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/osces/update_osce/forms/question_form/question_form.dart';
import 'package:flashcards/bloc/osces/update_osce/update_osce_cubit.dart';
import 'package:flashcards/bloc/osces/update_osce/update_osce_state.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/osce_builder/checks_bottom_sheet.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/images/image_picker_button.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuestionInputWidget extends StatelessWidget {
  final QuestionForm questionForm;
  final VoidCallback onRemoveQuestion;
  final int questionIndex;

  const QuestionInputWidget({
    super.key,
    required this.questionForm,
    required this.onRemoveQuestion,
    required this.questionIndex,
  });

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Are you sure you want to delete this question?"),
          content: const Text(
            "Deleting the question will delete all of its checks and the image "
            "attached to it immediately and you won't be able to revert this."
            "\n\nDo you want to continue?",
          ),
          actions: [
            TextButton(
              onPressed: () => context.router.pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                onRemoveQuestion.call();
                context.router.pop();
              },
              child: Text(
                "Delete the question",
                style: TextStyle(color: context.colors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final checksCount = questionForm.checkForms.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question input
            TextFormField(
              minLines: 1,
              maxLines: 4,
              controller: questionForm.controller,
              decoration: const InputDecoration(labelText: 'Question Text'),
            ),
            const SizedBox(height: 12),

            // Row sa dugmićima
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.list),
                  label: Text("Show Checks ($checksCount)"),
                  onPressed: () => showChecksBottomSheet(
                    context: context,
                    //questionForm: questionForm,
                    questionIndex: questionIndex,
                  ),
                ),
                const Spacer(),
                BlocBuilder<UpdateOsceCubit, UpdateOsceState>(
                  builder: (context, state) {
                    if (state is! UpdateOsceLoaded) {
                      return const SizedBox.shrink();
                    }

                    final imageData =
                        state.questionForms[questionIndex].imageData;
                    return ImagePickerButton(
                      label: "Question",
                      imageData: imageData,
                      onImageChanged: (imageData) => context
                          .read<UpdateOsceCubit>()
                          .questionImageChanged(questionIndex, imageData),
                      onError: (error) =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(extractErrorMessage(error))),
                          ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: context.colors.error),
                  tooltip: 'Delete Question',
                  onPressed: () => showConfirmationDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
