import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/pack/packs_getter/packs_getter_bloc.dart';
import 'package:flashcards/bloc/pack/packs_getter/packs_getter_event.dart';
import 'package:flashcards/bloc/pack/packs_getter/packs_getter_state.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/domain/enums/pack_section.dart';
import 'package:flashcards/domain/models/flashcards/pack/pack.dart';
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
class VerbalPacksPage extends StatelessWidget {
  const VerbalPacksPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const _SectionPacks(section: PackSection.verbal);
}

@RoutePage()
class QuantPacksPage extends StatelessWidget {
  const QuantPacksPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const _SectionPacks(section: PackSection.quant);
}

class _SectionPacks extends StatelessWidget {
  final PackSection section;

  const _SectionPacks({required this.section});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PacksGetterBloc(
        packRepository: context.read<PackRepository>(),
        section: section,
      ),
      child: const _PacksView(),
    );
  }
}

class _PacksView extends StatefulWidget {
  const _PacksView();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 15),
        padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
        child: BlocBuilder<PacksGetterBloc, PacksGetterState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => _handleRefresh(context),
              child: PagedListView(
                physics: const AlwaysScrollableScrollPhysics(),
                state: state.pagingState,
                fetchNextPage: context.read<PacksGetterBloc>().fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate(
                  invisibleItemsThreshold: 3,
                  firstPageProgressIndicatorBuilder: (context) =>
                      PackUiShimmer(),
                  firstPageErrorIndicatorBuilder: (context) => ErrorScreen(
                    errorMessage: "تعذّر تحميل الحزم",
                    onReload: context.read<PacksGetterBloc>().fetchNextPage,
                  ),
                  noItemsFoundIndicatorBuilder: (context) =>
                      const Center(child: Text("لا توجد حزم في هذا القسم بعد")),
                  itemBuilder: (context, item, index) {
                    final pack = item as Pack;

                    if (pack.dueCount == 0 && pack.newCount == 0) {
                      return SizedBox.shrink();
                    }

                    Future<void> openPack() async {
                      context.router.push(
                        FlashcardRoute(testType: TestType.regular, pack: pack),
                      );
                    }

                    return PackUiCard(
                      hasCards: state.hasCards,
                      pack: pack,
                      onTap: () async {
                        if (pack.isPaid == true) {
                          final ok = await ensureCardsAccess(context);
                          if (!ok) return;
                        }
                        await openPack();
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
