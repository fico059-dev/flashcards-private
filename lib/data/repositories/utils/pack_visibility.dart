import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcards/data/repositories/utils/user_claims.dart';

/// Who may see a pack. An admin can limit a pack to a list of emails; packs
/// without a list are for everyone, and admins see every pack.
class PackVisibility {
  final String? email;
  final bool isAdmin;

  const PackVisibility({required this.email, required this.isAdmin});

  bool allows(List<String> allowedEmails) {
    if (allowedEmails.isEmpty || isAdmin) return true;
    final own = email?.trim().toLowerCase();
    return own != null && own.isNotEmpty && allowedEmails.contains(own);
  }

  static Future<PackVisibility> current() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const PackVisibility(email: null, isAdmin: false);
    final claims = await UserClaims.current();
    return PackVisibility(email: user.email, isAdmin: claims.isAdmin);
  }
}
