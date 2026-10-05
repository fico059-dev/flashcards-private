import 'package:auto_route/auto_route.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/data/repositories/flashcards/flashcard_repository.dart';
import 'package:flashcards/data/repositories/flashcards/pack_card_bulk_actions.dart';
import 'package:flashcards/data/repositories/flashcards/tag_repository.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/domain/models/flashcards/pack_card_filter/pack_card_filter.dart';
import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/manage_flashcards/update_flashcard_bottom_sheet.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/flashcard_builder/manage_flashcard_packs/delete_flashcard_dialog.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/flashcard_builder/manage_flashcard_packs/edit_flashcard_shimmer.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Admin editor for the cards of one pack: search and filter the cards,
/// select some or all of them, and change them together.
@RoutePage()
class ManagePackFlashcardsPage extends StatefulWidget {
  final AdminPack pack;

  const ManagePackFlashcardsPage({super.key, required this.pack});

  @override
  State<ManagePackFlashcardsPage> createState() =>
      _ManagePackFlashcardsPageState();
}

class _ManagePackFlashcardsPageState extends State<ManagePackFlashcardsPage> {
  final _searchController = TextEditingController();

  List<Flashcard>? _cards;
  Exception? _error;
  bool _loading = true;
  PackCardFilter _filter = const PackCardFilter();
  final Set<String> _selected = {};

  AdminPack get _pack => widget.pack;

  List<Flashcard> get _visible => _filter.apply(_cards ?? const []);

