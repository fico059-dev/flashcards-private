import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/authorization/forgot_password/forgot_password_cubit.dart';
import 'package:flashcards/bloc/authorization/forgot_password/forgot_password_state.dart';
import 'package:flashcards/data/repositories/users/auth_repository.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/bloc_text_field.dart';
import 'package:flashcards/ui/widgets/core/theme_toggle_button.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ForgotPasswordCubit(authRepository: context.read<AuthRepository>()),
      child: _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView({super.key});

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        switch (state) {
          case ForgotPasswordSuccessful():
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.forgotPasswordPage_emailSent,
                ),
              ),
            );
            context.router.pop();
            break;
          case ForgotPasswordError(:final error):
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
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              context.router.pop();
            },
          ),
          actions: [ThemeToggleButton()],
        ),
        body: ReadableWidth(
          maxWidth: 480,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Icon(
                        CupertinoIcons.lock_rotation,
                        size: 100,
                        color: context.colors.primary,
                      ),
                      SizedBox(height: 40),
                      Text(
                        AppLocalizations.of(context)!.basicText_forgotPassword,
                        style: TextTheme.of(context).headlineMedium,
                      ),
                      SizedBox(height: 50),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.forgotPasswordPage_enterEmail,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 20),
                      BlocTextField<ForgotPasswordCubit, ForgotPasswordState>(
                        labelText: AppLocalizations.of(
                          context,
                        )!.basicText_email,
                        textEditingController: _emailController,
                        errorSelector: (state) =>
                            state is ForgotPasswordFormInvalid
                            ? state.errors["email"]
                            : null,
                      ),
                      SizedBox(height: 40),
                      BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                        builder: (context, state) {
                          final isLoading = state is ForgotPasswordLoading;

                          return FilledButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    final email = _emailController.text.trim();
                                    var cubit = context
                                        .read<ForgotPasswordCubit>();
                                    cubit.validateForm(email);
                                    context
                                        .read<ForgotPasswordCubit>()
                                        .sendResetEmail(email);
                                  },
                            child: isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.colors.primary,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.basicText_sendEmail,
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
