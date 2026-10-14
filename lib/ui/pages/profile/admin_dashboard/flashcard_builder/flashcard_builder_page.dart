import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/pack/admin_packs_getter/admin_packs_getter_bloc.dart';
import 'package:flashcards/bloc/pack/admin_packs_getter/admin_packs_getter_event.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/create_pack_dialog.dart';
import 'package:flashcards/ui/widgets/core/card_factory.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/flashcard_builder/admin_pack_card.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

@RoutePage()
class FlashcardBuilderPage extends StatelessWidget {
  const FlashcardBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _View();
  }
}

class _View extends StatefulWidget {
  const _View({super.key});

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> with AutoRouteAware {
  AutoRouteObserver? _observer;

  void _readFromCache() {
    context.read<AdminPacksGetterBloc>().add(AdminPacksGetterCacheRead());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _observer = RouterScope.of(
      context,
    ).firstObserverOfType<AutoRouteObserver>();
    if (_observer != null) {
      _observer!.subscribe(this, context.routeData);
    }
  }

  @override
  void dispose() {
    _observer?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeTabRoute(TabPageRoute previousRoute) {
    super.didChangeTabRoute(previousRoute);
    _readFromCache();
  }

  Future<void> _handleRefresh(BuildContext context) {
    final completer = Completer<void>();
    context.read<AdminPacksGetterBloc>().add(
      AdminPacksGetterRefresh(completer: completer),
    );

    return completer.future.catchError((error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(extractErrorMessage(error))));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreatePackDialog(context),
        child: Icon(Icons.add, color: Colors.indigo[50]),
      ),
      body: ReadableWidth(
        maxWidth: 820,
        child: Container(
          margin: EdgeInsets.only(top: 20),
          padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
          child: BlocBuilder<AdminPacksGetterBloc, PagingState<int, AdminPack>>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () => _handleRefresh(context),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        spacing: 15,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Select the pack you want to edit."),
                          CardFactory.info(
                            isThreeLine: true,
                            title: Text("Features of this page"),
                            subtitle: Text(
                              "You can create new packs, insert flashcards into pack,"
                              " manage flashcards inside a pack, meaning you can update and"
                              " delete flashcards inside a pack,",
                            ),
                          ),
                          SizedBox(),
                        ],
                      ),
                    ),

                    PagedSliverList(
                      state: state,
                      fetchNextPage: () =>
                          context.read<AdminPacksGetterBloc>().fetchNextPage(),
                      builderDelegate: PagedChildBuilderDelegate(
                        firstPageErrorIndicatorBuilder: (context) =>
                            ErrorScreen(
                              errorMessage: extractErrorMessage(state.error!),
                              onReload: () => context
                                  .read<AdminPacksGetterBloc>()
                                  .fetchNextPage(),
                            ),
                        itemBuilder: (context, item, index) {
                          final pack = item as AdminPack;
                          return AdminPackCard(pack: pack);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PacksView extends StatelessWidget {
  final List<AdminPack> packs;

  const _PacksView({super.key, required this.packs});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select the pack you want to edit."),
          CardFactory.info(
            isThreeLine: true,
            title: Text("Features of this page"),
            subtitle: Text(
              "You can create new packs, insert flashcards into pack,"
              " manage flashcards inside a pack, meaning you can update and"
              " delete flashcards inside a pack,",
            ),
          ),
          SizedBox(),
          ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: packs.length,
            itemBuilder: (context, index) {
              final pack = packs[index];

              return AdminPackCard(pack: pack);
            },
          ),
        ],
      ),
    );
  }
}
