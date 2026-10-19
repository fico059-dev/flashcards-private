import 'package:intl/intl.dart';

/// One day of the app's numbers.
class AnalyticsDay {
  final DateTime date;
  final int signups;
  final int totalUsers;
  final int activeLearners;
  final int cardsStudied;
  final int newCards;

  const AnalyticsDay({
    required this.date,
    required this.signups,
    required this.totalUsers,
    required this.activeLearners,
    required this.cardsStudied,
    required this.newCards,
  });

  factory AnalyticsDay.fromJson(Map<String, dynamic> json) => AnalyticsDay(
    date: DateTime.parse(json['date'] as String),
    signups: _int(json['signups']),
    totalUsers: _int(json['totalUsers']),
    activeLearners: _int(json['activeLearners']),
    cardsStudied: _int(json['cardsStudied']),
    newCards: _int(json['newCards']),
  );
}

/// Users who signed up in one week, and how many came back later.
class SignupCohort {
  final DateTime week;
  final int size;

  /// Percent who studied 1, 2 and 4 weeks after signing up (null: too soon).
  final double? week1;
  final double? week2;
  final double? week4;

  const SignupCohort({
    required this.week,
    required this.size,
    this.week1,
    this.week2,
    this.week4,
  });

  factory SignupCohort.fromJson(Map<String, dynamic> json) => SignupCohort(
    week: DateTime.parse(json['week'] as String),
    size: _int(json['size']),
    week1: _double(json['week1']),
    week2: _double(json['week2']),
    week4: _double(json['week4']),
  );
}

/// The app's user and study numbers, for the admin dashboard.
class AppAnalytics {
  final DateTime generatedAt;

  final int totalUsers;
  final int new7;
  final int new30;
  final int new30Previous;
  final int learnersEver;
  final Map<String, int> byProvider;
  final Map<String, int> byEducation;

  /// Users who studied today (or yesterday), in the last 7 and 30 days.
  final int dau;
  final int wau;
  final int mau;
  final double avgDauLast7;

  /// Average daily learners as a percent of monthly learners.
  final double? stickiness;
  final int cardsAllTime;
  final int newCardsAllTime;
  final int cardsLast30;
  final int cardsPerActiveDay;
  final int osceAttempts;
  final int withGoal;
  final double avgStreak;
  final int streak3;

  /// Percent who studied again 1, 7 and 30+ days after signing up.
  final double? d1;
  final double? d7;
  final double? d30;

  final List<SignupCohort> cohorts;
  final List<AnalyticsDay> daily;

  final int packs;
  final int flashcards;
  final int osces;

  const AppAnalytics({
    required this.generatedAt,
    required this.totalUsers,
    required this.new7,
    required this.new30,
    required this.new30Previous,
    required this.learnersEver,
    required this.byProvider,
    required this.byEducation,
    required this.dau,
    required this.wau,
    required this.mau,
    required this.avgDauLast7,
    required this.stickiness,
    required this.cardsAllTime,
    required this.newCardsAllTime,
    required this.cardsLast30,
    required this.cardsPerActiveDay,
    required this.osceAttempts,
    required this.withGoal,
    required this.avgStreak,
    required this.streak3,
    required this.d1,
    required this.d7,
    required this.d30,
    required this.cohorts,
    required this.daily,
    required this.packs,
    required this.flashcards,
    required this.osces,
  });

