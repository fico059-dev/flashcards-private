import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/pack/admin_packs_getter/admin_packs_getter_bloc.dart';
import 'package:flashcards/bloc/pack/admin_packs_getter/admin_packs_getter_event.dart';
import 'package:flashcards/bloc/pack/pack_searcher/pack_searcher_bloc.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_cubit.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/data/repositories/algolia_search/packs_searcher_repository.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/ui/pages/profile/admin_dashboard/admin_tab_routes.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/search/core_widgets/filter_drawer.dart';
import 'package:flashcards/ui/widgets/search/search_page/pack_search_page/pack_filter_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class AdminTabPage extends StatefulWidget implements AutoRouteWrapper {
  const AdminTabPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => AdminPacksGetterBloc(
                packRepo: context.read<PackRepository>(),
              ),
        ),

        // Search blocs
        BlocProvider(
          create:
              (context) => PackSearcherBloc(
                packSearcherRepo: context.read<PacksSearcherRepository>(),
              ),
        ),
      ],
      child: this,
    );
  }

  @override
  State<AdminTabPage> createState() => _AdminTabPageState();
}

class _AdminTabPageState extends State<AdminTabPage> with AutoRouteAware {
  TabsRouter? _tabsRouter;
  AutoRouteObserver? _observer;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
  void didPopNext() {
    super.didPopNext();
    if (_tabsRouter!.isRouteActive(FlashcardBuilderRoute.name)) {
      context.read<AdminPacksGetterBloc>().add(AdminPacksGetterCacheRead());
      return;
    }
  }

  @override
  void dispose() {
    _observer?.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.read<ProfileReaderCubit>().state;
    if (profileState is! ProfileReaderIsLoaded) {
      throw Exception("You didn't include ProfileLoadedGuard on this route");
    }
    final profile = profileState.profile;

    final l10n = AppLocalizations.of(context)!;

    void setActiveIndex(BuildContext drawerContext, int index) {
      drawerContext.router.pop();
      AutoTabsRouter.of(drawerContext).setActiveIndex(index);
    }

    return AutoTabsScaffold(
      scaffoldKey: _scaffoldKey,
      routes: AdminTabRoutes.routes,
      appBarBuilder: (appBarContext, tabsRouter) {
        _tabsRouter ??= tabsRouter;
        final title = AdminTabRoutes.getRouteTitle(appBarContext, tabsRouter);

        List<Widget>? appBarActions;
        switch (_tabsRouter?.activeIndex) {
          case 3:
          case 0:
            appBarActions = [
              Builder(
                builder: (ctx) {
                  return IconButton(
                    icon: const Icon(Icons.filter_alt),
                    onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                  );
                },
              ),
            ];
            break;
          default:
            appBarActions = [SizedBox.shrink()];
        }

        return AppBar(title: Text(title), actions: appBarActions);
      },
      endDrawer: Builder(
        builder: (ctx) {
          final tabsRouter = AutoTabsRouter.of(ctx);

          switch (tabsRouter.activeIndex) {
            case 0:
              return FilterDrawer(filterOptions: PackFilterOptions());
            default:
              return SizedBox.shrink(); // nema drawer-a
          }
        },
      ),
      drawer: Builder(
        builder: (drawerContext) {
          return Drawer(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: context.colors.primaryContainer),
                  currentAccountPicture: Icon(
                    CupertinoIcons.profile_circled,
                    color: context.colors.onPrimaryContainer,
                    size: 70,
                  ),
                  accountName: Text(
                    '${profile.name} ${profile.surname}',
                    style: TextStyle(color: context.colors.onPrimaryContainer),
                  ),
                  accountEmail: Text(
                    profile.email,
                    style: TextStyle(color: context.colors.onPrimaryContainer),
                  ),
                ),
                ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    _DrawerItem(
                      index: 0,
                      onTap: () => setActiveIndex(drawerContext, 0),
                      title: l10n.flashcardBuilderPage_title,
                      icon: Icons.style_outlined,
                      selectedIcon: Icons.style,
                    ),

                    _DrawerItem(
                      index: 1,
                      onTap: () => setActiveIndex(drawerContext, 1),
                      title: l10n.assignAdminPage_title,
                      icon: Icons.admin_panel_settings_outlined,
                      selectedIcon: Icons.admin_panel_settings,
                    ),
                    _DrawerItem(
                      index: 2,
                      onTap: () => setActiveIndex(drawerContext, 2),
                      title: "البطاقات المبلّغ عنها",
                      //l10n.assignAdminPage_title,
                      icon: Icons.report_outlined,
                      selectedIcon: Icons.report,
                    ),
                    Divider(height: 5),
                    _DrawerItem(
                      index: 3,
                      onTap: () {
                        context.router.pop();
                        context.router.replaceAll([MainTabRoute()]);
                      },
                      title: "الخروج من لوحة الإدارة",
                      icon: Icons.arrow_back,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final int index;
  final VoidCallback onTap;
  final String title;
  final IconData icon;
  final IconData? selectedIcon;

  const _DrawerItem({
    super.key,
    required this.onTap,
    required this.index,
    required this.title,
    required this.icon,
    this.selectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    final activeIndex = AutoTabsRouter.of(context).activeIndex;
    final isActive = activeIndex == index;
    return ListTile(
      tileColor: isActive ? context.colors.secondaryContainer.withValues(alpha: 0.6) : null,
      leading:
          isActive && selectedIcon != null
              ? Icon(selectedIcon, color: context.colors.primary)
              : Icon(icon, color: context.colors.primaryContainer),
      title: Text(title),
      onTap: onTap,
    );
  }
}
