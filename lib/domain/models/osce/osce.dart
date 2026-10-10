import 'package:flashcards/domain/enums/score_status.dart';
import 'package:flashcards/domain/models/osce/question/question.dart';
import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flashcards/domain/models/osce/question/question.dart';

part 'osce.freezed.dart';

@freezed
abstract class Osce with _$Osce {
  const factory Osce({
    required String id,
    required String name,
    required String scenario,
    required List<Question> questions,
    @Default(false) bool isPaid,
    String? folderId,
    String? scenarioImageUrl,
  }) = _Osce;

  factory Osce.fromSimpleOsce(
    SimpleOsce simpleOsce,
    List<Question> questions,
  ) => Osce(
    id: simpleOsce.id,
    name: simpleOsce.name,
    scenario: simpleOsce.scenario,
    questions: questions,
    isPaid: simpleOsce.isPaid,
    folderId: simpleOsce.folderId,
    scenarioImageUrl: simpleOsce.scenarioImageUrl,
  );
}

extension OsceX on Osce {
  int getMaxScore() => questions.fold(0, (sum, q) => sum + q.getMaxScore());

  int getAchievedScore() =>
      questions.fold(0, (sum, q) => sum + q.getAchievedScore());

  ScoreStatus getScoreStatus() {
    final maxScore = getMaxScore();
    final achievedScore = getAchievedScore();
    return calculateScoreStatus(achievedScore, maxScore);
  }

  SimpleOsce toSimpleOsce() => SimpleOsce(
    id: id,
    name: name,
    scenario: scenario,
    isPaid: isPaid,
    folderId: folderId,
    scenarioImageUrl: scenarioImageUrl,
  );
}
