import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/authorization/auth/auth_bloc.dart';
import 'package:flashcards/bloc/authorization/auth/auth_event.dart';
import 'package:flashcards/bloc/authorization/auth/auth_state.dart';
import 'package:flashcards/bloc/authorization/update_email/update_email_during_verification_cubit.dart';
import 'package:flashcards/bloc/authorization/update_email/update_email_state.dart';
import 'package:flashcards/data/repositories/users/auth_repository.dart';
import 'package:flashcards/ui/theme/themes.dart';
import 'package:flashcards/ui/widgets/change_email/change_email_scaffold.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class ChangeEmailPage extends StatelessWidget {
  const ChangeEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpdateEmailDuringVerificationCubit(
        authRepository: context.read<AuthRepository>(),
        setSignOutReason: context.read<AuthBloc>().setSignOutReason,
        resetSignOutReason: context.read<AuthBloc>().resetSignOutReason,
      ),
      child: _ChangeEmailView(),
    );
  }
}

class _ChangeEmailView extends StatefulWidget {
  const _ChangeEmailView({super.key});

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

  Future<bool?> _showBackDialog() async {
    return await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.changeEmailPage_leaveWithoutVerifying,
          ),
          content: Text(AppLocalizations.of(context)!.changeEmailPage_text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.changeEmailPage_stay),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                AppLocalizations.of(context)!.changeEmailPage_leaveAnyway,
              ),
            ),
          ],
        );
      },
    );
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
                  "Successfully sent new email verification at $email",
                ),
              ),
            );
            context.read<AuthBloc>().add(
              UpdatePendingEmailVerification(pendingEmailVerification: true),
            );
            break;
          case UpdateEmailSuccess():
            context.read<AuthBloc>().add(
              UpdatePendingEmailVerification(pendingEmailVerification: false),
            );
            break;
          case UpdateEmailRequiresReauth():
            break;
          default:
            break;
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;

              // if not authenticated, just pop
              if (state is! Authenticated) {
                context.router.pop();
                return;
              }

              // if email is already verified, just pop
              if (state case Authenticated(:final pendingEmailVerification)) {
                if (!pendingEmailVerification) {
                  context.router.pop();
                  return;
                }
              }

              await context
                  .read<UpdateEmailDuringVerificationCubit>()
                  .reloadUser(state.user.email!);
              final bool shouldPop = await _showBackDialog() ?? false;
              if (context.mounted && shouldPop) {
                context.router.pop();
              }
            },
            child: ChangeEmailScaffold(
              isVerifyEmailPage: false,
              updateEmailCubit: context
                  .read<UpdateEmailDuringVerificationCubit>(),
              emailController: _emailController,
              additionalContent: _ChangeEmailAdditionalContent(
                updateEmailCubit: context
                    .read<UpdateEmailDuringVerificationCubit>(),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

class _ChangeEmailAdditionalContent extends StatelessWidget {
  final UpdateEmailDuringVerificationCubit updateEmailCubit;

  const _ChangeEmailAdditionalContent({
    super.key,
    required this.updateEmailCubit,
  });

  @override
  Widget build(BuildContext context) {
    void onRefresh() {
      var authState = context.read<AuthBloc>().state;
      if (authState case Authenticated(:final user)) {
        updateEmailCubit.reloadUser(user.email!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Looks like you are not authenticated, try logging out and then log in again",
            ),
          ),
        );
      }
    }

    return BlocBuilder<UpdateEmailDuringVerificationCubit, UpdateEmailState>(
      builder: (context, state) {
        return Center(
          child: SizedBox(
            width: 180,
            child: FilledButton(
              style: tonalButtonStyle(context),
              onPressed:
                  state is UpdateEmailLoading || state is UpdateEmailRefreshing
                  ? null
                  : onRefresh,
              child: state is! UpdateEmailRefreshing
                  ? Text("I've verified my email")
                  : SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.indigo,
                        strokeWidth: 3,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
