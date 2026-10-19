import 'package:auto_route/annotations.dart';
import 'package:flashcards/bloc/pack/pack_searcher/pack_searcher_bloc.dart';
import 'package:flashcards/bloc/pack/pack_searcher/pack_searcher_event.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/dialogs/packs/single_pack_admin_bottom_sheet.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/create_pack_dialog.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/search/search_page/pack_search_page/pack_search_bar.dart';
import 'package:flashcards/ui/widgets/search/search_page/pack_search_page/pack_search_results.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class AdminPackSearchPage extends StatefulWidget {
  const AdminPackSearchPage({super.key});

  @override
  State<AdminPackSearchPage> createState() => _AdminPackSearchPageState();
}

class _AdminPackSearchPageState extends State<AdminPackSearchPage> {
  late final TextEditingController _controller = TextEditingController();

  void _openDialogAndReact() async {
    final pack = await showCreatePackDialog(context);
    if (pack != null) {
      if (!context.mounted) return;

      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) return;
      context.read<PackSearcherBloc>().add(PackSearcherRequestSent(query: ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: "Create new pack",
        onPressed: _openDialogAndReact,
        child: Icon(Icons.add, color: context.colors.onPrimary),
      ),
      body: ReadableWidth(
        maxWidth: 820,
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalScreenPadding,
            right: horizontalScreenPadding,
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: PackSearchBar(cont: _controller)),

              SliverToBoxAdapter(child: SizedBox(height: 15)),

              PackSearchResults(
                onTap: (packId, _) =>
                    showSinglePackAdminBottomSheet(context, packId),
                showDefaultPremiumIcon: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
