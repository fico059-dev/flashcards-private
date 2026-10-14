import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/pack/packs_getter/packs_getter_bloc.dart';
import 'package:flashcards/bloc/pack/packs_getter/packs_getter_event.dart';
import 'package:flashcards/bloc/pack/packs_getter/packs_getter_state.dart';
import 'package:flashcards/domain/models/flashcards/pack/pack.dart';
import 'package:flashcards/domain/models/flashcards/pack/pack_tree.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/packs/pack_ui_card.dart';
import 'package:flashcards/ui/widgets/packs/pack_ui_shimmer.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../bloc/flashcards/flashcard/flashcard_event.dart';
import '../../../../config/router/router.dart';
import '../../../../utils/util_functions.dart';

@RoutePage()
class PacksPage extends StatelessWidget {
  const PacksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PacksView();
  }
}

class _PacksView extends StatefulWidget {
  const _PacksView({super.key});

  @override
  State<_PacksView> createState() => _PacksViewState();
}

class _PacksViewState extends State<_PacksView> with AutoRouteAware {
  AutoRouteObserver? _observer;
  bool _bootstrapped = false;

  void _bootstrap() {
    if (_bootstrapped) return;
    _bootstrapped = true;

    final bloc = context.read<PacksGetterBloc>();
    //bloc.add(PacksGetterClaimsFetched());
    bloc.add(PacksGetterCacheRead());
    bloc.fetchNextPage();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _observer = RouterScope.of(
      context,
    ).firstObserverOfType<AutoRouteObserver>();
    _observer?.subscribe(this, context.routeData);
  }

  @override
  void didChangeTabRoute(TabPageRoute previousRoute) {
    super.didChangeTabRoute(previousRoute);
    context.read<PacksGetterBloc>().add(PacksGetterCacheRead());
  }

  @override
  void dispose() {
    _observer?.unsubscribe(this);
    super.dispose();
  }

  Future<void> _handleRefresh(BuildContext context) {
    final completer = Completer<void>();
    context.read<PacksGetterBloc>().add(
      PacksGetterRefresh(completer: completer),
    );
    return completer.future.catchError((error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(extractErrorMessage(error))));
    });
  }

  /// Packs whose sub-packs are shown.
  final Set<String> _expanded = {};

  Future<void> _study(Pack pack) async {
    if (pack.isPaid == true) {
      final ok = await ensureCardsAccess(context);
      if (!ok || !mounted) return;
    }
    context.router.push(FlashcardRoute(testType: TestType.regular, pack: pack));
  }

  /// The tree as rows: (node, depth), skipping closed packs' sub-packs and
  /// packs with nothing to study.
  List<(PackNode, int)> _rows(List<PackNode> nodes, int depth) {
    final rows = <(PackNode, int)>[];
    for (final node in nodes) {
      final pack = node.combined;
      if (pack.dueCount == 0 && pack.newCount == 0) continue;
      rows.add((node, depth));
      if (_expanded.contains(node.pack.id)) {
        rows.addAll(_rows(node.children, depth + 1));
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 15),
        padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
        child: BlocBuilder<PacksGetterBloc, PacksGetterState>(
          builder: (context, state) {
            final paging = state.pagingState;
            // Every page is loaded, so sub-packs can be put inside their
            // pack.
            if (paging.hasNextPage &&
                !paging.isLoading &&
                paging.error == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) context.read<PacksGetterBloc>().fetchNextPage();
              });
            }

            final packs = [...?paging.items].cast<Pack>();
            if (packs.isEmpty) {
              if (paging.error != null) {
                return ErrorScreen(
                  errorMessage: _loadErrorMessage(paging.error),
                  onReload: context.read<PacksGetterBloc>().fetchNextPage,
                );
              }
              if (paging.isLoading || paging.hasNextPage) {
                return PackUiShimmer();
              }
            }

            final rows = _rows(buildPackTree(packs), 0);
            return RefreshIndicator(
              onRefresh: () => _handleRefresh(context),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: rows.length + (paging.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= rows.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final (node, depth) = rows[index];
                  final pack = node.combined;
                  final hasChildren = node.children.isNotEmpty;
                  final open = _expanded.contains(node.pack.id);

                  return Padding(
                    padding: EdgeInsets.only(left: depth * 20.0),
                    child: PackUiCard(
                      hasCards: state.hasCards,
                      pack: pack,
                      subtitle: hasChildren
                          ? "${node.children.length} sub-pack"
                                "${node.children.length == 1 ? '' : 's'}"
                                " · studies all of them"
                          : null,
                      leading: hasChildren
                          ? IconButton(
                              tooltip: open
                                  ? "Hide sub-packs"
                                  : "Show sub-packs",
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                open ? Icons.expand_more : Icons.chevron_right,
                              ),
                              onPressed: () => setState(() {
                                if (!_expanded.remove(node.pack.id)) {
                                  _expanded.add(node.pack.id);
                                }
                              }),
                            )
                          : null,
                      onTap: () => _study(pack),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

void _showLegendDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Icon Legend'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.layers),
            title: Text('Total Cards'),
            subtitle: Text("Total cards in the pack."),
          ),
          ListTile(
            leading: Icon(Icons.schedule, color: Colors.indigo),
            title: Text('Due today'),
            subtitle: Text("Cards that you are supposed to review today."),
          ),
          ListTile(
            leading: Icon(Icons.warning, color: Colors.indigo[900]),
            title: Text('Overdue'),
            subtitle: Text(
              "Cards that you were supposed to review in the past."
              " They will still get shown to you.",
            ),
            isThreeLine: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.router.pop(),
          child: Text('Got it'),
        ),
      ],
    ),
  );
}

String _loadErrorMessage(Object? error) => error == null
    ? "Error loading packs"
    : "Error loading packs\n${extractErrorMessage(error)}";
