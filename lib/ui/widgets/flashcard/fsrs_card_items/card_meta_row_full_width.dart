import 'package:flashcards/domain/models/flashcards/card_info_item/card_info_item.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class CardMetaRowFullWidth extends StatelessWidget {
  final CardInfoItem item;

  const CardMetaRowFullWidth({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 16.0, right: 2),
      leading: Icon(
        item.icon,
        color: context.colors.onSecondaryContainer,
        size: 20,
      ),
      title: Text(
        "${item.label}: ${item.value}",
        style: TextStyle(
          color: context.colors.onSecondaryContainer,
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
      ),
      trailing: Tooltip(
        message: item.tooltip,
        showDuration: Duration(seconds: 4),
        triggerMode: TooltipTriggerMode.tap,
        child: SizedBox(
          height: 40,
          width: 40,
          //padding: const EdgeInsets.all(0),
          child: Icon(
            Icons.info_outline,
            color: context.colors.onSecondaryContainer,
            size: 16,
          ),
        ),
      ),
    );
  }
}
