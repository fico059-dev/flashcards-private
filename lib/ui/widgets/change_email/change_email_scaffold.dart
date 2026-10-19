import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/authorization/update_email/update_email_during_verification_cubit.dart';
import 'package:flashcards/bloc/authorization/update_email/update_email_state.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/auth/reauth_section.dart';
import 'package:flashcards/ui/widgets/change_email/change_email_button.dart';
import 'package:flashcards/ui/widgets/core/bloc_text_field.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';

class ChangeEmailScaffold extends StatelessWidget {
  final TextEditingController emailController;
  final UpdateEmailDuringVerificationCubit updateEmailCubit;
  final Widget? additionalContent;
  final bool isVerifyEmailPage;

  const ChangeEmailScaffold({
    super.key,
    required this.updateEmailCubit,
    required this.emailController,
    required this.isVerifyEmailPage,
    this.additionalContent,
  });

  @override
  Widget build(BuildContext context) {
    void onUpdateEmail() {
      updateEmailCubit.verifyBeforeUpdateEmail(
        emailController.text,
        isVerifyEmailPage,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Update Email"),
        leading: IconButton(
          onPressed: () => context.router.maybePop(),
          icon: Icon(Icons.close),
        ),
        actions: [ChangeEmailButton(onUpdate: onUpdateEmail)],
      ),
      body: ReadableWidth(
        maxWidth: 480,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalScreenPadding,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 7),
                Text(
                  "A verification link will be sent to your new email address. Once you verify it, your email will be updated automatically.",
                ),
                SizedBox(height: 40),
                BlocTextField<
                  UpdateEmailDuringVerificationCubit,
                  UpdateEmailState
                >(
                  isEnabledState: (state) =>
                      state is! UpdateEmailRequiresReauth,
                  errorSelector: (state) => state is UpdateEmailFormInvalid
                      ? state.errors["email"]
                      : null,
                  labelText: "New Email",
                  textEditingController: emailController,
                ),
                SizedBox(height: 20),
                additionalContent ?? SizedBox.shrink(),
                if (additionalContent != null) SizedBox(height: 20),
                ReauthSection<
                  UpdateEmailDuringVerificationCubit,
                  UpdateEmailState
                >(
                  isReauthState: (state) => state is UpdateEmailRequiresReauth,
                  onRetryOriginalAction: onUpdateEmail,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
