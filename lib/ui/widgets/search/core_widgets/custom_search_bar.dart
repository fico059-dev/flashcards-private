import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final void Function(String value) onChanged;
  final void Function(String value) onSubmit;

  /// If it's not provided the widget will create it's own controller
  final TextEditingController? controller;

  const CustomSearchBar({
    super.key,
    required this.onChanged,
    required this.onSubmit,
    this.controller,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmit,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'ابحث في البطاقات...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            _controller.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear), onPressed: _clear)
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
