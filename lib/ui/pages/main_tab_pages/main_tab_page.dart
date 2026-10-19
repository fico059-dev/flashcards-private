import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/custom_session/custom_session_getter/custom_session_getter_bloc.dart';
import 'package:flashcards/bloc/custom_session/custom_session_getter/custom_session_getter_event.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/data/repositories/flashcards/custom_session_repository.dart';
import 'package:flashcards/ui/pages/main_tab_pages/main_tab_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class MainTabPage extends StatefulWidget implements AutoRouteWrapper {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CustomSessionGetterBloc(
            sessionRepo: context.read<CustomSessionRepository>(),
          ),
        ),
      ],
      child: this,
    );
  }
}

class _MainTabPageState extends State<MainTabPage> with AutoRouteAware {
  TabsRouter? _tabsRouter;
  AutoRouteObserver? _observer;
  List<Widget> appBarActions = [];

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
  void didPopNext() {
    super.didPopNext();

    if (_tabsRouter!.isRouteActive(PreviousSessionsRoute.name)) {
      context.read<CustomSessionGetterBloc>().add(
        CustomSessionGetterStateReset(),
      );
    }

    _assignAppBarActions();
  }

  void _assignAppBarActions() {
    final router = _tabsRouter!;
    if (router.isRouteActive(VerbalPacksRoute.name) ||
        router.isRouteActive(QuantPacksRoute.name)) {
      appBarActions = [
        IconButton(
          onPressed: () => context.router.push(const PackSearchRoute()),
          icon: const Icon(Icons.search),
        ),
      ];
    } else if (router.isRouteActive(PreviousSessionsRoute.name) ||
        router.isRouteActive(CustomSessionResultRoute.name)) {
      appBarActions = [
        IconButton(
          onPressed: () => context.router.push(CustomSessionWrapperRoute()),
          icon: const Icon(CupertinoIcons.add),
        ),
      ];
    } else {
      appBarActions = [];
    }
  }

  @override
  void dispose() {
    _observer?.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      appBarBuilder: (context, tabsRouter) {
        _tabsRouter ??= tabsRouter;

        final title = MainTabRoutes.getRouteTitle(context, tabsRouter);
        _assignAppBarActions();

        return AppBar(
          title: Text(title),
          leading: IconButton(
            icon: Icon(CupertinoIcons.profile_circled),
            onPressed: () {
              context.router.push(ProfileRoute());
            },
          ),
          actions: appBarActions,
        );
      },
      routes: MainTabRoutes.mainTabPages,
      bottomNavigationBuilder: (context, tabsRouter) {
        _tabsRouter ??= AutoTabsRouter.of(context);

        return NavigationBar(
          onDestinationSelected: tabsRouter.setActiveIndex,
          selectedIndex: tabsRouter.activeIndex,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: "الرئيسية",
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.menu_book),
              icon: Icon(Icons.menu_book_outlined),
              label: "لفظي",
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.calculate),
              icon: Icon(Icons.calculate_outlined),
              label: "كمي",
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.tune),
              icon: Icon(Icons.tune_outlined),
              label: "جلساتي",
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.insights),
              icon: Icon(Icons.insights_outlined),
              label: "تقدّمي",
            ),
          ],
        );
      },
    );
  }
}
