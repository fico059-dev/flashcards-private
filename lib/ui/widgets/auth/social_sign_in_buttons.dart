import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcards/data/repositories/users/auth_repository.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Sign in with Apple is offered in the iPhone and Mac apps.
bool get appleSignInAvailable =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS);

/// What to tell the student when signing in with Google or Apple fails, or
/// null when they just closed the window.
String? socialSignInErrorMessage(Object error, BuildContext context) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
      case 'web-context-canceled':
      case 'web-context-cancelled':
      case 'canceled':
      case 'cancelled':
      case 'user-cancelled':
        return null;
      case 'account-exists-with-different-credential':
        return 'This email already has a FlashPedz account. Sign in with '
            'your email and password instead.';
      case 'popup-blocked':
        return 'The browser blocked the sign-in window. Allow pop-ups for '
            'this site and try again.';
      case 'operation-not-allowed':
        return 'This sign-in option is not turned on yet.';
    }
  }
  if (error.toString().toLowerCase().contains('cancel')) return null;
  return mapFirebaseError(error: error, context: context).message;
}

/// "Continue with Google" (and with Apple on iPhone). After signing in, the
/// app opens like after a normal sign-in; new accounts get a profile made
/// from their Google or Apple name.
class SocialSignInButtons extends StatefulWidget {
  const SocialSignInButtons({super.key});

  @override
  State<SocialSignInButtons> createState() => _SocialSignInButtonsState();
}

class _SocialSignInButtonsState extends State<SocialSignInButtons> {
  String? _busy;

  Future<void> _signIn(String providerId) async {
    setState(() => _busy = providerId);
    final result = await context.read<AuthRepository>().signInWithProvider(
      providerId,
    );
    if (!mounted) return;
    setState(() => _busy = null);
    if (result case Error(:final error)) {
      final message = socialSignInErrorMessage(error, context);
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    Widget button({
      required String providerId,
      required Widget icon,
      required String label,
    }) => SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _busy == null ? () => _signIn(providerId) : null,
        icon: _busy == providerId
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : icon,
        label: Text(label),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('or', style: TextStyle(color: muted)),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 12),
        button(
          providerId: 'google.com',
          icon: const _GoogleLogo(),
          label: 'Continue with Google',
        ),
        if (appleSignInAvailable) ...[
          const SizedBox(height: 10),
          button(
            providerId: 'apple.com',
            icon: const Icon(Icons.apple, size: 22),
            label: 'Continue with Apple',
          ),
        ],
      ],
    );
  }
}

/// A simple four-colour "G".
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const SweepGradient(
        colors: [
          Color(0xFF4285F4),
          Color(0xFF34A853),
          Color(0xFFFBBC05),
          Color(0xFFEA4335),
          Color(0xFF4285F4),
        ],
      ).createShader(bounds),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
