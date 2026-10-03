import 'dart:convert';

/// The student's objective, used to draw the trajectory.
class StudyGoal {
  final DateTime? examDate;

  /// How many cards the student wants to have studied by the exam.
  final int? targetCards;

  /// OSCE score (in %) the student aims for on every station.
  final int targetOsceScore;

  const StudyGoal({this.examDate, this.targetCards, this.targetOsceScore = 70});

  bool get isEmpty => examDate == null && targetCards == null;

  StudyGoal copyWith({
    DateTime? Function()? examDate,
    int? Function()? targetCards,
    int? targetOsceScore,
  }) => StudyGoal(
    examDate: examDate == null ? this.examDate : examDate(),
    targetCards: targetCards == null ? this.targetCards : targetCards(),
    targetOsceScore: targetOsceScore ?? this.targetOsceScore,
  );

  Map<String, dynamic> toJson() => {
    if (examDate != null) 'examDate': dayKey(examDate!),
    if (targetCards != null) 'targetCards': targetCards,
    'targetOsceScore': targetOsceScore,
  };

  factory StudyGoal.fromJson(Map<String, dynamic> json) => StudyGoal(
    examDate: DateTime.tryParse(json['examDate'] as String? ?? ''),
    targetCards: (json['targetCards'] as num?)?.toInt(),
    targetOsceScore: (json['targetOsceScore'] as num?)?.toInt() ?? 70,
  );
}

/// What the student did on one day.
class DayActivity {
  final int reviews;
  final int newCards;
  final int forgotten;

  const DayActivity({this.reviews = 0, this.newCards = 0, this.forgotten = 0});

  DayActivity add({required bool isNew, required bool forgot}) => DayActivity(
    reviews: reviews + 1,
    newCards: newCards + (isNew ? 1 : 0),
    forgotten: forgotten + (forgot ? 1 : 0),
  );

  List<int> toJson() => [reviews, newCards, forgotten];

  factory DayActivity.fromJson(List<dynamic> json) => DayActivity(
    reviews: (json.elementAtOrNull(0) as num?)?.toInt() ?? 0,
    newCards: (json.elementAtOrNull(1) as num?)?.toInt() ?? 0,
    forgotten: (json.elementAtOrNull(2) as num?)?.toInt() ?? 0,
  );
}

/// Running totals for one OSCE question (section), to find weak areas.
class OsceQuestionLog {
  final String text;
  final int attempts;
  final int achieved;
  final int max;

  const OsceQuestionLog({
    required this.text,
    this.attempts = 0,
    this.achieved = 0,
    this.max = 0,
  });

  double get percent => max == 0 ? 0 : achieved / max;

  Map<String, dynamic> toJson() => {
    't': text,
    'n': attempts,
    'a': achieved,
    'm': max,
  };

  factory OsceQuestionLog.fromJson(Map<String, dynamic> json) =>
      OsceQuestionLog(
        text: json['t'] as String? ?? '',
        attempts: (json['n'] as num?)?.toInt() ?? 0,
        achieved: (json['a'] as num?)?.toInt() ?? 0,
        max: (json['m'] as num?)?.toInt() ?? 0,
      );
}

/// What the device has recorded about one OSCE station.
class OsceStationLog {
  final String name;
  final Map<String, OsceQuestionLog> questions;

  /// How many times each checklist item was missed.
  final Map<String, int> missedChecks;

