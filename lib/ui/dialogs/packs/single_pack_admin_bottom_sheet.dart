import 'package:auto_route/auto_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashcards/bloc/pack/delete_pack/delete_pack_cubit.dart';
import 'package:flashcards/bloc/pack/pack_searcher/pack_searcher_bloc.dart';
import 'package:flashcards/bloc/pack/pack_searcher/pack_searcher_event.dart';
import 'package:flashcards/bloc/pack/single_pack_getter/single_pack_simple/single_pack_simple_getter_cubit.dart';
import 'package:flashcards/bloc/pack/single_pack_getter/single_pack_simple/single_pack_simple_getter_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/domain/models/flashcards/simple_pack/simple_pack.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/delete_pack_dialog.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/export_pack.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/pack_access_page.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/pack_premium_dialog.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/rename_pack_dialog.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/subs_status_icon.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showSinglePackAdminBottomSheet(BuildContext context, String packId) {
  final packSearcherBloc = context.read<PackSearcherBloc>();
  debugPrint(
    '[ADMIN] open packId=$packId, project=${Firebase.app().options.projectId}',
  );

  showModalBottomSheet(
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: bottomSheetShape,
    context: context,
    builder: scrollableSheet(
      (context) =>
          _SinglePackWidget(packId: packId, searcherBloc: packSearcherBloc),
    ),
  );
}

class _SinglePackWidget extends StatelessWidget {
  final String packId;
  final PackSearcherBloc searcherBloc;

  const _SinglePackWidget({
    super.key,
    required this.packId,
    required this.searcherBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SinglePackSimpleGetterCubit(packRepo: context.read<PackRepository>()),
      child: _View(packId: packId, searcherBloc: searcherBloc),
    );
  }
}

class _View extends StatefulWidget {
  final String packId;
  final PackSearcherBloc searcherBloc;

  const _View({super.key, required this.packId, required this.searcherBloc});

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  @override
  void initState() {
    super.initState();
    context.read<SinglePackSimpleGetterCubit>().getPack(widget.packId);
  }

  void navigateTo(PageRouteInfo route) {
    context.router.pop();
    context.router.push(route);
  }

  void _onEditName(SimplePack pack) async {
    context.router.pop();

    final newName = await showRenamePackDialog(context, pack, null);
    if (newName != null) {
      widget.searcherBloc.add(
        PackSearcherPackUpdatedInState(
          packId: pack.packId,
          copyWith: (pack) => pack.copyWith(name: newName),
        ),
      );
    }
  }

  void _onChangePremium(SimplePack pack) async {
    context.router.pop();
    final isPaid = await showChangePackPremiumDialog(context, pack);
    if (isPaid != null) {
      widget.searcherBloc.add(
        PackSearcherPackUpdatedInState(
          packId: pack.packId,
          copyWith: (pack) => pack.copyWith(isPaid: isPaid),
        ),
      );
    }
  }

  // The menu reloads the pack when opened, so nothing else to update.
  void _onChangeAccess(SimplePack pack) async {
    context.router.pop();
    await showPackAccessPage(context, pack);
  }

  void _onDelete(SimplePack pack) async {
    context.router.pop();
    final cubit = DeletePackCubit(packRepo: context.read<PackRepository>());
    final success = await showDeletePackDialog(context, pack, cubit, null);
    cubit.close();

    if (success == true) {
      widget.searcherBloc.add(
        PackSearcherPackRemovedFromState(packId: pack.packId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //final getterBloc = context.read<AdminPacksGetterBloc>();

    return Padding(
      padding: bottomSheetPadding,
      child: Wrap(
        children: [
          BlocBuilder<SinglePackSimpleGetterCubit, SinglePackSimpleGetterState>(
            builder: (context, state) {
              switch (state) {
                case SinglePackSimpleGetterInitial():
                case SinglePackSimpleGetterLoading():
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  );
                case SinglePackSimpleGetterError(:final error):
                  return Center(
                    child: Text(
                      "Error loading pack: ${extractErrorMessage(error)}",
                    ),
                  );
                case SinglePackSimpleGetterLoaded(:final pack):
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.folder),
                        title: Text(pack.packName),
                        subtitle: Text("Flashcards: ${pack.flashcardsCount}"),
                        trailing: SubsStatusIcon(
                          isPaid: pack.isPaid,
                          hasAccess: false,
                          size: 20,
                        ),
                      ),

                      Divider(),

                      ListTile(
                        onTap: () =>
                            navigateTo(CreateFlashcardRoute(pack: pack)),
                        leading: Icon(
                          Icons.add_circle_outline,
                          color: context.colors.primaryContainer,
                        ),
                        title: Text("Add Flashcards"),
                      ),
                      ListTile(
                        onTap: () => navigateTo(AnkiImportRoute(pack: pack)),
                        leading: Icon(
                          Icons.upload_file,
                          color: context.colors.primaryContainer,
                        ),
                        title: Text("Import from Anki"),
                        subtitle: Text(
                          "Add a whole .apkg or .txt deck at once",
                        ),
                      ),
                      ListTile(
                        onTap: () =>
                            navigateTo(ManagePackFlashcardsRoute(pack: pack)),
                        leading: Icon(
                          Icons.edit_note,
                          color: context.colors.primaryContainer,
                        ),
                        title: Text("Edit/Delete Flashcards"),
                      ),
                      ListTile(
                        onTap: () => _onEditName(pack),
                        leading: Icon(
                          Icons.drive_file_rename_outline,
                          color: context.colors.primaryContainer,
                        ),
                        title: Text("Rename Pack"),
                      ),
                      PackPremiumTile(
                        isPaid: pack.isPaid,
                        onTap: () => _onChangePremium(pack),
                      ),
                      PackAccessTile(
                        restricted: pack.restricted,
                        onTap: () => _onChangeAccess(pack),
                      ),
                      ExportPackTile(pack: pack),
                      ListTile(
                        onTap: () => _onDelete(pack),
                        leading: Icon(
                          Icons.delete_forever,
                          color: context.colors.error,
                        ),
                        title: Text("Delete Pack"),
                        subtitle: Text(
                          "Deletes the pack and all its flashcards",
                        ),
                        subtitleTextStyle: TextStyle(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
              }
            },
          ),
        ],
      ),
    );
  }
}
