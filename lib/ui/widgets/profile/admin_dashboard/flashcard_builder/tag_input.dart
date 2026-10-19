import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:flashcards/ui/widgets/core/tag_chip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TagInput extends StatefulWidget {
  final List<Tag> suggestedTags;
  final List<Tag> selectedTags;
  final void Function(Tag tag)? onTagAdded;
  final void Function(Tag tag)? onTagRemoved;

  const TagInput({
    super.key,
    required this.suggestedTags,
    required this.selectedTags,
    this.onTagAdded,
    this.onTagRemoved,
  });

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final TextEditingController _textController = TextEditingController();
  String? _errorText;
  static const int _maxTagLength = 15;

  void _addTag(String rawTag) {
    final tag = Tag.fromName(rawTag);
    if (tag.id.isEmpty) return;

    if (tag.id.length > _maxTagLength) {
      setState(() {
        _errorText = 'الوسم طويل (الحد الأقصى $_maxTagLength حرفاً)';
      });
      return;
    }

    final alreadySelected = widget.selectedTags.any((t) => t == tag);
    if (!alreadySelected) {
      setState(() {
        _errorText = null;
      });
      widget.onTagAdded?.call(tag);
    }

    _textController.clear();
  }

  void _removeTag(Tag tag) {
    widget.onTagRemoved?.call(tag);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 5,
          children: widget.selectedTags
              .map(
                (tag) =>
                    TagChip(label: tag.name, onDeleted: () => _removeTag(tag)),
                // (tag) => Chip(
                //   backgroundColor: Colors.indigo[50],
                //   label: Text(tag.name),
                //   onDeleted: () => _removeTag(tag),
                // ),
              )
              .toList(),
        ),
        const SizedBox(height: 14),
        RawAutocomplete<Tag>(
          textEditingController: _textController,
          focusNode: FocusNode(),
          optionsBuilder: (TextEditingValue textEditingValue) {
            final input = textEditingValue.text.trim().toLowerCase();
            if (input.isEmpty) return const Iterable<Tag>.empty();

            return widget.suggestedTags.where(
              (tag) => tag.name.toLowerCase().contains(input),
            );
          },
          displayStringForOption: (Tag tag) => tag.name,
          onSelected: (Tag selection) {
            _addTag(selection.name);
          },
          fieldViewBuilder:
              (context, textController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      CupertinoIcons.tag,
                      color: Colors.grey,
                      size: 22,
                    ),
                    labelText: 'أدخل الوسوم (اختياري)',
                    border: const OutlineInputBorder(),
                    errorText: _errorText,
                  ),
                  onSubmitted: _addTag,
                  onChanged: (value) {
                    if (_errorText != null && value.length <= _maxTagLength) {
                      setState(() {
                        _errorText = null;
                      });
                    }
                  },
                );
              },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      final Tag option = options.elementAt(index);
                      return ListTile(
                        title: Text(option.name),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
