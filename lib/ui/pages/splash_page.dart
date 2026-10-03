import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/authorization/auth/auth_event.dart';
import 'package:flashcards/bloc/authorization/auth/auth_bloc.dart';
import 'package:flashcards/bloc/authorization/auth/auth_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  /// After this long without leaving the splash screen, the user gets the
  /// option to retry or sign out instead of waiting forever.
  static const _slowStartTimeout = Duration(seconds: 20);

  bool _hasRedirected = false;
  bool _isSlow = false;
  Timer? _slowTimer;

  void _redirectUser(BuildContext context, AuthState authState) {
    if (_hasRedirected) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // print("Trying to redirect with state: $authState");
      final router = context.router;
      switch (authState) {
        case Authenticated():
          router.replaceAll([HomeRoute()]);
          _hasRedirected = true;
          break;
        case AuthVerifyEmailPending():
          router.replaceAll([VerifyEmailRoute()]);
          _hasRedirected = true;
          break;
        case AuthInitial():
          break;
        case AuthLoading():
          break;
        default:
          router.replaceAll([LoginRoute()]);
          _hasRedirected = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _redirectUser(context, context.read<AuthBloc>().state);
    _startSlowTimer();
  }

  void _startSlowTimer() {
    _slowTimer?.cancel();
    _slowTimer = Timer(_slowStartTimeout, () {
      if (mounted) setState(() => _isSlow = true);
    });
  }

  void _retry() {
    setState(() => _isSlow = false);
    _startSlowTimer();
    context.read<AuthBloc>().add(AuthRetry());
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is Authenticated && current is Authenticated) {
          return previous.pendingEmailVerification !=
                  current.pendingEmailVerification ||
              previous.user.uid !=
                  current.user.uid; // or check more specific fields
        }
        return previous != current;
      },
      listener: (context, state) {
        _redirectUser(context, state);
      },
      child: Scaffold(
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final error = switch (state) {
              AuthInitial(:final error) => error,
              AuthLoading(:final error) => error,
              _ => null,
            };
            if (error != null || _isSlow) {
              return _StartupProblem(
                error: error,
                onRetry: _retry,
                onSignOut: () => context.read<AuthBloc>().add(AuthSignOut()),
              );
            }
            return Center(
              child: Column(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: Colors.indigo,
                      strokeWidth: 5,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.splashPageText,
                    style: TextTheme.of(context).headlineSmall,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Shown when startup failed or is taking too long, so the user isn't stuck
/// on the loading screen.
class _StartupProblem extends StatelessWidget {
  final Exception? error;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  const _StartupProblem({
    required this.error,
    required this.onRetry,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                error == null ? Icons.hourglass_bottom : Icons.cloud_off,
                size: 56,
                color: Colors.indigo,
              ),
              Text(
                error == null
                    ? "This is taking longer than usual"
                    : "We couldn't load your account",
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              Text(
                error == null
                    ? "Check your internet connection and try again."
                    : extractErrorMessage(error!),
                textAlign: TextAlign.center,
              ),
              if (error != null)
                SelectableText(
                  error.runtimeType.toString(),
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              FilledButton(onPressed: onRetry, child: const Text("Try again")),
              TextButton(onPressed: onSignOut, child: const Text("Sign out")),
            ],
          ),
        ),
      ),
    );
  }
}
