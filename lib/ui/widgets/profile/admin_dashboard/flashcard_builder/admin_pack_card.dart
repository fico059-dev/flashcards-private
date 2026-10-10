import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/pack_options_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class AdminPackCard extends StatelessWidget {
  final AdminPack pack;

  const AdminPackCard({super.key, required this.pack});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        onTap: () => showPackOptionsBottomSheet(context, pack),
        tileColor: Colors.indigo[50],
        leading: badges.Badge(
          badgeStyle: badges.BadgeStyle(badgeColor: Colors.indigo),
          badgeContent: Text(
            pack.flashcardsCount.toString(),
            style: TextStyle(fontSize: 11, color: Colors.indigo[50]),
          ),
          child: Icon(Icons.folder),
        ),
        title: Text(pack.packName),
        subtitle: pack.parentId == null ? null : const Text("Sub-pack"),
        trailing: pack.restricted
            ? const Tooltip(
                message: "Only chosen users",
                child: Icon(Icons.lock_person),
              )
            : null,
      ),
    );
  }
}
