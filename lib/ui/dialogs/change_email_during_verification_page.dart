import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/authorization/auth/auth_bloc.dart';
import 'package:flashcards/bloc/authorization/email_verification/email_verification_bloc.dart';
import 'package:flashcards/bloc/authorization/email_verification/email_verification_event.dart';
import 'package:flashcards/bloc/authorization/update_email/update_email_during_verification_cubit.dart';
import 'package:flashcards/bloc/authorization/update_email/update_email_state.dart';
import 'package:flashcards/data/repositories/users/auth_repository.dart';
import 'package:flashcards/ui/widgets/change_email/change_email_scaffold.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class ChangeEmailDuringVerificationPage extends StatelessWidget {
  final EmailVerificationBloc emailVerificationBloc;

  const ChangeEmailDuringVerificationPage({
    super.key,
    required this.emailVerificationBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpdateEmailDuringVerificationCubit(
        authRepository: context.read<AuthRepository>(),
        setSignOutReason: context.read<AuthBloc>().setSignOutReason,
        resetSignOutReason: context.read<AuthBloc>().resetSignOutReason,
      ),
      child: _ChangeEmailView(emailVerificationBloc: emailVerificationBloc),
    );
  }
}

class _ChangeEmailView extends StatefulWidget {
  final EmailVerificationBloc emailVerificationBloc;

  const _ChangeEmailView({super.key, required this.emailVerificationBloc});

  @override
  State<_ChangeEmailView> createState() => _ChangeEmailViewState();
}

class _ChangeEmailViewState extends State<_ChangeEmailView> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateEmailDuringVerificationCubit, UpdateEmailState>(
      listener: (context, state) {
        switch (state) {
          case UpdateEmailError(:final error):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  mapFirebaseError(error: error, context: context).message,
                ),
              ),
            );
            break;
          case UpdateEmailSent(:final email):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  )!.changeEmailDuringVerificationPage_text(email),
                ),
              ),
            );
            widget.emailVerificationBloc.add(
              EmailVerificationEmailUpdated(email: email),
            );
            context.router.pop();
            break;
          case UpdateEmailRequiresReauth():
            break;
          default:
            break;
        }
      },
      child: ChangeEmailScaffold(
        updateEmailCubit: context.read<UpdateEmailDuringVerificationCubit>(),
        emailController: _emailController,
        isVerifyEmailPage: true,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
