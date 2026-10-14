import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_tag_picker_state.freezed.dart';

extension SessionTagPickerStateX on SessionTagPickerState {
  List<String> get selectedTagsList {
    final state = this;
    if (state is! SessionTagPickerLoaded) return [];

    return state.selectedTags.entries.map((e) => e.key).toList();
  }

  List<Tag> get selectedTagsObject {
    final state = this;
    if (state is! SessionTagPickerLoaded) return [];

    return state.selectedTags.keys.map((k) => Tag.fromId(k)).toList();
  }

  /// With no tags selected every card counts, so the card count is exact.
  /// Otherwise a card must have all the selected tags, which can only be
  /// estimated here.
  bool get isCountExact {
    final state = this;
    return state is! SessionTagPickerLoaded || state.selectedTags.isEmpty;
  }

  /// At most this many cards can have all the selected tags: the count of
  /// the rarest selected tag. Null when no tags are selected.
  int? get maxCardsWithAllTags {
    final state = this;
    if (state is! SessionTagPickerLoaded || state.selectedTags.isEmpty) {
      return null;
    }
    int? result;
    state.allTagCounts.forEach((tag, count) {
      if (state.selectedTags[tag.id] != true) return;
      if (result == null || count < result!) result = count;
    });
    return result ?? 0;
  }
}

@freezed
sealed class SessionTagPickerState with _$SessionTagPickerState {
  const factory SessionTagPickerState.initial() = SessionTagPickerInitial;

  const factory SessionTagPickerState.loaded({
    required bool? firstOptionChecked,
    required Map<Tag, int> allTagCounts,
    required Map<String, bool> selectedTags,
  }) = SessionTagPickerLoaded;
}
