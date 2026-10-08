import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcards/data/repositories/utils/user_claims.dart';

/// Who may see a pack. An admin can limit a pack to some users: the pack is
/// marked `restricted` and each allowed email has a list of the limited
/// packs it may open (pack_access_by_email). Admins see every pack.
class PackVisibility {
  final bool isAdmin;

  /// Limited packs opened to this user.
  final Set<String> openedPackIds;

  const PackVisibility({required this.isAdmin, required this.openedPackIds});

  bool allows(String packId, {required bool restricted}) =>
      !restricted || isAdmin || openedPackIds.contains(packId);

  static (DateTime, String, PackVisibility)? _cache;
  static const _cacheDuration = Duration(minutes: 1);

  /// Forgets the saved answer, e.g. after an admin changed access.
  static void invalidate() => _cache = null;

  static Future<PackVisibility> current() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const PackVisibility(isAdmin: false, openedPackIds: {});
    }
    final cache = _cache;
    if (cache != null &&
        cache.$2 == user.uid &&
        DateTime.now().difference(cache.$1) < _cacheDuration) {
      return cache.$3;
    }

    final claims = await UserClaims.current();
    var opened = <String>{};
    final email = user.email?.trim().toLowerCase();
    if (!claims.isAdmin && email != null && email.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('pack_access_by_email')
            .doc(email)
            .get();
        opened = List<String>.from(
          doc.data()?['packIds'] as List? ?? const [],
        ).toSet();
      } on Exception {
        // Not readable (e.g. older rules): limited packs stay hidden.
      }
    }
    final visibility = PackVisibility(
      isAdmin: claims.isAdmin,
      openedPackIds: opened,
    );
    _cache = (DateTime.now(), user.uid, visibility);
    return visibility;
  }
}
