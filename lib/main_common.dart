import 'package:auto_route/auto_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashcards/bloc/theme/theme_cubit.dart';
import 'package:flashcards/config/orientation_helper.dart';
import 'package:flashcards/ui/widgets/core/theme_toggle_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:flashcards/bloc/authorization/auth/auth_bloc.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_cubit.dart';
import 'package:flashcards/config/app_dependencies.dart';
import 'package:flashcards/config/app_keys.dart';
import 'package:flashcards/config/router/guards/admin_guard.dart';
import 'package:flashcards/config/router/guards/auth_guard.dart';
import 'package:flashcards/config/router/guards/guest_guard.dart';
import 'package:flashcards/config/router/guards/profile_loaded_guard.dart';
import 'package:flashcards/config/router/guards/verify_email_guard.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/l10n/app_localizations.dart';
import 'package:flashcards/ui/theme/themes.dart';
import 'package:flashcards/ui/widgets/auth/auth_profile_synchronization_wrapper.dart';
import 'package:flashcards/ui/widgets/core/loading_overlay_with_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import 'config/firebase_options_dev.dart' as dev;
import 'config/firebase_options_prod.dart' as prod;

enum AppFlavor { dev, prod }

class Flavor {
  static AppFlavor current = AppFlavor.dev;

  static bool get isDev => current == AppFlavor.dev;

  static bool get isProd => current == AppFlavor.prod;
}

Future<void> bootstrap({required bool isDev}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // ANDROID: google-services.json po flavoru rešava sve -> nije potrebno options.
  // iOS/web/desktop: koristimo options.
  if (!kIsWeb && Platform.isAndroid) {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } else {
    final opts = isDev
        ? dev.DefaultFirebaseOptions.currentPlatform
        : prod.DefaultFirebaseOptions.currentPlatform;
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: opts);
    }
  }

  // app orientation
  //await setAppOrientation();

  // time zone
  tz.initializeTimeZones();
  final TimezoneInfo currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));

  // dependency injection
  final dep = AppDependencies(isDev: isDev);
  await dep.initialize();
  final providers = dep.getProviders();

  runApp(
    MultiProvider(
      providers: providers,
      child: _MyApp(dependencies: dep),
    ),
  );
}

class _MyApp extends StatefulWidget {
  final AppDependencies dependencies;

  const _MyApp({super.key, required this.dependencies});

  @override
  State<_MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> {
  late final AppRouter _appRouter;
  bool _orientationSet = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_orientationSet) {
      _orientationSet = true;
      setAppOrientation(context);
    }
  }

  @override
  void initState() {
    super.initState();
    final authGuard = AuthGuard(authBloc: context.read<AuthBloc>());
    final guestGuard = GuestGuard(authBloc: context.read<AuthBloc>());
    final verifyEmailGuard = VerifyEmailGuard(
      authBloc: context.read<AuthBloc>(),
    );
    final profileLoadedGuard = ProfileLoadedGuard(
      profileReaderCubit: context.read<ProfileReaderCubit>(),
    );
    final adminGuard = AdminGuard(
      profileReaderCubit: context.read<ProfileReaderCubit>(),
    );

    _appRouter = AppRouter(
      authGuard: authGuard,
      guestGuard: guestGuard,
      verifyEmailGuard: verifyEmailGuard,
      profileLoadedGuard: profileLoadedGuard,
      adminGuard: adminGuard,
    );
  }

  @override
  void dispose() {
    widget.dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      overlayWidgetBuilder: (_) =>
          const Center(child: LoadingOverlayWithText()),
      overlayColor: Colors.black.withAlpha(120),
      child: AuthProfileSynchronizationWrapper(
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              scaffoldMessengerKey: rootScaffoldMessengerKey,
              debugShowCheckedModeBanner: false,
              title: 'FlashPedz',
              routerConfig: _appRouter.config(
                navigatorObservers: () => [AutoRouteObserver()],
              ),
              theme: lightThemeData,
              darkTheme: darkThemeData,
              themeMode: themeMode,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,

              builder: (context, child) {
                return Stack(
                  children: [
                    _PhoneWidthOnWeb(child: child!),
                    if (kDebugMode)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: ThemeToggleButton.asFab(),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// The app is designed for phones. On the website, wide screens show it in a
/// centred, phone-width column instead of stretching it edge to edge.
class _PhoneWidthOnWeb extends StatelessWidget {
  static const _maxWidth = 600.0;

  final Widget child;

  const _PhoneWidthOnWeb({required this.child});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    final media = MediaQuery.of(context);
    if (media.size.width <= _maxWidth) return child;

    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: ClipRect(
          child: SizedBox(
            width: _maxWidth,
            child: MediaQuery(
              data: media.copyWith(size: Size(_maxWidth, media.size.height)),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
