import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/authorization/auth/auth_bloc.dart';
import 'package:flashcards/bloc/authorization/auth/auth_event.dart';
import 'package:flashcards/bloc/authorization/auth/auth_state.dart';
import 'package:flashcards/bloc/authorization/email_verification/email_verification_bloc.dart';
import 'package:flashcards/bloc/authorization/email_verification/email_verification_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmailListener extends StatelessWidget {
  final Widget child;

  const VerifyEmailListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<EmailVerificationBloc, EmailVerificationState>(
          listener: (context, state) {
            if (!context.mounted) return;
            switch (state) {
              case EmailVerificationError(:final error):
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      mapFirebaseError(error: error, context: context).message,
                    ),
                  ),
                );
                break;
              default:
                break;
            }
          },
        ),

        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            switch (state) {
              case AuthInitial():
                context.router.replace(LoginRoute());
                break;
              case Authenticated():
                //print("e ovde de je redirectujem");
                context.read<AuthBloc>().add(AuthSignOut());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "✅ تم توثيق البريد! سجّل الدخول من جديد.",
                    ),
                  ),
                );
                //context.router.replaceAll([HomeRoute()]);
                break;
              case Unauthenticated():
                context.router.replace(LoginRoute());
                break;
              default:
                break;
            }
          },
        ),
      ],
      child: child,
    );
  }
}