  factory AppAnalytics.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> part(String key) =>
        Map<String, dynamic>.from(json[key] as Map? ?? const {});
    Map<String, int> counts(Object? value) => {
      for (final e in Map<String, dynamic>.from(
        value as Map? ?? const {},
      ).entries)
        e.key: _int(e.value),
    };
    final users = part('users');
    final activity = part('activity');
    final retention = part('retention');
    final content = part('content');
    return AppAnalytics(
      generatedAt: DateTime.parse(json['generatedAt'] as String).toLocal(),
      totalUsers: _int(users['total']),
      new7: _int(users['new7']),
      new30: _int(users['new30']),
      new30Previous: _int(users['new30Previous']),
      learnersEver: _int(users['learnersEver']),
      byProvider: counts(users['byProvider']),
      byEducation: counts(users['byEducation']),
      dau: _int(activity['dau']),
      wau: _int(activity['wau']),
      mau: _int(activity['mau']),
      avgDauLast7: _double(activity['avgDauLast7']) ?? 0,
      stickiness: _double(activity['stickiness']),
      cardsAllTime: _int(activity['cardsAllTime']),
      newCardsAllTime: _int(activity['newCardsAllTime']),
      cardsLast30: _int(activity['cardsLast30']),
      cardsPerActiveDay: _int(activity['cardsPerActiveDay']),
      osceAttempts: _int(activity['osceAttempts']),
      withGoal: _int(activity['withGoal']),
      avgStreak: _double(activity['avgStreak']) ?? 0,
      streak3: _int(activity['streak3']),
      d1: _double(retention['d1']),
      d7: _double(retention['d7']),
      d30: _double(retention['d30']),
      cohorts: [
        for (final c in json['cohorts'] as List? ?? const [])
          SignupCohort.fromJson(Map<String, dynamic>.from(c as Map)),
      ],
      daily: [
        for (final d in json['daily'] as List? ?? const [])
          AnalyticsDay.fromJson(Map<String, dynamic>.from(d as Map)),
      ],
      packs: _int(content['packs']),
      flashcards: _int(content['flashcards']),
      osces: _int(content['osces']),
    );
  }

  /// Growth of new sign-ups over the previous 30 days, in percent.
  double? get signupGrowth =>
      new30Previous == 0 ? null : (new30 - new30Previous) / new30Previous * 100;

  /// Percent of users who have studied at least once.
  double? get activation =>
      totalUsers == 0 ? null : learnersEver / totalUsers * 100;

  /// A short text to paste into an email or a slide.
  String summary() {
    final n = NumberFormat.decimalPattern();
    String pct(double? v) => v == null ? '–' : '${v.toStringAsFixed(0)}%';
    final growth = signupGrowth;
    return [
      'FlashPedz – key numbers (${DateFormat.yMMMd().format(generatedAt)})',
      '',
      'Users: ${n.format(totalUsers)} total, ${n.format(new30)} new in the '
          'last 30 days'
          '${growth == null ? '' : ' (${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(0)}% vs previous 30 days)'}',
      'Activation: ${pct(activation)} of users have studied',
      'Active learners: ${n.format(dau)} daily, ${n.format(wau)} weekly, '
          '${n.format(mau)} monthly (stickiness ${pct(stickiness)})',
      'Retention: ${pct(d1)} day 1, ${pct(d7)} day 7, ${pct(d30)} day 30',
      'Cards studied: ${n.format(cardsLast30)} in the last 30 days, '
          '${n.format(cardsAllTime)} all time',
      'Average session: ${n.format(cardsPerActiveDay)} cards per learner per '
          'study day',
      'OSCE questions practised: ${n.format(osceAttempts)}',
      'Learners with an exam goal: ${n.format(withGoal)}',
      'Content: ${n.format(packs)} packs, ${n.format(flashcards)} flashcards, '
          '${n.format(osces)} OSCE stations',
    ].join('\n');
  }

  /// The daily numbers as a spreadsheet (CSV).
  String dailyCsv() => [
    'date,signups,total_users,active_learners,cards_studied,new_cards',
    for (final d in daily)
      '${DateFormat('yyyy-MM-dd').format(d.date)},${d.signups},'
          '${d.totalUsers},${d.activeLearners},${d.cardsStudied},'
          '${d.newCards}',
  ].join('\n');
}

int _int(Object? value) => value is num ? value.toInt() : 0;

double? _double(Object? value) => value is num ? value.toDouble() : null;
