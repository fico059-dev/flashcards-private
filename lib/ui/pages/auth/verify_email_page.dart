import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/authorization/email_verification/email_verification_bloc.dart';
import 'package:flashcards/bloc/authorization/email_verification/email_verification_event.dart';
import 'package:flashcards/data/repositories/users/auth_repository.dart';
import 'package:flashcards/ui/widgets/core/theme_toggle_button.dart';
import 'package:flashcards/ui/widgets/verify_email/verify_email_action_buttons.dart';
import 'package:flashcards/ui/widgets/verify_email/verify_email_headline.dart';
import 'package:flashcards/ui/widgets/verify_email/verify_email_icon.dart';
import 'package:flashcards/ui/widgets/verify_email/verify_email_info_section.dart';
import 'package:flashcards/ui/widgets/verify_email/verify_email_listener.dart';
import 'package:flashcards/ui/widgets/verify_email/verify_email_refresh_button.dart';
import 'package:flashcards/ui/widgets/verify_email/verify_email_resend_link_button.dart';
import 'package:flashcards/ui/widgets/verify_email/verify_email_sign_out_button.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          EmailVerificationBloc(authRepository: context.read<AuthRepository>()),
      child: _VerifyEmailView(),
    );
  }
}

class _VerifyEmailView extends StatefulWidget {
  const _VerifyEmailView({super.key});

  @override
  State<_VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<_VerifyEmailView> {
  @override
  void initState() {
    super.initState();
    context.read<EmailVerificationBloc>().add(
      SendEmailVerification(
        onSuccess: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.verifyEmailPage_success,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: [VerifyEmailRefreshButton(), ThemeToggleButton()],
      ),
      body: ReadableWidth(
        maxWidth: 480,
        child: VerifyEmailListener(
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(
                left: 25,
                right: 25,
                top: 10,
                bottom: 45,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      VerifyEmailIcon(),
                      SizedBox(height: 40),
                      VerifyEmailHeadline(),
                      SizedBox(height: 50),
                      VerifyEmailInfoSection(),
                      SizedBox(height: 80),
                      VerifyEmailActionButtons(),
                    ],
                  ),
                  VerifyEmailSignOutButton(),
                  VerifyEmailResendLinkButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
