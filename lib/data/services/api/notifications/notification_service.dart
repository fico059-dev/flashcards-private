import 'dart:math';

import 'package:flashcards/data/services/local/local_storage_service.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final _random = Random();

  final titles = [
    "Time to review your flashcards!",
    "Boost your memory today 📚",
    "Quick review session awaits!",
    "Keep your streak alive!",
    "Come and solve flashcards",
  ];

  final bodies = [
    "Just 5 minutes to stay on track.",
    "Your due cards are ready!",
    "Stay sharp — review now.",
    "Consistency is the key to progress!",
    "You have due cards that need reviewing",
  ];

  String getRandomTitle() => titles[_random.nextInt(titles.length)];

  String getRandomBody() => bodies[_random.nextInt(bodies.length)];

  /// It will ask for iOS notification permission as soon as the app launches
  Future<void> init() async {
    // Local notifications aren't available on the web.
    if (kIsWeb) return;
    const androidInit = AndroidInitializationSettings('app_icon');
    // const iosInit = DarwinInitializationSettings(
    //   requestAlertPermission: false,
    //   requestBadgePermission: false,
    //   requestSoundPermission: false,
    // );
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);
  }

  tz.TZDateTime _nextInstanceOfHour(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);

    // If time for today is already passed, we move it to tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfDayAndHour(int weekday, int hour) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
    );

    // pomeramo na sledeći weekday ako je prošao danas
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  tz.TZDateTime _now() {
    return tz.TZDateTime.now(tz.local);
  }

  Future<void> requestIOSPermissions() async {
    if (kIsWeb) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }

  Future<Result<void>> scheduleReminderNotification(
    NotificationFrequency frequency,
  ) async {
    if (kIsWeb) return Result.ok(null);
    try {
      await _plugin.cancelAll();

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Daily flashcard reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      );

      switch (frequency) {
        case NotificationFrequency.none:
          break;
        case NotificationFrequency.onceDaily:
          await scheduleOncePerDayNotification(details);
          break;
        case NotificationFrequency.twiceDaily:
          await scheduleTwicePerDayNotifications(details);
          break;
        case NotificationFrequency.threePerWeek:
          await scheduleThreeTimesPerWeekNotifications(details);
          break;
        case NotificationFrequency.oncePerWeek:
          await scheduleOncePerWeekNotifications(details);
          break;
      }

      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  Future<void> scheduleOncePerDayNotification(
    NotificationDetails details,
  ) async {
    final scheduled = _nextInstanceOfHour(18); // every day at 18:00
    await _plugin.zonedSchedule(
      0,
      getRandomTitle(),
      getRandomBody(),
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexact,
      // this tells it to repeat every day at the same time
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleTwicePerDayNotifications(
    NotificationDetails details,
  ) async {
    final morning = _nextInstanceOfHour(10);
    final evening = _nextInstanceOfHour(18);
    // final morning = _now().add(const Duration(minutes: 1));
    // final evening = _now().add(const Duration(minutes: 2));

    await _plugin.zonedSchedule(
      0,
      getRandomTitle(),
      getRandomBody(),
      morning,
      details,
      androidScheduleMode: AndroidScheduleMode.inexact,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    await _plugin.zonedSchedule(
      1, // different ID
      getRandomTitle(),
      getRandomBody(),
      evening,
      details,
      androidScheduleMode: AndroidScheduleMode.inexact,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleOncePerWeekNotifications(
    NotificationDetails details,
  ) async {
    final schedule = _nextInstanceOfDayAndHour(DateTime.monday, 18);

    await _plugin.zonedSchedule(
      0,
      getRandomTitle(),
      getRandomBody(),
      schedule,
      details,
      androidScheduleMode: AndroidScheduleMode.inexact,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> scheduleThreeTimesPerWeekNotifications(
    NotificationDetails details,
  ) async {
    final monday = _nextInstanceOfDayAndHour(DateTime.monday, 18);
    final wednesday = _nextInstanceOfDayAndHour(DateTime.wednesday, 18);
    final friday = _nextInstanceOfDayAndHour(DateTime.friday, 18);

    await _plugin.zonedSchedule(
      0,
      getRandomTitle(),
      getRandomBody(),
      monday,
      details,
      androidScheduleMode: AndroidScheduleMode.inexact,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
    await _plugin.zonedSchedule(
      1,
      getRandomTitle(),
      getRandomBody(),
      wednesday,
      details,
      androidScheduleMode: AndroidScheduleMode.inexact,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
    await _plugin.zonedSchedule(
      2,
      getRandomTitle(),
      getRandomBody(),
      friday,
      details,
      androidScheduleMode: AndroidScheduleMode.inexact,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> showSimpleNotification(String title, String body) async {
    if (kIsWeb) return;
    const androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Default',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(0, title, body, notificationDetails);
  }
}
