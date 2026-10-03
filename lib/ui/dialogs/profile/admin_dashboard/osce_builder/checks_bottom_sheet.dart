import 'package:flashcards/bloc/osces/update_osce/forms/question_form/question_form.dart';
import 'package:flashcards/bloc/osces/update_osce/update_osce_cubit.dart';
import 'package:flashcards/bloc/osces/update_osce/update_osce_state.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/custom_drag_handle.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/osce_builder/check_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showChecksBottomSheet({
  required BuildContext context,
  required int questionIndex,
}) {
  void removeCheck(int qIndex, int cIndex) async {
    context.read<UpdateOsceCubit>().removeCheck(qIndex, cIndex);
  }

  void toggleCheckTitle(int questionIndex, int checkIndex, bool value) {
    context.read<UpdateOsceCubit>().toggleCheckTitle(
      questionIndex,
      checkIndex,
      value,
    );
  }

  void addCheck() {
    context.read<UpdateOsceCubit>().addCheck(questionIndex);
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (bottomSheetContext) => BlocProvider.value(
      value: context.read<UpdateOsceCubit>(),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.97,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: bottomSheetHorizontalPadding.copyWith(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Scaffold(
            backgroundColor:
                context.theme.bottomSheetTheme.backgroundColor ??
                context.colors.surfaceContainerLow,
            floatingActionButton: FloatingActionButton(
              onPressed: addCheck,
              child: Icon(Icons.add, color: context.colors.onPrimary),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDragHandle(),
                Text(
                  "Question Checks",
                  style: TextTheme.of(
                    context,
                  ).titleLarge?.merge(TextStyle(fontWeight: FontWeight.w600)),
                ),
                SizedBox(height: 15),

                Expanded(
                  child:
                      BlocSelector<
                        UpdateOsceCubit,
                        UpdateOsceState,
                        QuestionForm
                      >(
                        selector: (state) {
                          if (state is! UpdateOsceLoaded) {
                            throw Exception("UpdateOsceState is not loaded");
                          }
                          final qForm = state.questionForms[questionIndex];
                          //print("Question shown: ${qForm.controller.text}");
                          return qForm;
                        },
                        builder: (context, questionForm) {
                          return ListView(
                            controller: scrollController,
                            // Room for the add button over the last check.
                            padding: const EdgeInsets.only(bottom: 96),
                            children: [
                              ...questionForm.checkForms.asMap().entries.map((
                                cEntry,
                              ) {
                                final cIndex = cEntry.key;
                                final cForm = cEntry.value;
                                return CheckInputWidget(
                                  cForm: cForm,
                                  cIndex: cIndex,
                                  onChanged: (value) => toggleCheckTitle(
                                    questionIndex,
                                    cIndex,
                                    value!,
                                  ),
                                  onRemoveCheck: () =>
                                      removeCheck(questionIndex, cIndex),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
