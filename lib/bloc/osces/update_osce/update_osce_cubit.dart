import 'package:collection/collection.dart';
import 'package:flashcards/bloc/osces/update_osce/forms/check_form/check_form.dart';
import 'package:flashcards/bloc/osces/update_osce/forms/question_form/question_form.dart';
import 'package:flashcards/bloc/osces/update_osce/update_osce_state.dart';
import 'package:flashcards/data/repositories/osces/osce_repository.dart';
import 'package:flashcards/domain/models/core/image_data_wrapper.dart';
import 'package:flashcards/domain/models/osce/osce_text_format.dart';
import 'package:flashcards/domain/models/osce/question/question.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

CheckForm _checkFormFromParsed(ParsedCheck check) => CheckForm(
  controller: TextEditingController(text: check.text),
  scoreController: TextEditingController(text: check.score.toString()),
  isTitle: check.isTitle,
);

class UpdateOsceCubit extends Cubit<UpdateOsceState> {
  final OsceRepository _osceRepo;

  UpdateOsceCubit({required OsceRepository osceRepo})
    : _osceRepo = osceRepo,
      super(UpdateOsceInitial());

  void questionImageChanged(
    int questionIndex,
    ImageDataWrapper questionImageData,
  ) {
    final state = this.state;
    if (state is! UpdateOsceLoaded) return;

    final newForms = List.of(state.questionForms);
    newForms[questionIndex] = newForms[questionIndex].copyWith(
      imageData: questionImageData,
    );

    emit(state.copyWith(questionForms: newForms));
  }

  void loadQuestions(String osceId) async {
    if (state is! UpdateOsceInitial) return;

    emit(UpdateOsceLoading());

    final result = await _osceRepo.getQuestions(osceId);
    switch (result) {
      case Error<List<MapEntry<String, Question>>>(:final error):
        emit(UpdateOsceError(error: error));
        return;
      case Ok<List<MapEntry<String, Question>>>():
    }
    final questionMap = result.value;

    final questionForms = questionMap
        .map((entry) => QuestionForm.fromQuestion(entry.value))
        .toList();
    emit(UpdateOsceLoaded(osceId: osceId, questionForms: questionForms));
  }

  /// It just adds the new question form, it's just local change, server is not
  /// called.
  void addQuestionForm() {
    final state = this.state;
    if (state is! UpdateOsceLoaded) return;

    final newForms = List.of(state.questionForms);

    newForms.add(
      QuestionForm.initial(_osceRepo.generateQuestionId(state.osceId)),
    );

    emit(
      state.copyWith(
        status: UpdateOsceStatus.initial,
        questionForms: newForms,
        error: null,
      ),
    );
  }

  /// Adds questions written as text (see [parseOsceText]). Like
  /// [addQuestionForm], nothing is saved until Save Changes.
  void addQuestionsFromText(List<ParsedQuestion> parsed) {
    final state = this.state;
    if (state is! UpdateOsceLoaded || parsed.isEmpty) return;

    final newForms = List.of(state.questionForms);
    for (final question in parsed) {
      final form = QuestionForm.initial(
        _osceRepo.generateQuestionId(state.osceId),
      );
      form.controller.text = question.text;
      newForms.add(
        form.copyWith(
          checkForms: question.checks.map(_checkFormFromParsed).toList(),
        ),
      );
    }

    emit(
      state.copyWith(
        status: UpdateOsceStatus.initial,
        questionForms: newForms,
        error: null,
      ),
    );
  }

  /// Replaces a question's whole checklist with checks written as text.
  void replaceChecks(int questionIndex, List<ParsedCheck> checks) {
    final state = this.state;
    if (state is! UpdateOsceLoaded) return;

    final newForms = List.of(state.questionForms);
    newForms[questionIndex] = newForms[questionIndex].copyWith(
      checkForms: checks.map(_checkFormFromParsed).toList(),
    );

    emit(
      state.copyWith(
        questionForms: newForms,
        status: UpdateOsceStatus.initial,
        error: null,
      ),
    );
  }

  /// Moves a question up or down in the list.
  void moveQuestion(int from, int to) {
    final state = this.state;
    if (state is! UpdateOsceLoaded) return;
    if (to < 0 || to >= state.questionForms.length || from == to) return;

    final newForms = List.of(state.questionForms);
    newForms.insert(to, newForms.removeAt(from));
    emit(
      state.copyWith(
        questionForms: newForms,
        status: UpdateOsceStatus.initial,
        error: null,
      ),
    );
  }

