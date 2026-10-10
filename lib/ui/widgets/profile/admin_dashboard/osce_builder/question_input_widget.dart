import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/osces/update_osce/forms/check_form/check_form.dart';
import 'package:flashcards/bloc/osces/update_osce/forms/question_form/question_form.dart';
import 'package:flashcards/domain/models/osce/osce_text_format.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/osce_builder/osce_text_dialog.dart';
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
  final int questionCount;

  const QuestionInputWidget({
    super.key,
    required this.questionForm,
    required this.onRemoveQuestion,
    required this.questionIndex,
    this.questionCount = 1,
  });

  Future<void> _editChecksAsText(BuildContext context) =>
      editChecksAsText(context, questionIndex, questionForm);

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
            Row(
              children: [
                Text(
                  'Question ${questionIndex + 1}',
                  style: TextTheme.of(context).titleSmall,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Move up',
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: questionIndex == 0
                      ? null
                      : () => context.read<UpdateOsceCubit>().moveQuestion(
                          questionIndex,
                          questionIndex - 1,
                        ),
                ),
                IconButton(
                  tooltip: 'Move down',
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: questionIndex >= questionCount - 1
                      ? null
                      : () => context.read<UpdateOsceCubit>().moveQuestion(
                          questionIndex,
                          questionIndex + 1,
                        ),
                ),
              ],
            ),
            // Question input
            TextFormField(
              minLines: 1,
              maxLines: 4,
              controller: questionForm.controller,
              decoration: const InputDecoration(labelText: 'Question Text'),
            ),
            const SizedBox(height: 8),
            _ChecksPreview(checkForms: questionForm.checkForms),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit_note),
                  label: const Text("Edit checks as text"),
                  onPressed: () => _editChecksAsText(context),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.list),
                  label: Text("Checks one by one ($checksCount)"),
                  onPressed: () => showChecksBottomSheet(
                    context: context,
                    questionIndex: questionIndex,
                  ),
                ),
              ],
            ),
            Row(
              children: [
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

/// Opens the checklist of a question as one text box and replaces it with
/// what the admin writes.
Future<void> editChecksAsText(
  BuildContext context,
  int questionIndex,
  QuestionForm questionForm,
) async {
  final cubit = context.read<UpdateOsceCubit>();
  final current = checklistToText(
    questionForm.checkForms
        .where((c) => c.controller.text.trim().isNotEmpty)
        .map(
          (c) => ParsedCheck(
            text: c.controller.text.trim(),
            isTitle: c.isTitle,
            score: int.tryParse(c.scoreController.text.trim()) ?? 1,
          ),
        ),
  );
  final text = await showOsceTextDialog(
    context: context,
    title: 'Checks for question ${questionIndex + 1}',
    actionLabel: 'Use these checks',
    describe: describeChecklistText,
    initialText: current,
    hint: checklistTextExample,
  );
  if (text == null) return;
  cubit.replaceChecks(questionIndex, parseChecklist(text));
}

/// A short read-only look at the checklist, so admins see it without opening
/// anything.
class _ChecksPreview extends StatelessWidget {
  final List<CheckForm> checkForms;

  const _ChecksPreview({required this.checkForms});

  @override
  Widget build(BuildContext context) {
    // Typing in the checks sheet changes the controllers, not the state.
    return ListenableBuilder(
      listenable: Listenable.merge([
        for (final c in checkForms) ...[c.controller, c.scoreController],
      ]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final filled = checkForms
        .where((c) => c.controller.text.trim().isNotEmpty)
        .toList();
    final muted = TextTheme.of(
      context,
    ).bodySmall?.copyWith(color: context.colors.onSurfaceVariant);
    if (filled.isEmpty) {
      return Text('No checks yet.', style: muted);
    }
    const shown = 6;
    final marks = filled
        .where((c) => !c.isTitle)
        .fold(
          0,
          (sum, c) => sum + (int.tryParse(c.scoreController.text.trim()) ?? 0),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final check in filled.take(shown))
          Text(
            check.isTitle
                ? check.controller.text.trim()
                : '•  ${check.controller.text.trim()}'
                      '${check.scoreController.text.trim() == '1' ? '' : '  (${check.scoreController.text.trim()})'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: check.isTitle
                ? TextTheme.of(
                    context,
                  ).bodySmall?.copyWith(fontWeight: FontWeight.w700)
                : muted,
          ),
        if (filled.length > shown)
          Text('…and ${filled.length - shown} more', style: muted),
        const SizedBox(height: 4),
        Text('Total: $marks marks', style: TextTheme.of(context).labelMedium),
      ],
    );
  }
}
