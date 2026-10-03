import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Asks the admin to confirm, then switches [pack] between free and premium.
/// Returns the new premium value, or null if cancelled or it failed.
Future<bool?> showChangePackPremiumDialog(
  BuildContext context,
  AdminPack pack,
) async {
  final packRepo = context.read<PackRepository>();
  final messenger = ScaffoldMessenger.of(context);
  final makePaid = !pack.isPaid;

  final changed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      var isSaving = false;
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          Future<void> onConfirm() async {
            setState(() => isSaving = true);
            final result = await packRepo.setPackPremium(pack.packId, makePaid);
            if (!dialogContext.mounted) return;
            switch (result) {
              case Ok<void>():
                Navigator.of(dialogContext).pop(true);
              case Error<void>(:final error):
                setState(() => isSaving = false);
                messenger.showSnackBar(
                  SnackBar(content: Text(extractErrorMessage(error))),
                );
            }
          }

          return AlertDialog(
            title: Text(makePaid ? "Make pack Premium?" : "Make pack Free?"),
            content: Text(
              makePaid
                  ? "\"${pack.packName}\" will only be available to "
                        "subscribers. Users without a subscription will no "
                        "longer be able to study its cards."
                  : "\"${pack.packName}\" will be free for everyone, "
                        "including users without a subscription.",
            ),
            actions: [
              TextButton(
                onPressed: isSaving
                    ? null
                    : () => Navigator.of(dialogContext).pop(false),
                child: const Text("Cancel"),
              ),
              FilledButton(
                onPressed: isSaving ? null : onConfirm,
                child: isSaving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: dialogContext.colors.onPrimary,
                        ),
                      )
                    : Text(makePaid ? "Make Premium" : "Make Free"),
              ),
            ],
          );
        },
      );
    },
  );

  if (changed != true) return null;
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        makePaid
            ? "\"${pack.packName}\" is now Premium"
            : "\"${pack.packName}\" is now Free",
      ),
    ),
  );
  return makePaid;
}

/// Menu row showing whether a pack is premium, with a switch to change it.
class PackPremiumTile extends StatelessWidget {
  final bool isPaid;
  final VoidCallback onTap;

  const PackPremiumTile({super.key, required this.isPaid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        isPaid ? Icons.lock : Icons.lock_open,
        color: context.colors.primaryContainer,
      ),
      title: const Text("Premium"),
      subtitle: Text(
        isPaid ? "Only subscribers can study this pack" : "Free for everyone",
      ),
      trailing: Switch(value: isPaid, onChanged: (_) => onTap()),
    );
  }
}
