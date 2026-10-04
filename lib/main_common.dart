import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashcards/bloc/theme/theme_cubit.dart';
import 'package:flashcards/config/orientation_helper.dart';
import 'package:flashcards/ui/widgets/core/theme_toggle_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

Future<void> bootstrap({required bool isDev}) {
  // The app prints many debug messages. In a browser each one is written to
  // the console, which slows the website down, so the published website
  // skips them.
  if (kIsWeb && kReleaseMode) {
    return runZoned(
      () => _bootstrap(isDev: isDev),
      zoneSpecification: ZoneSpecification(print: (_, _, _, _) {}),
    );
  }
  return _bootstrap(isDev: isDev);
}

Future<void> _bootstrap({required bool isDev}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // On the website the browser's own menu replaces the app's selection
  // menu, which hides "Highlight" (and on iPhone Safari it doesn't appear at
  // all). Use the app's menu, like in the iPhone app.
  if (kIsWeb) {
    try {
      await BrowserContextMenu.disableContextMenu();
    } catch (_) {
      // Not supported by this browser: keep its own menu.
    }
  }

  try {
    await _initialize(isDev);
  } catch (error, stack) {
    // Without this a failed start leaves an empty page (e.g. on the website
    // when its Firebase settings are missing), with no hint why.
    debugPrint('Startup failed while $_startupStep: $error\n$stack');
    runApp(_StartupErrorApp(error: error, step: _startupStep, stack: stack));
  }
}

/// What the app was setting up, shown if starting fails.
String _startupStep = 'starting';

Future<void> _initialize(bool isDev) async {
  _startupStep = 'connecting to Firebase';
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
    // On the web nothing has started Firebase yet, and asking for
    // Firebase.apps before it's loaded crashes in Safari ("Null check
    // operator used on a null value").
    if (kIsWeb || Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: opts);
    }
  }

  // app orientation
  //await setAppOrientation();

  // time zone
  _startupStep = 'time zone';
  tz.initializeTimeZones();
  try {
    final TimezoneInfo currentTimeZone =
        await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));
  } catch (error) {
    // Some browsers report a name the time zone database doesn't know.
    debugPrint('Unknown time zone, using UTC: $error');
    tz.setLocalLocation(tz.UTC);
  }

  // dependency injection
  final dep = AppDependencies(isDev: isDev);
  await dep.initialize(onStep: (step) => _startupStep = step);
  _startupStep = 'app services';
  final providers = dep.getProviders();
  _startupStep = 'first screen';

  runApp(
    MultiProvider(
      providers: providers,
      child: _MyApp(dependencies: dep),
    ),
  );
}

class _StartupErrorApp extends StatelessWidget {
  final Object error;
  final String step;
  final StackTrace stack;

  const _StartupErrorApp({
    required this.error,
    required this.step,
    required this.stack,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  "FlashPedz couldn't start",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please try again later.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SelectableText(
                  'Step: $step\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                // Technical details, for whoever fixes it.
                SelectableText(
                  stack.toString().split('\n').take(8).join('\n'),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
                    _WebFrame(child: child!),
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

/// On the website, very wide screens show the app in a centred frame
/// instead of stretching it edge to edge. Below that it uses the full
/// width: phones get the phone layout, computers the desktop layout.
class _WebFrame extends StatelessWidget {
  static const _maxWidth = 1280.0;

  final Widget child;

  const _WebFrame({required this.child});

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
