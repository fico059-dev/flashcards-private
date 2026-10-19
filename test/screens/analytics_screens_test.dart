// Renders the admin analytics page to PNG files:
// flutter test test/screens/analytics_screens_test.dart
@Tags(['screens'])
library;

import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flashcards/domain/models/analytics/app_analytics.dart';
import 'package:flashcards/ui/pages/profile/admin_dashboard/analytics/analytics_page.dart';
import 'package:flashcards/ui/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> sampleAnalytics() {
  final random = Random(1);
  final start = DateTime.utc(2026, 7, 22);
  var total = 120;
  return {
    'generatedAt': '2026-10-19T12:00:00Z',
    'users': {
      'total': 640,
      'new7': 48,
      'new30': 190,
      'new30Previous': 150,
      'learnersEver': 470,
      'byProvider': {'password': 380, 'google.com': 200, 'apple.com': 60},
      'byEducation': {
        'medicalStudent': 300,
        'intern': 150,
        'juniorResident': 90,
        'notSet': 100,
      },
    },
    'activity': {
      'dau': 85,
      'wau': 240,
      'mau': 390,
      'avgDauLast7': 81.4,
      'stickiness': 20.9,
      'cardsAllTime': 412000,
      'newCardsAllTime': 160000,
      'cardsLast30': 98000,
      'cardsPerActiveDay': 62,
      'osceAttempts': 5400,
      'withGoal': 210,
      'avgStreak': 2.4,
      'streak3': 120,
    },
    'retention': {'d1': 54.0, 'd7': 38.5, 'd30': 24.0},
    'cohorts': [
      for (var i = 0; i < 8; i++)
        {
          'week': '2026-${i < 3 ? '08' : '09'}-${(i * 7 % 28 + 1).toString().padLeft(2, '0')}',
          'size': 30 + i * 5,
          'week1': i < 7 ? 60.0 - i : null,
          'week2': i < 6 ? 45.0 - i : null,
          'week4': i < 4 ? 30.0 - i : null,
        },
    ],
    'daily': [
      for (var i = 0; i < 90; i++)
        () {
          final signups = 2 + random.nextInt(4 + i ~/ 12);
          total += signups;
          final learners = 20 + i * 0.7 + random.nextInt(15);
          return {
            'date': start
                .add(Duration(days: i))
                .toIso8601String()
                .substring(0, 10),
            'signups': signups,
            'totalUsers': total,
            'activeLearners': learners.round(),
            'cardsStudied': (learners * (50 + random.nextInt(25))).round(),
            'newCards': (learners * 20).round(),
          };
        }(),
    ],
    'content': {'packs': 42, 'flashcards': 9800, 'osces': 120},
  };
}

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = File(
      '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter'}'
      '/bin/cache/artifacts/material_fonts/$file',
    ).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

void main() {
  test('summary and CSV', () {
    final data = AppAnalytics.fromJson(sampleAnalytics());
    expect(data.totalUsers, 640);
    expect(data.daily, hasLength(90));
    expect(data.signupGrowth!.round(), 27);
    final summary = data.summary();
    expect(summary, contains('640 total'));
    expect(summary, contains('54% day 1'));
    expect(data.dailyCsv().split('\n'), hasLength(91));
  });

  for (final (name, width, height, dark) in [
    ('analytics_phone', 390.0, 3000.0, false),
    ('analytics_desktop', 1200.0, 2300.0, true),
  ]) {
    testWidgets(name, (tester) async {
      await tester.runAsync(() async {
        await _loadFont('Roboto', [
          'Roboto-Regular.ttf',
          'Roboto-Medium.ttf',
          'Roboto-Bold.ttf',
        ]);
        await _loadFont('MaterialIcons', ['MaterialIcons-Regular.otf']);
      });
      tester.view.physicalSize = Size(width * 2, height * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? darkThemeData : lightThemeData,
          home: RepaintBoundary(
            key: key,
            child: Scaffold(
              appBar: AppBar(title: const Text('Analytics')),
              body: AnalyticsPage(load: () async => sampleAnalytics()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Total users'), findsWidgets);
      expect(find.text('Copy summary'), findsOneWidget);

      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory('build/screens')..createSync(recursive: true);
        File('${dir.path}/$name.png').writeAsBytesSync(
          data!.buffer.asUint8List(),
        );
      });
    });
  }
}
