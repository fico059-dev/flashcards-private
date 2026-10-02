import 'package:equatable/equatable.dart';

/// A user with the admin role, as listed in the admin dashboard.
class AdminUser extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;

  const AdminUser({required this.uid, this.email, this.displayName});

  factory AdminUser.fromMap(Map<String, dynamic> map) => AdminUser(
    uid: map['uid'] as String,
    email: map['email'] as String?,
    displayName: map['displayName'] as String?,
  );

  @override
  List<Object?> get props => [uid, email, displayName];
}
