import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/authorization/register/register_cubit.dart';
import 'package:flashcards/bloc/authorization/register/register_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/data/repositories/users/auth_repository.dart';
import 'package:flashcards/domain/models/profile/profile.dart';
import 'package:flashcards/domain/models/profile/profile_settings/profile_settings.dart';
import 'package:flashcards/domain/models/profile/streak/streak.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/auth/auth_listener.dart';
import 'package:flashcards/ui/widgets/auth/auth_screen_container.dart';
import 'package:flashcards/ui/widgets/core/bloc_animated_icon.dart';
import 'package:flashcards/ui/widgets/core/bloc_buttons/bloc_button.dart';
import 'package:flashcards/ui/widgets/core/bloc_text_field.dart';
import 'package:flashcards/domain/models/profile/education_level.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/ui/widgets/auth/social_sign_in_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RegisterCubit(authRepository: context.read<AuthRepository>()),
      child: _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView({super.key});

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _repeatPasswordController;
  late final TextEditingController _phoneController;

  // used for displaying localized name of the enum value in dropdown
  late final TextEditingController _educationLevelController;
  late EducationLevel educationLevel = EducationLevel.intern;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _repeatPasswordController = TextEditingController();
    _phoneController = TextEditingController();
    _educationLevelController = TextEditingController(
      //text: educationLevel.toLocalizedString(context),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _educationLevelController ??= TextEditingController(
    //   text: educationLevel.toLocalizedString(context),
    // );
  }

  void _onRegister() {
    var email = _emailController.text.trim();
    var password = _passwordController.text;
    var repeatPassword = _repeatPasswordController.text;
    var profile = Profile(
      streak: Streak(count: 1, lastStreakDate: DateTime.now()),
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      username:
          "${_nameController.text.trim()} ${_surnameController.text.trim()}",
      email: email,
      phoneNumber: _phoneController.text.trim(),
      educationLevel: educationLevel,
      profileSettings: ProfileSettings(),
    );

    context.read<RegisterCubit>().validateForm(
      email,
      password,
      repeatPassword,
      profile,
    );

    context.read<RegisterCubit>().register(email, password, profile);
  }

  @override
  Widget build(BuildContext context) {
    final lightGrayStyle = TextStyle(
      fontWeight: FontWeight.w300,
      color: context.colors.onSurfaceVariant,
    );

    _educationLevelController.text = educationLevel.toLocalizedString(context);

    return AuthListener(
      child: AuthScreenContainer(
        authIcon: BlocAnimatedIcon<RegisterCubit, RegisterState>(
          icon: Icons.person_add,
          isSuccessState: (state) => state is RegisterSuccess,
          isErrorState: (state) =>
              state is RegisterError || state is RegisterFormInvalid,
        ),
        messageContainer: _MessageContainer(),
        message: Text(
          AppLocalizations.of(context)!.registerPage_header,
          style: lightGrayStyle,
        ),
        inputs: [
          Row(
            spacing: 15,
            children: [
              Expanded(
                child: BlocTextField<RegisterCubit, RegisterState>(
                  labelText: AppLocalizations.of(context)!.basicText_name,
                  textEditingController: _nameController,
                  errorSelector: (state) => state is RegisterFormInvalid
                      ? state.errors["name"]
                      : null,
                ),
              ),
              Expanded(
                child: BlocTextField<RegisterCubit, RegisterState>(
                  labelText: AppLocalizations.of(context)!.basicText_surname,
                  textEditingController: _surnameController,
                  errorSelector: (state) => state is RegisterFormInvalid
                      ? state.errors["surname"]
                      : null,
                ),
              ),
            ],
          ),
          BlocTextField<RegisterCubit, RegisterState>(
            labelText: AppLocalizations.of(context)!.basicText_email,
            textEditingController: _emailController,
            errorSelector: (state) =>
                state is RegisterFormInvalid ? state.errors["email"] : null,
          ),
          BlocTextField<RegisterCubit, RegisterState>(
            labelText: AppLocalizations.of(context)!.basicText_phoneNumber,
            textEditingController: _phoneController,
            errorSelector: (state) => state is RegisterFormInvalid
                ? state.errors["phoneNumber"]
                : null,
          ),
          DropdownMenu<EducationLevel>(
            controller: _educationLevelController,
            width: double.infinity,
            inputDecorationTheme: Theme.of(context).inputDecorationTheme,
            initialSelection: educationLevel,
            label: Text(AppLocalizations.of(context)!.basicText_educationLevel),
            onSelected: (EducationLevel? newValue) => setState(() {
              if (newValue == null) return;
              _educationLevelController!.text = newValue.toLocalizedString(
                context,
              );
              educationLevel = newValue;
            }),
            dropdownMenuEntries: EducationLevel.values.map((level) {
              return DropdownMenuEntry<EducationLevel>(
                value: level,
                label: level.toLocalizedString(context),
              );
            }).toList(),
          ),
          BlocTextField<RegisterCubit, RegisterState>(
            labelText: AppLocalizations.of(context)!.basicText_password,
            obscureText: true,
            textEditingController: _passwordController,
            errorSelector: (state) =>
                state is RegisterFormInvalid ? state.errors["password"] : null,
          ),
          Text(
            "Password must be at least 8 characters long and include uppercase,"
            " lowercase, and special characters.",
            style: TextTheme.of(
              context,
            ).labelMedium?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          BlocTextField<RegisterCubit, RegisterState>(
            labelText: AppLocalizations.of(context)!.basicText_repeatPassword,
            obscureText: true,
            textEditingController: _repeatPasswordController,
            errorSelector: (state) => state is RegisterFormInvalid
                ? state.errors["repeatPassword"]
                : null,
          ),
        ],
        otherContent: [
          SizedBox(height: 30),
          BlocButton<RegisterCubit, RegisterState>(
            textString: AppLocalizations.of(context)!.basicText_register,
            onPressed: (context) => _onRegister(),
            isLoadingState: (state) => state is RegisterLoading,
            isDisabledState: (state) => state is RegisterSuccess,
          ),
          SizedBox(height: 16),
          const SocialSignInButtons(),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Text(
                AppLocalizations.of(context)!.basicText_alreadyAMember,
                style: lightGrayStyle,
              ),
              TextButton(
                onPressed: () {
                  context.router.replace(LoginRoute());
                },
                child: Text(
                  AppLocalizations.of(context)!.basicText_signInNow,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
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
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _phoneController.dispose();
    _educationLevelController!.dispose();
    super.dispose();
  }
}

class _MessageContainer extends StatelessWidget {
  const _MessageContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) =>
          current is RegisterSuccess || current is RegisterError,
      listener: (context, state) {
        switch (state) {
          case RegisterSuccess(:final displayName):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("✅ Congrats $displayName, you're registered!"),
              ),
            );
            break;
          case RegisterError(:final error):
            final message = mapFirebaseError(
              error: error,
              context: context,
            ).message;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
            break;
          case RegisterInitial():
          case RegisterLoading():
          case RegisterFormInvalid():
          case RegisterFormValid():
            break;
        }
      },
      child: BlocBuilder<RegisterCubit, RegisterState>(
        builder: (context, state) {
          String? message;
          bool isError = false;
          switch (state) {
            case RegisterError(:final error):
              isError = true;
              message = mapFirebaseError(
                error: error,
                context: context,
              ).message;
              break;
            case RegisterSuccess(:final displayName):
              message = AppLocalizations.of(
                context,
              )!.registerPage_successfulRegister(displayName);
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
      ),
    );
  }
}
