import 'package:auto_route/annotations.dart';
import 'package:flashcards/bloc/custom_session/session_tag_picker/session_tag_picker_cubit.dart';
import 'package:flashcards/bloc/custom_session/session_tag_picker/session_tag_picker_state.dart';
import 'package:flashcards/domain/models/flashcards/simple_pack/simple_pack.dart';
import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/card_factory.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class FlashcardTagSelectionPage extends StatefulWidget {
  final List<SimplePack> packs;

  const FlashcardTagSelectionPage({super.key, required this.packs});

  @override
  State<FlashcardTagSelectionPage> createState() =>
      _FlashcardTagSelectionPageState();
}

class _FlashcardTagSelectionPageState extends State<FlashcardTagSelectionPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<SessionTagPickerCubit>().loadAllTags(widget.packs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReadableWidth(
        maxWidth: 820,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardFactory.info(
                  title: Text("Select tags"),
                  subtitle: Text(
                    "Only cards that have ALL the tags you select are included, "
                    "e.g. Neoreview + 2025 gives cards tagged with both. "
                    "Select no tags to include every card.",
                  ),
                ),

                SizedBox(height: 16),

                BlocBuilder<SessionTagPickerCubit, SessionTagPickerState>(
                  builder: (context, state) {
                    switch (state) {
                      case SessionTagPickerInitial():
                        return Center(child: CircularProgressIndicator());
                      case SessionTagPickerLoaded(
                        :final allTagCounts,
                        :final selectedTags,
                      ):
                        if (allTagCounts.isEmpty) {
                          return Center(
                            child: Text(
                              "Looks like the packs you selected don't have "
                              "tags in them, you can skip this step.",
                            ),
                          );
                        }

                        final query = _query.trim().toLowerCase();
                        final entries = allTagCounts.entries
                            .where(
                              (e) =>
                                  query.isEmpty ||
                                  e.key.name.toLowerCase().contains(query),
                            )
                            .toList();
                        final selected = allTagCounts.keys
                            .where((tag) => selectedTags[tag.id] == true)
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SelectionSummary(selected: selected),
                            SizedBox(height: 12),
                            if (allTagCounts.length > 8)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) =>
                                      setState(() => _query = value),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.search),
                                    hintText: 'Search tags',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    isDense: true,
                                    suffixIcon: _query.isEmpty
                                        ? null
                                        : IconButton(
                                            tooltip: 'Clear search',
                                            icon: Icon(Icons.close),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() => _query = '');
                                            },
                                          ),
                                  ),
                                ),
                              ),
                            if (entries.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text('No tags match "$_query".'),
                              ),
                            ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              itemCount: entries.length,
                              itemBuilder: (context, index) {
                                final tagCount = entries[index];
                                return _TagCountItem(
                                  tagCount: tagCount,
                                  isSelected:
                                      selectedTags[tagCount.key.id] == true,
                                );
                              },
                            ),
                            SizedBox(height: 16),
                          ],
                        );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionSummary extends StatelessWidget {
  final List<Tag> selected;

  const _SelectionSummary({required this.selected});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SessionTagPickerCubit>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: selected.isEmpty
          ? Row(
              children: [
                Icon(Icons.all_inclusive, color: context.colors.primary),
                SizedBox(width: 10),
                Expanded(child: Text("No tags selected: all cards included")),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selected.length == 1
                            ? "Cards tagged:"
                            : "Cards with all ${selected.length} tags:",
                        style: context.text.labelLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: cubit.clearSelection,
                      child: Text("Clear"),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < selected.length; i++) ...[
                      if (i > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'AND',
                            style: context.text.labelSmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      InputChip(
                        label: Text(selected[i].name),
                        onDeleted: () => cubit.toggleTag(selected[i]),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ],
                ),
              ],
            ),
    );
  }
}

class _TagCountItem extends StatelessWidget {
  final MapEntry<Tag, int> tagCount;
  final bool isSelected;

  const _TagCountItem({required this.tagCount, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(tagCount.key.name),
      subtitle: Text('${tagCount.value} flashcards'),
      value: isSelected,
      onChanged: (value) {
        context.read<SessionTagPickerCubit>().toggleTag(tagCount.key);
      },
    );
  }
}