  /// It calls server to delete the question along with the image attached to it.
  void deleteQuestion(int index) async {
    final state = this.state;
    if (state is! UpdateOsceLoaded) return;

    final qForm = state.questionForms[index];
    final questionId = qForm.id;

    final newForms = List.of(state.questionForms);
    // it means the added question is locally added, it's not in db.
    // That means that we just delete it locally
    if (qForm.isLocal) {
      newForms.removeAt(index);
      emit(
        state.copyWith(
          status: UpdateOsceStatus.deleteSuccessful,
          questionForms: newForms,
        ),
      );
      return;
    }

    emit(state.copyWith(status: UpdateOsceStatus.loading, error: null));
    final deleteResult = await _osceRepo.deleteQuestion(
      osceId: state.osceId,
      questionId: questionId,
    );
    switch (deleteResult) {
      case Error<void>(:final error):
        emit(state.copyWith(status: UpdateOsceStatus.error, error: error));
        return;
      case Ok<void>():
    }

    newForms.removeAt(index);
    emit(
      state.copyWith(
        status: UpdateOsceStatus.deleteSuccessful,
        questionForms: newForms,
        error: null,
      ),
    );
  }

  void addCheck(int questionIndex) {
    final state = this.state;
    if (state is! UpdateOsceLoaded) return;

    final newForms = List.of(state.questionForms);
    final newChecks = List.of(newForms[questionIndex].checkForms);
    newChecks.add(CheckForm.initial());
    newForms[questionIndex] = newForms[questionIndex].copyWith(
      checkForms: newChecks,
    );

    emit(
      state.copyWith(
        questionForms: newForms,
        status: UpdateOsceStatus.initial,
        error: null,
      ),
    );
  }

  void removeCheck(int questionIndex, int checkIndex) {
    final state = this.state;
    if (state is! UpdateOsceLoaded) return;

    final newForms = List.of(state.questionForms);
    final newChecks = List.of(newForms[questionIndex].checkForms);
    newChecks.removeAt(checkIndex);
    newForms[questionIndex] = newForms[questionIndex].copyWith(
      checkForms: newChecks,
    );

    emit(
      state.copyWith(
        questionForms: newForms,
        status: UpdateOsceStatus.initial,
        error: null,
      ),
    );
  }

  void toggleCheckTitle(int questionIndex, int checkIndex, bool value) {
    final state = this.state;
    if (state is! UpdateOsceLoaded) return;

    final newForms = List.of(state.questionForms);
    final newChecks = List.of(newForms[questionIndex].checkForms);
    newChecks[checkIndex] = newChecks[checkIndex].copyWith(isTitle: value);
    newForms[questionIndex] = newForms[questionIndex].copyWith(
      checkForms: newChecks,
    );

    emit(
      state.copyWith(
        questionForms: newForms,
        status: UpdateOsceStatus.initial,
        error: null,
      ),
    );
  }

  void submitOSCEQuestions() async {
    final state = this.state;
    if (state is! UpdateOsceLoaded) return;

    emit(state.copyWith(status: UpdateOsceStatus.loading, error: null));

    final qForms = state.questionForms;

    // validate forms
    for (int i = 0; i < qForms.length; i++) {
      final qForm = qForms[i];
      for (int j = 0; j < qForm.checkForms.length; j++) {
        if (qForm.checkForms[j].isTitle) continue;
        final score = int.tryParse(
          qForm.checkForms[j].scoreController.text.trim(),
        );
        if (score == null || score < 1 || score > 1000) {
          emit(
            state.copyWith(
              error: Exception(
                "Question number ${i + 1} has invalid "
                "score for check number ${j + 1}. "
                "Score must be between 1 and 1000",
              ),
              status: UpdateOsceStatus.error,
            ),
          );
          return;
        }
      }
    }

    final futures = <Future<Result<void>>>[];
    for (int i = 0; i < qForms.length; i++) {
      final qForm = qForms[i];

      final newQuestion = qForm.toQuestion(i);

      if (qForm.isLocal) {
        final future = _osceRepo.addQuestion(
          osceId: state.osceId,
          question: newQuestion,
          questionImage: qForm.imageData.pickedImage,
        );
        futures.add(future);
        continue;
      }

      // It's the same of the question is not changed. No need to send the request then
      if (!qForm.isChanged(newQuestion)) continue;

      final future = _osceRepo.updateQuestion(
        osceId: state.osceId,
        question: newQuestion,
        questionImageData: qForm.imageData,
      );
      futures.add(future);
    }

    // Wait for every question, new ones included, before reporting success.
    final results = await Future.wait(futures);
    for (final result in results) {
      switch (result) {
        case Error(:final error):
          emit(state.copyWith(status: UpdateOsceStatus.error, error: error));
          return;
        case Ok():
      }
    }

    emit(state.copyWith(status: UpdateOsceStatus.updateSuccessful));
  }
}
