import 'package:flashcards/ui/constants/styles.dart';
import 'package:flutter/material.dart';

class FilterDrawerCustom extends StatelessWidget {
  final bool show;
  final VoidCallback onClose;
  final Widget filterOptions;

  const FilterDrawerCustom({
    super.key,
    required this.show,
    required this.onClose,
    required this.filterOptions,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      top: 0,
      right: show ? 0 : -screenWidth * 0.8,
      width: screenWidth * 0.8,
      height: MediaQuery.of(context).size.height,
      child: Material(
        elevation: 12,
        color: Colors.white,
        child: Container(
          padding: bottomSheetPaddingWithTop,
          child: Column(
            children: [
              Row(
                children: [
                  Text("تصفية بالوسم"),
                  IconButton(icon: const Icon(Icons.close), onPressed: onClose),
                ],
              ),
              Expanded(child: filterOptions),
            ],
          ),
        ),
      ),
    );
  }
}