  List<Flashcard> get _selectedCards =>
      (_cards ?? const []).where((c) => _selected.contains(c.id)).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await context
        .read<FlashcardRepository>()
        .getAllFlashcardsInPack(_pack.packId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Ok<List<Flashcard>>(:final value):
          _cards = value;
          final ids = value.map((c) => c.id).toSet();
          _selected.retainWhere(ids.contains);
        case Error<List<Flashcard>>(:final error):
          _error = error;
      }
    });
  }

  void _setFilter(PackCardFilter filter) => setState(() => _filter = filter);

  void _toggle(Flashcard card) => setState(() {
    if (!_selected.remove(card.id)) _selected.add(card.id);
  });

  /// Selects every card shown, or clears them if all are already selected.
  void _toggleAllVisible() {
    final visibleIds = _visible.map((c) => c.id);
    setState(() {
      if (visibleIds.every(_selected.contains)) {
        _selected.removeAll(visibleIds);
      } else {
        _selected.addAll(visibleIds);
      }
    });
  }

  Future<void> _edit(Flashcard card) async {
    final saved = await showUpdateFlashcardBottomSheet(context, card);
    if (saved == true) await _load();
  }

  Future<void> _deleteOne(Flashcard card) async {
    final deleted = await showDeleteFlashcardDialog(context, card);
    if (deleted == true) await _load();
  }

  PackCardBulkActions _bulk() => PackCardBulkActions(
    flashcardRepo: context.read<FlashcardRepository>(),
    tagRepo: context.read<TagRepository>(),
  );

  /// Runs a change on the selected cards with a progress dialog.
  Future<void> _runBulk(
    String title,
    String verb,
    Future<BulkOutcome> Function(
      void Function(int finished, int total) onProgress,
    )
    action,
  ) async {
    final progress = ValueNotifier<(int, int)>((0, _selected.length));
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(title),
          content: ValueListenableBuilder<(int, int)>(
            valueListenable: progress,
            builder: (context, value, _) {
              final (finished, total) = value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  LinearProgressIndicator(
                    value: total == 0 ? null : finished / total,
                  ),
                  Text("$finished of $total cards"),
                ],
              );
            },
          ),
        ),
      ),
    );

    final outcome = await action((finished, total) {
      progress.value = (finished, total);
    });
    navigator.pop();
    progress.dispose();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(outcome.describe(verb))));
    if (outcome.failed == 0) setState(_selected.clear);
    await _load();
  }

  Future<void> _addTagToSelected() async {
    final tag = await _pickNewTag(context);
    if (tag == null || !mounted) return;
    final cards = _selectedCards;
    await _runBulk(
      'Adding "${tag.name}"',
      'tagged',
      (onProgress) => _bulk().addTag(cards, tag, onProgress: onProgress),
    );
  }

  Future<void> _removeTagFromSelected() async {
    final cards = _selectedCards;
    final tags = PackCardFilter.tagsIn(cards);
    if (tags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("The selected cards have no tags.")),
      );
      return;
    }
    final tag = await showDialog<Tag>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Remove which tag?"),
        children: [
          for (final (tag, count) in tags)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(tag),
              child: Text("${tag.name}  ($count)"),
            ),
        ],
      ),
    );
    if (tag == null || !mounted) return;
    await _runBulk(
      'Removing "${tag.name}"',
      'untagged',
      (onProgress) => _bulk().removeTag(cards, tag, onProgress: onProgress),
    );
  }

  Future<void> _deleteSelected() async {
    final cards = _selectedCards;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete ${cards.length} cards?"),
        content: const Text(
          "They are removed from this pack and from every student's "
          "progress. This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _runBulk(
      'Deleting cards',
      'deleted',
      (onProgress) => _bulk().delete(cards, onProgress: onProgress),
    );
  }

  Future<void> _pickFilterTags() async {
    final result = await showModalBottomSheet<PackCardFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _TagFilterSheet(
        tags: PackCardFilter.tagsIn(_cards ?? const []),
        filter: _filter,
      ),
    );
    if (result != null) _setFilter(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pack.packName),
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            tooltip: "Reload",
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: "Add cards",
            onPressed: () =>
                context.router.push(CreateFlashcardRoute(pack: _pack)),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ReadableWidth(maxWidth: 900, child: _body()),
      bottomNavigationBar: _selected.isEmpty
          ? null
          : _SelectionBar(
              count: _selected.length,
              onAddTag: _addTagToSelected,
              onRemoveTag: _removeTagFromSelected,
              onDelete: _deleteSelected,
              onClear: () => setState(_selected.clear),
            ),
    );
  }

  Widget _body() {
    final cards = _cards;
    if (cards == null) {
      if (_error != null) {
        return ErrorScreen(
          errorMessage: extractErrorMessage(_error!),
          onReload: _load,
        );
      }
      return Padding(
        padding: EdgeInsets.all(horizontalScreenPadding),
        child: const EditFlashcardShimmer(),
      );
    }
    if (cards.isEmpty) return _EmptyPack(pack: _pack);

    final visible = _visible;
    final selectedVisible = visible.where((c) => _selected.contains(c.id));
    final allSelected =
        visible.isNotEmpty && selectedVisible.length == visible.length;
    final noneSelected = selectedVisible.isEmpty;
    final tagCount = _filter.tagIds.length;

    return Column(
      children: [
        if (_loading) const LinearProgressIndicator(minHeight: 2),
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalScreenPadding,
            12,
            horizontalScreenPadding,
            4,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (text) => _setFilter(_filter.copyWith(text: text)),
            decoration: InputDecoration(
              hintText: "Search question or answer",
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: const OutlineInputBorder(),
              suffixIcon: _filter.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _setFilter(_filter.copyWith(text: ''));
                      },
                    ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                avatar: const Icon(Icons.sell_outlined, size: 18),
                label: Text(
                  tagCount == 0
                      ? "Tags"
                      : "Tags: $tagCount (${_filter.matchAllTags ? 'all' : 'any'})",
                ),
                selected: tagCount > 0,
                onSelected: (_) => _pickFilterTags(),
              ),
              FilterChip(
                label: const Text("No tags"),
                selected: _filter.untaggedOnly,
                onSelected: (value) =>
                    _setFilter(_filter.copyWith(untaggedOnly: value)),
              ),
              FilterChip(
                label: const Text("Has image"),
                selected: _filter.images == ImageFilter.withImage,
                onSelected: (value) => _setFilter(
                  _filter.copyWith(
                    images: value ? ImageFilter.withImage : ImageFilter.any,
                  ),
                ),
              ),
              FilterChip(
                label: const Text("No image"),
                selected: _filter.images == ImageFilter.withoutImage,
                onSelected: (value) => _setFilter(
                  _filter.copyWith(
                    images: value ? ImageFilter.withoutImage : ImageFilter.any,
                  ),
                ),
              ),
              if (_filter.isActive)
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    _setFilter(const PackCardFilter());
                  },
                  child: const Text("Clear filters"),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalScreenPadding - 8,
          ),
          child: Row(
            children: [
              Checkbox(
                tristate: true,
                value: allSelected ? true : (noneSelected ? false : null),
                onChanged: visible.isEmpty ? null : (_) => _toggleAllVisible(),
              ),
              Text(_filter.isActive ? "Select all shown" : "Select all"),
              const Spacer(),
              Text(
                _filter.isActive
                    ? "${visible.length} of ${cards.length} cards"
                    : "${cards.length} cards",
                style: TextTheme.of(context).bodySmall,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: visible.isEmpty
              ? const Center(child: Text("No cards match these filters."))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      horizontalScreenPadding,
                      10,
                      horizontalScreenPadding,
                      24,
                    ),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final card = visible[index];
                      return _CardTile(
                        card: card,
                        selected: _selected.contains(card.id),
                        selecting: _selected.isNotEmpty,
                        onToggle: () => _toggle(card),
                        onEdit: () => _edit(card),
                        onDelete: () => _deleteOne(card),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _CardTile extends StatelessWidget {
  final Flashcard card;
  final bool selected;

  /// While some cards are selected, tapping a card selects it.
  final bool selecting;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CardTile({
    required this.card,
    required this.selected,
    required this.selecting,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasImage =
        (card.questionImageUrl?.isNotEmpty ?? false) ||
        (card.answerImageUrl?.isNotEmpty ?? false);
    final small = TextTheme.of(context).bodySmall;

    return Material(
      borderRadius: BorderRadius.circular(12),
      color: selected
          ? colors.primaryContainer.withValues(alpha: 0.35)
          : colors.secondaryContainer.withValues(alpha: 0.6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: selecting ? onToggle : onEdit,
        onLongPress: onToggle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(value: selected, onChanged: (_) => onToggle()),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      card.question,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      card.answer,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.onSecondaryContainer),
                    ),
                    if (card.tags.isNotEmpty || hasImage)
                      Wrap(
                        spacing: 6,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (hasImage)
                            Icon(
                              Icons.image_outlined,
                              size: 16,
                              color: colors.primary,
                            ),
                          for (final tag in card.tags)
                            Text("#${tag.name}", style: small),
                        ],
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text("Edit"),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text("Delete"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionBar extends StatelessWidget {
  final int count;
  final VoidCallback onAddTag;
  final VoidCallback onRemoveTag;
  final VoidCallback onDelete;
  final VoidCallback onClear;

  const _SelectionBar({
    required this.count,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onDelete,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: context.colors.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              IconButton(
                tooltip: "Clear selection",
                onPressed: onClear,
                icon: const Icon(Icons.close),
              ),
              Text(
                "$count selected",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onAddTag,
                icon: const Icon(Icons.sell_outlined),
                label: const Text("Add tag"),
              ),
              TextButton.icon(
                onPressed: onRemoveTag,
                icon: const Icon(Icons.label_off_outlined),
                label: const Text("Remove tag"),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.error,
                ),
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text("Delete"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chooses the tags to filter by, and whether cards need any or all of them.
class _TagFilterSheet extends StatefulWidget {
  final List<(Tag, int)> tags;
  final PackCardFilter filter;

  const _TagFilterSheet({required this.tags, required this.filter});

  @override
  State<_TagFilterSheet> createState() => _TagFilterSheetState();
}

class _TagFilterSheetState extends State<_TagFilterSheet> {
  late final Set<String> _ids = {...widget.filter.tagIds};
  late bool _matchAll = widget.filter.matchAllTags;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final shown = widget.tags
        .where((t) => t.$1.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text("Filter by tags", style: TextTheme.of(context).titleLarge),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text("Any selected tag")),
                ButtonSegment(value: true, label: Text("All selected tags")),
              ],
              selected: {_matchAll},
              onSelectionChanged: (value) =>
                  setState(() => _matchAll = value.first),
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: "Find a tag",
                prefixIcon: Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
            Expanded(
              child: widget.tags.isEmpty
                  ? const Center(child: Text("No card in this pack has tags."))
                  : ListView(
                      children: [
                        for (final (tag, count) in shown)
                          CheckboxListTile(
                            dense: true,
                            value: _ids.contains(tag.id),
                            title: Text(tag.name),
                            secondary: Text("$count"),
                            onChanged: (value) => setState(() {
                              if (value == true) {
                                _ids.add(tag.id);
                              } else {
                                _ids.remove(tag.id);
                              }
                            }),
                          ),
                      ],
                    ),
            ),
            SafeArea(
              top: false,
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(_ids.clear),
                      child: const Text("Clear"),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(
                        widget.filter.copyWith(
                          tagIds: {..._ids},
                          matchAllTags: _matchAll,
                        ),
                      ),
                      child: const Text("Show cards"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Asks for the tag to add: an existing one or a new name.
Future<Tag?> _pickNewTag(BuildContext context) async {
  final result = await context.read<TagRepository>().getAllTags();
  if (!context.mounted) return null;
  final allTags = switch (result) {
    Ok(:final value) => value,
    Error() => <Tag>[],
  };
  final controller = TextEditingController();
  final tag = await showDialog<Tag>(
    context: context,
    builder: (context) {
      void submit() {
        final name = controller.text.trim();
        if (name.isEmpty) return;
        final existing = allTags.where(
          (t) => t.name.toLowerCase() == name.toLowerCase() || t.id == name,
        );
        Navigator.of(
          context,
        ).pop(existing.isNotEmpty ? existing.first : Tag.fromName(name));
      }

      return AlertDialog(
        title: const Text("Add tag to selected cards"),
        content: SizedBox(
          width: 400,
          child: Autocomplete<Tag>(
            displayStringForOption: (tag) => tag.name,
            optionsBuilder: (value) {
              final text = value.text.trim().toLowerCase();
              if (text.isEmpty) return const [];
              return allTags
                  .where((t) => t.name.toLowerCase().contains(text))
                  .take(20);
            },
            onSelected: (tag) => controller.text = tag.name,
            fieldViewBuilder: (context, fieldController, focusNode, _) {
              fieldController.addListener(
                () => controller.text = fieldController.text,
              );
              return TextField(
                controller: fieldController,
                focusNode: focusNode,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Tag name",
                  helperText: "Pick an existing tag or type a new one",
                ),
                onSubmitted: (_) => submit(),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          FilledButton(onPressed: submit, child: const Text("Add")),
        ],
      );
    },
  );
  controller.dispose();
  return tag;
}

class _EmptyPack extends StatelessWidget {
  final AdminPack pack;

  const _EmptyPack({required this.pack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Text(
              'There are no flashcards in "${pack.packName}" pack',
              style: TextTheme.of(context).headlineSmall,
              textAlign: TextAlign.center,
            ),
            FilledButton(
              onPressed: () {
                context.router.pop();
                context.router.push(CreateFlashcardRoute(pack: pack));
              },
              child: const Text("Add Flashcards"),
            ),
          ],
        ),
      ),
    );
  }
}
