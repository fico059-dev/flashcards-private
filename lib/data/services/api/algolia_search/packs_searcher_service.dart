import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards/data/remote/firestore_db_context.dart';
import 'package:flashcards/domain/models/algolia/algolia_pack/algolia_pack.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flashcards/utils/typedefs.dart';

/// Loads the packs that pack search runs over. Search used to go through
/// Algolia, whose app no longer exists, so packs are read from Firestore and
/// searched on the device.
class PacksSearcherService {
  final CollectionReference<JsonMap> _packs;

  PacksSearcherService({required FirestoreDbContext dbContext})
    : _packs = dbContext.packs;

  Future<Result<List<AlgoliaPack>>> getAllPacks() async {
    try {
      QuerySnapshot<JsonMap> snapshot;
      try {
        snapshot = await _packs.orderBy('name').get();
      } on FirebaseException catch (error) {
        // Users without a subscription may only be allowed to read free packs
        if (error.code != 'permission-denied') rethrow;
        snapshot = await _packs
            .where('isPaid', isEqualTo: false)
            .orderBy('name')
            .get();
      }
      return Result.ok(
        snapshot.docs.map((doc) {
          final data = doc.data();
          return AlgoliaPack(
            objectID: doc.id,
            name: data['name'] as String? ?? '',
            tags: List<String>.from(data['tags'] as List? ?? const []),
            isPaid: data['isPaid'] as bool? ?? false,
          );
        }).toList(),
      );
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
