import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcards/utils/typedefs.dart';

/// صلاحيات المستخدم المخزّنة في الـ custom claims بتوكن Firebase.
///
/// - `roles`: مثل `admin`.
/// - `entitlements`: قائمة الاشتراكات الدائمة (مثل `premium`).
/// - `premiumExp`: وقت انتهاء الاشتراك المؤقت (ثوانٍ أو مللي ثانية).
class UserClaims {
  final List<String> roles;
  final List<String> entitlements;
  final int premiumExpMs;

  const UserClaims({
    required this.roles,
    required this.entitlements,
    required this.premiumExpMs,
  });

  bool get isAdmin => roles.contains('admin');

  int get _nowMs => DateTime.now().millisecondsSinceEpoch;

  /// هل يحق للمستخدم الوصول للحزم المدفوعة؟
  bool get hasCards {
    if (entitlements.contains('premium')) return true;
    return premiumExpMs > _nowMs;
  }

  static int _toMs(dynamic v) {
    if (v is num) {
      final n = v.toDouble();
      if (n <= 0) return 0;
      return n < 1e12 ? (n * 1000).round() : n.round();
    }
    return 0;
  }

  static List<String> _asStrList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  factory UserClaims.fromMap(JsonMap? map) {
    return UserClaims(
      roles: _asStrList(map?['roles']),
      entitlements: _asStrList(map?['entitlements']),
      premiumExpMs: _toMs(map?['premiumExp']),
    );
  }

  static Future<UserClaims> current() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const UserClaims(roles: [], entitlements: [], premiumExpMs: 0);
    }
    final token = await user.getIdTokenResult(true);
    final map =
        token.claims?.map((k, v) => MapEntry(k, v)) ?? <String, dynamic>{};
    return UserClaims.fromMap(map);
  }
}
