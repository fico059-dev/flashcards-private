import 'dart:async';

import 'package:flashcards/bloc/osces/update_osce/update_osce_cubit.dart';
import 'package:flashcards/bloc/osces/update_osce/update_osce_state.dart';
import 'package:flashcards/data/repositories/osces/osce_repository.dart';
import 'package:flashcards/data/services/local/pdf_export_service.dart';
import 'package:flashcards/domain/models/core/image_data_wrapper.dart';
import 'package:flashcards/domain/models/osce/osce.dart';
import 'package:flashcards/domain/models/osce/osce_text_format.dart';
import 'package:flashcards/domain/models/osce/question/check/check.dart';
import 'package:flashcards/domain/models/osce/question/question.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

class _FakeOsceRepo implements OsceRepository {
  var _next = 0;
  final added = <Question>[];
  final updated = <Question>[];
  final List<Question> existing;
  Completer<void>? addGate;

  _FakeOsceRepo([this.existing = const []]);

  @override
  String generateQuestionId(String osceId) => 'new${_next++}';

  @override
  Future<Result<List<MapEntry<String, Question>>>> getQuestions(
    String osceId,
  ) async => Result.ok([for (final q in existing) MapEntry(q.id, q)]);

  @override
  Future<Result<void>> addQuestion({
    required String osceId,
    required Question question,
    required Object? questionImage,
  }) async {
    await addGate?.future;
    added.add(question);
    return Result.ok(null);
  }

  @override
  Future<Result<void>> updateQuestion({
    required String osceId,
    required Question question,
    ImageDataWrapper questionImageData = const ImageDataWrapper(),
  }) async {
    updated.add(question);
    return Result.ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<UpdateOsceCubit> _loaded(_FakeOsceRepo repo) async {
  final cubit = UpdateOsceCubit(osceRepo: repo)..loadQuestions('osce');
  await cubit.stream.firstWhere((s) => s is UpdateOsceLoaded);
  return cubit;
}

UpdateOsceLoaded _state(UpdateOsceCubit cubit) =>
    cubit.state as UpdateOsceLoaded;

void main() {
  test('pasted questions become new questions with their checks', () async {
    final repo = _FakeOsceRepo();
    final cubit = await _loaded(repo);

    cubit.addQuestionsFromText(
      parseOsceText('Q: History\nHistory:\n- Fever (2)\nQ: Plan\n- Admit'),
    );

    final forms = _state(cubit).questionForms;
    expect(forms.length, 2);
    expect(forms[0].controller.text, 'History');
    expect(forms[0].checkForms.length, 2);
    expect(forms[0].checkForms[0].isTitle, isTrue);
    expect(forms[0].checkForms[1].scoreController.text, '2');
    expect(forms.every((f) => f.isLocal), isTrue);
  });

  test('saving waits for new questions and saves them in order', () async {
    final repo = _FakeOsceRepo()..addGate = Completer();
    final cubit = await _loaded(repo);
    cubit.addQuestionsFromText(parseOsceText('Q: A\n- one\nQ: B\n- two (3)'));

    cubit.submitOSCEQuestions();
    await Future<void>.delayed(Duration.zero);
    // Not reported as saved while the questions are still being written.
    expect(_state(cubit).status, UpdateOsceStatus.loading);

    repo.addGate!.complete();
    await cubit.stream.firstWhere(
      (s) => s is UpdateOsceLoaded && s.status.isUpdateSuccessful,
    );
    expect(repo.added.map((q) => q.text), ['A', 'B']);
    expect(repo.added[1].checks.single.score, 3);
  });

  test('titles do not need a score to save', () async {
    final repo = _FakeOsceRepo();
    final cubit = await _loaded(repo);
    cubit.addQuestionsFromText(parseOsceText('Q: A\nHistory:\n- one'));
    _state(cubit).questionForms[0].checkForms[0].scoreController.text = '';

    cubit.submitOSCEQuestions();
    await cubit.stream.firstWhere(
      (s) => s is UpdateOsceLoaded && !s.status.isLoading,
    );
    expect(_state(cubit).status, UpdateOsceStatus.updateSuccessful);
  });

  test('a checklist edited as text replaces the old checks', () async {
    final repo = _FakeOsceRepo([
      const Question(
        id: 'q1',
        text: 'Existing',
        index: 0,
        checks: [
          Check(text: 'old', isTitle: false, isChecked: false, index: 0),
        ],
      ),
    ]);
    final cubit = await _loaded(repo);

    cubit.replaceChecks(0, parseChecklist('- new one\n- new two (2)'));
    final form = _state(cubit).questionForms.single;
    expect(form.checkForms.map((c) => c.controller.text), [
      'new one',
      'new two',
    ]);

    cubit.submitOSCEQuestions();
    await cubit.stream.firstWhere(
      (s) => s is UpdateOsceLoaded && s.status.isUpdateSuccessful,
    );
    expect(repo.updated.single.checks.map((c) => c.text), [
      'new one',
      'new two',
    ]);
  });

  test('questions can be moved', () async {
    final cubit = await _loaded(_FakeOsceRepo());
    cubit.addQuestionsFromText(parseOsceText('Q: A\nQ: B\nQ: C'));
    cubit.moveQuestion(2, 0);
    expect(_state(cubit).questionForms.map((f) => f.controller.text), [
      'C',
      'A',
      'B',
    ]);
    cubit.moveQuestion(0, -1);
    expect(_state(cubit).questionForms.first.controller.text, 'C');
  });

  test('the results PDF is made, even when an image cannot load', () async {
    final service = PdfExportService(
      theme: pw.ThemeData.base(),
      loadImage: (_) async => null,
    );
    const osce = Osce(
      id: 'o',
      name: 'Febrile infant',
      scenario: 'A 3 week old with fever.',
      scenarioImageUrl: 'https://example.com/a.jpg',
      questions: [
        Question(
          id: 'q',
          text: 'History',
          index: 0,
          imageDownloadUrl: 'https://example.com/b.jpg',
          checks: [
            Check(text: 'History', isTitle: true, isChecked: false, index: 0),
            Check(text: 'Fever', isTitle: false, isChecked: true, index: 1),
            Check(
              text: 'Feeding',
              isTitle: false,
              isChecked: false,
              index: 2,
              score: 2,
            ),
          ],
        ),
      ],
    );
    final bytes = await service.generateOscePdf(osce, date: DateTime(2026));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(1000));
  });

  test('PDF file names are safe', () {
    expect(
      pdfFileName('NICU: Febrile infant / day 1'),
      'NICU_Febrile_infant_day_1',
    );
    expect(pdfFileName('***'), 'OSCE');
  });
}
