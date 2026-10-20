import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flashcards/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

/// يرجع إعدادات Firebase الصحيحة للمنصة الحالية.
///
/// على الويب: إذا كان `firebase_options.dart` ما زال قالباً (REPLACE_ME)،
/// نقرأ الإعدادات الحقيقية من `/__/firebase/init.json` الذي يوفّره
/// Firebase Hosting تلقائياً لكل موقع منشور عليه.
Future<FirebaseOptions> resolveFirebaseOptions() async {
  final options = DefaultFirebaseOptions.currentPlatform;
  if (!kIsWeb || !options.apiKey.startsWith('REPLACE_ME')) return options;

  try {
    final body = await html.HttpRequest.getString('/__/firebase/init.json');
    final json = jsonDecode(body) as Map<String, dynamic>;
    return FirebaseOptions(
      apiKey: json['apiKey'] as String,
      appId: json['appId'] as String,
      messagingSenderId: (json['messagingSenderId'] ?? '') as String,
      projectId: json['projectId'] as String,
      authDomain: json['authDomain'] as String?,
      storageBucket: json['storageBucket'] as String?,
      measurementId: json['measurementId'] as String?,
    );
  } catch (e) {
    debugPrint('تعذّر تحميل /__/firebase/init.json: $e');
    return options;
  }
}