  const OsceStationLog({
    required this.name,
    this.questions = const {},
    this.missedChecks = const {},
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'q': questions.map((key, value) => MapEntry(key, value.toJson())),
    'miss': missedChecks,
  };

  factory OsceStationLog.fromJson(Map<String, dynamic> json) => OsceStationLog(
    name: json['name'] as String? ?? '',
    questions: (json['q'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(
        key,
        OsceQuestionLog.fromJson(value as Map<String, dynamic>),
      ),
    ),
    missedChecks: (json['miss'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(key, (value as num).toInt()),
    ),
  );
}

/// One finished OSCE question, as recorded by [StudyLog.recordOsce].
class OsceQuestionResult {
  final String text;
  final int achieved;
  final int max;
  final List<String> missedChecks;

  const OsceQuestionResult({
    required this.text,
    required this.achieved,
    required this.max,
    required this.missedChecks,
  });
}

/// Study history kept on the device. Firestore only stores the current state
/// of every card, so the daily activity, the number of studied cards over time
/// and OSCE details are recorded here as the student studies.
class StudyLog {
  static const _keepDays = 400;

  final Map<String, DayActivity> days;

  /// Number of studied cards, recorded once per day the progress is opened.
  final Map<String, int> studiedSnapshots;
  final Map<String, OsceStationLog> osce;
  final StudyGoal goal;

  const StudyLog({
    this.days = const {},
    this.studiedSnapshots = const {},
    this.osce = const {},
    this.goal = const StudyGoal(),
  });

  StudyLog copyWith({
    Map<String, DayActivity>? days,
    Map<String, int>? studiedSnapshots,
    Map<String, OsceStationLog>? osce,
    StudyGoal? goal,
  }) => StudyLog(
    days: days ?? this.days,
    studiedSnapshots: studiedSnapshots ?? this.studiedSnapshots,
    osce: osce ?? this.osce,
    goal: goal ?? this.goal,
  );

  DayActivity activityOn(DateTime day) =>
      days[dayKey(day)] ?? const DayActivity();

  StudyLog recordReview({
    required DateTime now,
    required bool isNew,
    required bool forgot,
  }) {
    final key = dayKey(now);
    return copyWith(
      days: _trim({
        ...days,
        key: (days[key] ?? const DayActivity()).add(
          isNew: isNew,
          forgot: forgot,
        ),
      }, now),
    );
  }

  StudyLog recordStudiedCount(DateTime now, int studied) => copyWith(
    studiedSnapshots: _trim({...studiedSnapshots, dayKey(now): studied}, now),
  );

  StudyLog recordOsce({
    required String osceId,
    required String name,
    required List<OsceQuestionResult> results,
  }) {
    final station = osce[osceId] ?? OsceStationLog(name: name);
    final questions = {...station.questions};
    final missed = {...station.missedChecks};
    for (final result in results) {
      final current =
          questions[result.text] ?? OsceQuestionLog(text: result.text);
      questions[result.text] = OsceQuestionLog(
        text: result.text,
        attempts: current.attempts + 1,
        achieved: current.achieved + result.achieved,
        max: current.max + result.max,
      );
      for (final check in result.missedChecks) {
        missed[check] = (missed[check] ?? 0) + 1;
      }
    }
    return copyWith(
      osce: {
        ...osce,
        osceId: OsceStationLog(
          name: name,
          questions: questions,
          missedChecks: missed,
        ),
      },
    );
  }

  Map<String, T> _trim<T>(Map<String, T> map, DateTime now) {
    final oldest = dayKey(now.subtract(const Duration(days: _keepDays)));
    return Map.fromEntries(
      map.entries.where((entry) => entry.key.compareTo(oldest) >= 0),
    );
  }

  String encode() => jsonEncode({
    'days': days.map((key, value) => MapEntry(key, value.toJson())),
    'studied': studiedSnapshots,
    'osce': osce.map((key, value) => MapEntry(key, value.toJson())),
    'goal': goal.toJson(),
  });

  factory StudyLog.decode(String? source) {
    if (source == null || source.isEmpty) return const StudyLog();
    try {
      final json = jsonDecode(source) as Map<String, dynamic>;
      return StudyLog(
        days: (json['days'] as Map<String, dynamic>? ?? {}).map(
          (key, value) =>
              MapEntry(key, DayActivity.fromJson(value as List<dynamic>)),
        ),
        studiedSnapshots: (json['studied'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key, (value as num).toInt()),
        ),
        osce: (json['osce'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(
            key,
            OsceStationLog.fromJson(value as Map<String, dynamic>),
          ),
        ),
        goal: StudyGoal.fromJson(
          json['goal'] as Map<String, dynamic>? ?? const {},
        ),
      );
    } on Object {
      // A damaged log shouldn't break the app, start over.
      return const StudyLog();
    }
  }
}

/// Local calendar day as "yyyy-mm-dd", which also sorts by date.
String dayKey(DateTime date) {
  final local = date.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

DateTime startOfDay(DateTime date) {
  final local = date.toLocal();
  return DateTime(local.year, local.month, local.day);
}
