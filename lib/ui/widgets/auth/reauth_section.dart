import 'package:flashcards/bloc/authorization/reauth/reauth_cubit.dart';
import 'package:flashcards/bloc/authorization/reauth/reauth_state.dart';
import 'package:flashcards/data/repositories/users/auth_repository.dart';
import 'package:flashcards/ui/widgets/core/bloc_text_field.dart';
import 'package:flashcards/ui/widgets/core/card_factory.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

class ReauthSection<B extends StateStreamable<S>, S> extends StatelessWidget {
  final bool Function(S state) isReauthState;
  final VoidCallback onRetryOriginalAction;

  const ReauthSection({
    super.key,
    required this.isReauthState,
    required this.onRetryOriginalAction,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ReauthCubit(authRepository: context.read<AuthRepository>()),
      child: _ReauthSectionView<B, S>(
        isReauthState: isReauthState,
        onRetryOriginalAction: onRetryOriginalAction,
      ),
    );
  }
}

class _ReauthSectionView<B extends StateStreamable<S>, S>
    extends StatefulWidget {
  final bool Function(S state) isReauthState;
  final VoidCallback onRetryOriginalAction;

  const _ReauthSectionView({
    super.key,
    required this.isReauthState,
    required this.onRetryOriginalAction,
  });

  @override
  State<_ReauthSectionView> createState() => _ReauthSectionViewState<B, S>();
}

class _ReauthSectionViewState<B extends StateStreamable<S>, S>
    extends State<_ReauthSectionView<B, S>> {
  late final TextEditingController _passController;

  @override
  void initState() {
    super.initState();
    _passController = TextEditingController();
  }

  void _onReauthenticate() {
    context.read<ReauthCubit>().reauthenticate(_passController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReauthCubit, ReauthState>(
      listener: (context, state) {
        switch (state) {
          case ReauthError(:final error):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  mapFirebaseError(error: error, context: context).message,
                ),
              ),
            );
            break;
          case ReauthSuccess():
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.reauthSection_success,
                ),
              ),
            );
            widget.onRetryOriginalAction.call();
            break;
          default:
            break;
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<B, S>(
            builder: (context, state) {
              if (widget.isReauthState(state)) {
                final auth = context.read<AuthRepository>();
                final social = auth.hasPassword ? null : auth.socialProviderId;
                if (social != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CardFactory.warning(
                        subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!.reauthSection_securityNotice,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: BlocBuilder<ReauthCubit, ReauthState>(
                          builder: (context, reauthState) => FilledButton.icon(
                            onPressed: reauthState is ReauthLoading
                                ? null
                                : () => context
                                      .read<ReauthCubit>()
                                      .reauthenticateWithProvider(),
                            icon: Icon(
                              social == 'apple.com'
                                  ? Icons.apple
                                  : Icons.account_circle,
                            ),
                            label: Text(
                              social == 'apple.com'
                                  ? 'Confirm with Apple'
                                  : 'Confirm with Google',
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //SizedBox(height: 20),
                    CardFactory.warning(
                      subtitle: Text(
                        AppLocalizations.of(
                          context,
                        )!.reauthSection_securityNotice,
                      ),
                    ),
                    SizedBox(height: 20),
                    BlocTextField<ReauthCubit, ReauthState>(
                      errorSelector: (state) => state is ReauthFormInvalid
                          ? state.errors["password"]
                          : null,
                      labelText: AppLocalizations.of(
                        context,
                      )!.basicText_password,
                      textEditingController: _passController,
                      obscureText: true,
                    ),
                    SizedBox(height: 15),

                    Center(
                      child: BlocBuilder<ReauthCubit, ReauthState>(
                        builder: (context, state) {
                          bool isLoading = state is ReauthLoading;
                          return SizedBox(
                            height: 45,
                            width: 150,
                            child: FilledButton(
                              onPressed: !isLoading ? _onReauthenticate : null,
                              child: !isLoading
                                  ? Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.reauthSection_button,
                                    )
                                  : SizedBox(
                                      width: 23,
                                      height: 23,
                                      child: CircularProgressIndicator(
                                        color: Colors.indigo,
                                        strokeWidth: 3,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else {
                return CardFactory.info(
                  title: Text(AppLocalizations.of(context)!.reauthSection_info),
                  isBigTitle: false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passController.dispose();
    super.dispose();
  }
}
