import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/authorization/update_password/update_password_cubit.dart';
import 'package:flashcards/bloc/authorization/update_password/update_password_state.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_cubit.dart';
import 'package:flashcards/data/repositories/users/auth_repository.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/auth/reauth_section.dart';
import 'package:flashcards/ui/widgets/core/bloc_text_field.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class UpdatePasswordPage extends StatelessWidget {
  const UpdatePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UpdatePasswordCubit(authRepo: context.read<AuthRepository>()),
      child: _UpdatePasswordView(),
    );
  }
}

class _UpdatePasswordView extends StatefulWidget {
  const _UpdatePasswordView({super.key});

  @override
  State<_UpdatePasswordView> createState() => _UpdatePasswordViewState();
}

class _UpdatePasswordViewState extends State<_UpdatePasswordView> {
  late final TextEditingController _passCont;
  late final TextEditingController _repeatPassCont;

  @override
  void initState() {
    super.initState();
    _passCont = TextEditingController();
    _repeatPassCont = TextEditingController();
  }

  @override
  void dispose() {
    _passCont.dispose();
    _repeatPassCont.dispose();
    super.dispose();
  }

  void _onUpdate() {
    context.read<UpdatePasswordCubit>().updatePassword(
      _passCont.text,
      _repeatPassCont.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.updatePasswordPage_title),
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          BlocBuilder<UpdatePasswordCubit, UpdatePasswordState>(
            builder: (context, state) => TextButton(
              onPressed:
                  state is UpdatePasswordLoading ||
                      state is UpdatePasswordRequiresReauth
                  ? null
                  : _onUpdate,
              child: state is! UpdatePasswordLoading
                  ? Text(
                      AppLocalizations.of(context)!.updatePasswordPage_update,
                    )
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
        ],
      ),
      body: BlocListener<UpdatePasswordCubit, UpdatePasswordState>(
        listenWhen: (previous, current) =>
            current is UpdatePasswordSuccessful ||
            current is UpdatePasswordError,
        listener: (context, state) {
          switch (state) {
            case UpdatePasswordSuccessful():
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.updatePasswordPage_success,
                  ),
                ),
              );
              context.read<ProfileReaderCubit>().readProfile();
              context.router.pop();
              break;
            case UpdatePasswordError(:final error):
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
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 30),
            padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
            child: Column(
              spacing: 20,
              children: [
                BlocTextField<UpdatePasswordCubit, UpdatePasswordState>(
                  labelText: AppLocalizations.of(
                    context,
                  )!.updatePasswordPage_password,
                  errorSelector: (state) => state is UpdatePasswordFormInvalid
                      ? state.errors['password']
                      : null,
                  textEditingController: _passCont,
                  obscureText: true,
                ),
                BlocTextField<UpdatePasswordCubit, UpdatePasswordState>(
                  labelText: AppLocalizations.of(
                    context,
                  )!.updatePasswordPage_repeatPassword,
                  errorSelector: (state) => state is UpdatePasswordFormInvalid
                      ? state.errors['repeat-password']
                      : null,
                  textEditingController: _repeatPassCont,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ReauthSection<UpdatePasswordCubit, UpdatePasswordState>(
                  isReauthState: (state) =>
                      state is UpdatePasswordRequiresReauth,
                  onRetryOriginalAction: _onUpdate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
