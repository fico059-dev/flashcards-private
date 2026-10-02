import 'package:flashcards/domain/models/flashcards/tag/tag.dart';

/// Tags Anki adds on its own, not useful in Flashpedz.
const _ignoredAnkiTags = {'leech', 'marked'};

/// Converts Anki tags into Flashpedz tags. Anki tags can be hierarchical
/// (`Cardiology::Arrhythmia`), only the last level is kept. Underscores are
/// how Anki writes spaces.
List<Tag> ankiTagsToTags(List<String> ankiTags) {
  final tags = <Tag>{};
  for (final ankiTag in ankiTags) {
    final name = ankiTag
        .split('::')
        .last
        .replaceAll('_', ' ')
        // Tag ids are used as Firestore document ids.
        .replaceAll(RegExp(r'[/.#\[\]]'), ' ')
        .trim();
    if (name.isEmpty || _ignoredAnkiTags.contains(name.toLowerCase())) {
      continue;
    }
    tags.add(Tag.fromName(name));
  }
  return tags.toList();
}
