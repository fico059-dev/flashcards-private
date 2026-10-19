import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class FilterDrawer extends StatelessWidget {
  final Widget filterOptions;

  const FilterDrawer({super.key, required this.filterOptions});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            Container(
              color: context.colors.primaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الفلاتر',
                    style: Theme.of(context).textTheme.titleLarge?.merge(
                      TextStyle(color: context.colors.onPrimaryContainer, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: context.colors.onPrimaryContainer),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(child: filterOptions),
          ],
        ),
      ),
    );
  }
}
