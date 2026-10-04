import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/osces/admin_osce_getter/admin_osce_getter_bloc.dart';
import 'package:flashcards/bloc/osces/admin_osce_getter/admin_osce_getter_event.dart';
import 'package:flashcards/bloc/osces/admin_osce_getter/admin_osce_getter_state.dart';
import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/osce/create_osce_bottom_sheet.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/osce_builder/admin_osce_card.dart';
import 'package:flashcards/ui/widgets/search/shimmers/pack_shimmer.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/osce_builder/osce_library_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

@RoutePage()
class OsceBuilderPage extends StatelessWidget {
  const OsceBuilderPage({super.key});

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
    context.read<AdminOsceGetterBloc>().add(AdminOsceGetterCacheRead());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _observer =
        RouterScope.of(context).firstObserverOfType<AutoRouteObserver>();
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
    context.read<AdminOsceGetterBloc>().add(
      AdminOsceGetterRefresh(completer: completer),
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
        tooltip: "Create new OSCE",
        onPressed: () => showCreateOsceDialog(context),
        child: Icon(Icons.add, color: context.colors.onPrimary),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
        child: BlocBuilder<AdminOsceGetterBloc, AdminOsceGetterState>(
          builder:
              (context, state) => RefreshIndicator(
                onRefresh: () => _handleRefresh(context),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        spacing: 15,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final bloc = context
                                    .read<AdminOsceGetterBloc>();
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const OsceFoldersAdminPage(),
                                  ),
                                );
                                bloc.add(
                                  AdminOsceGetterRefresh(completer: null),
                                );
                              },
                              icon: const Icon(Icons.folder_copy_outlined),
                              label: const Text("Manage folders"),
                            ),
                          ),
                          Text("Select what OSCE do you want to edit."),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),

                    PagedSliverList(
                      state: state.pagingState,
                      fetchNextPage:
                          context.read<AdminOsceGetterBloc>().fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate(
                        firstPageProgressIndicatorBuilder:
                            (context) => PackShimmer(),
                        firstPageErrorIndicatorBuilder:
                            (context) => ErrorScreen(
                              errorMessage: extractErrorMessage(state.pagingState.error!),
                              onReload:
                                  context
                                      .read<AdminOsceGetterBloc>()
                                      .fetchNextPage,
                            ),
                        itemBuilder: (context, item, index) {
                          final simpleOsce = item as SimpleOsce;
                          return AdminOsceCard(osce: simpleOsce);
                        },
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
