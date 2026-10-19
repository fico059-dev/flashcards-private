import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/authorization/login/login_cubit.dart';
import 'package:flashcards/bloc/authorization/login/login_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/data/repositories/users/auth_repository.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/auth/auth_screen_container.dart';
import 'package:flashcards/ui/widgets/auth/auth_listener.dart';
import 'package:flashcards/ui/widgets/core/bloc_animated_icon.dart';
import 'package:flashcards/ui/widgets/core/bloc_text_field.dart';
import 'package:flashcards/ui/widgets/core/bloc_buttons/bloc_button.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LoginCubit(authRepository: context.read<AuthRepository>()),
      child: _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({super.key});

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  void _onSignIn() {
    var loginCubit = context.read<LoginCubit>();
    loginCubit.validateForm(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (loginCubit.state case LoginFormValid()) {
      loginCubit.login(_emailController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthListener(
      child: AuthScreenContainer(
        authIcon: BlocAnimatedIcon<LoginCubit, LoginState>(
          icon: Icons.lock,
          isErrorState: (state) =>
              state is LoginError || state is LoginFormInvalid,
          isSuccessState: (state) => state is LoginSuccess,
        ),
        messageContainer: _MessageContainer(),
        message: Text(
          AppLocalizations.of(context)!.loginPage_welcomeBack,
          style: TextStyle(color: context.colors.onSurfaceVariant),
        ),
        inputs: [
          BlocTextField<LoginCubit, LoginState>(
            textEditingController: _emailController,
            labelText: AppLocalizations.of(context)!.basicText_email,
            errorSelector: (state) =>
                state is LoginFormInvalid ? state.errors["email"] : null,
          ),
          BlocTextField<LoginCubit, LoginState>(
            errorSelector: (state) =>
                state is LoginFormInvalid ? state.errors["password"] : null,
            labelText: AppLocalizations.of(context)!.basicText_password,
            textEditingController: _passwordController,
            obscureText: true,
          ),
        ],
        otherContent: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => context.router.push(ForgotPasswordRoute()),
                child: Text(
                  AppLocalizations.of(context)!.basicText_forgotPassword,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: context.colors.onSurfaceVariant),
                ),
              ),
            ],
          ),

          SizedBox(height: 25),
          BlocButton<LoginCubit, LoginState>(
            textString: AppLocalizations.of(context)!.basicText_signInNow,
            onPressed: (context) => _onSignIn(),
            isLoadingState: (state) => state is LoginLoading,
            isDisabledState: (state) => state is LoginSuccess,
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Text(
                AppLocalizations.of(context)!.basicText_notAMember,
                style: TextStyle(color: context.colors.onSurfaceVariant),
              ),
              TextButton(
                onPressed: () {
                  context.router.replace(RegisterRoute());
                },
                child: Text(
                  AppLocalizations.of(context)!.basicText_register,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _MessageContainer extends StatelessWidget {
  const _MessageContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        String? message;
        bool isError = false;
        switch (state) {
          case LoginError(:final error):
            // switch (errorMessage) {
            //   case "For security reasons, please reauthenticate to perform this action.":
            //     message =
            //         AppLocalizations.of(context)!.error_requiresRecentLogin;
            //     break;
            //   case "صيغة البريد الإلكتروني غير صحيحة.":
            //     message = AppLocalizations.of(context)!.error_invalidEmail;
            //     break;
            //   case "User with that email is disabled.":
            //     message = AppLocalizations.of(context)!.error_userDisabled;
            //     break;
            //   case "No account found with that email.":
            //     message = AppLocalizations.of(context)!.error_userNotFound;
            //     break;
            //   case "Incorrect password. Try again.":
            //     message = AppLocalizations.of(context)!.error_wrongPassword;
            //     break;
            //   case "You've send too many requests, try again later":
            //     message = AppLocalizations.of(context)!.error_tooManyRequests;
            //     break;
            //   case "Session expired, please log in again.":
            //     message = AppLocalizations.of(context)!.error_tokenExpired;
            //     break;
            //   case "There is a problem with the network, please check your internet connection":
            //     message = AppLocalizations.of(context)!.error_networkIssue;
            //     break;
            //   case "Invalid credentials, please try again":
            //     message = AppLocalizations.of(context)!.error_invalidCredential;
            //     break;
            //   case "There is a problem with firebase auth, please contact the developer":
            //     message =
            //         AppLocalizations.of(context)!.error_operationNotAllowed;
            //     break;
            //   case "That email is already in use, try another one.":
            //     message = AppLocalizations.of(context)!.error_emailAlreadyInUse;
            //     break;
            //   case "Authentication failed. Please try again.":
            //     message = AppLocalizations.of(context)!.error_authFailed;
            //     break;
            //   case "An unexpected error occurred. Please try again.":
            //     message = AppLocalizations.of(context)!.error_unexpected;
            //     break;
            //   case "Password does not meet security requirements.":
            //     message =
            //         AppLocalizations.of(context)!.error_passwordRequirement;
            //     break;
            //   default:
            //     message = AppLocalizations.of(context)!.error_unexpected;
            // }

            message = mapFirebaseError(error: error, context: context).message;
            isError = true;
            break;
          case LoginSuccess(:final displayName):
            message = AppLocalizations.of(
              context,
            )!.loginPage_welcomeBackMember(displayName);
            break;
          default:
            message = null;
        }
        if (message == null) return SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            textAlign: TextAlign.center,
            message,
            style: TextStyle(
              color: isError
                  ? context.colors.error
                  : context.customColors.success,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
