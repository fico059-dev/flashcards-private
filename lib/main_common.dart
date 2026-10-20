import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flashcards/bloc/theme/theme_cubit.dart';
import 'package:flashcards/config/orientation_helper.dart';
import 'package:flashcards/ui/widgets/core/theme_toggle_button.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show Intl;
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

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

import 'config/firebase_config_resolver.dart';

enum AppFlavor { dev, prod }

class Flavor {
  static AppFlavor current = AppFlavor.dev;

  static bool get isDev => current == AppFlavor.dev;

  static bool get isProd => current == AppFlavor.prod;
}

Future<void> bootstrap({required bool isDev}) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await _bootstrap(isDev: isDev);
  } catch (error, stack) {
    // بدل صفحة بيضاء: نعرض سبب الفشل ليسهل إصلاحه.
    debugPrint('Bootstrap failed: $error\n$stack');
    runApp(_StartupErrorApp(error: error));
  }
}

Future<void> _bootstrap({required bool isDev}) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: await resolveFirebaseOptions());
  }

  // تشغيل التطبيق على Firebase Emulators (للتطوير):
  //   flutter run --dart-define=USE_EMULATOR=true
  //   (على محاكي أندرويد استخدم --dart-define=EMULATOR_HOST=10.0.2.2)
  if (const bool.fromEnvironment('USE_EMULATOR')) {
    const host = String.fromEnvironment('EMULATOR_HOST', defaultValue: 'localhost');
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
    await FirebaseStorage.instance.useStorageEmulator(host, 9199);
  }

  // تاريخ ووقت بالعربية
  Intl.defaultLocale = 'ar';
  await initializeDateFormatting('ar');
  timeago.setLocaleMessages('ar', timeago.ArMessages());

  // app orientation
  //await setAppOrientation();

  // time zone
  tz.initializeTimeZones();
  try {
    final TimezoneInfo currentTimeZone =
        await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));
  } catch (error) {
    // بعض المتصفحات ترجع منطقة زمنية غير معروفة؛ نستخدم توقيت الرياض.
    debugPrint('Timezone fallback: $error');
    tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
  }

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

class _StartupErrorApp extends StatelessWidget {
  final Object error;

  const _StartupErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'تعذّر تشغيل تقدر',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SelectableText('$error', textAlign: TextAlign.center),
                ],
              ),
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
              title: 'تقدر',
              routerConfig: _appRouter.config(
                navigatorObservers: () => [AutoRouteObserver()],
              ),
              theme: lightThemeData,
              darkTheme: darkThemeData,
              themeMode: themeMode,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('ar'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,

              builder: (context, child) {
                return Stack(
                  children: [
                    child!,
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
