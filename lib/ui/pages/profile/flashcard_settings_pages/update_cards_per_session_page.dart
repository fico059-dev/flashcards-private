import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_cubit.dart';
import 'package:flashcards/bloc/profile/update_profile_settings/update_profile_settings_cubit.dart';
import 'package:flashcards/bloc/profile/update_profile_settings/update_profile_settings_state.dart';
import 'package:flashcards/data/repositories/users/profile_repository.dart';
import 'package:flashcards/domain/models/profile/profile.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/core/bloc_text_field.dart';
import 'package:flashcards/ui/widgets/profile/profile_reader_bloc_builder.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class UpdateCardsPerSessionPage extends StatelessWidget {
  const UpdateCardsPerSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileReaderBlocBuilder(
      onLoadedContent: (profile) => Scaffold(
        appBar: AppBar(
          title: Text("Cards per session"),
          leading: IconButton(
            onPressed: () => context.router.pop(),
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: ReadableWidth(
          maxWidth: 820,
          child: _ProfileSettingsView(profile: profile),
        ),
      ),
    );
  }
}

class _ProfileSettingsView extends StatefulWidget {
  final Profile profile;

  const _ProfileSettingsView({super.key, required this.profile});

  @override
  State<_ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<_ProfileSettingsView> {
  late final TextEditingController _cardsPerSessionCont;

  @override
  void initState() {
    super.initState();
    _cardsPerSessionCont = TextEditingController(
      text: widget.profile.profileSettings.cardsPerSession.toString(),
    );
  }

  @override
  void dispose() {
    _cardsPerSessionCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpdateProfileSettingsCubit(
        profileRepo: context.read<ProfileRepository>(),
      ),
      child: Builder(
        builder: (context) {
          return BlocListener<
            UpdateProfileSettingsCubit,
            UpdateProfileSettingsState
          >(
            listenWhen: (previous, current) =>
                (current is UpdateProfileSettingsDisabled ||
                    current is UpdateProfileSettingsSuccessful ||
                    current is UpdateProfileSettingsError) &&
                current != previous,
            listener: (context, state) {
              switch (state) {
                case UpdateProfileSettingsDisabled():
                  _cardsPerSessionCont.text = widget
                      .profile
                      .profileSettings
                      .cardsPerSession
                      .toString();
                  break;
                case UpdateProfileSettingsSuccessful():
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Successfully updated settings")),
                  );
                  context.read<ProfileReaderCubit>().readProfile();
                  break;
                case UpdateProfileSettingsError(:final message):
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                  break;
                default:
                  break;
              }
            },
            child: Container(
              padding: EdgeInsets.only(
                left: horizontalScreenPadding,
                right: horizontalScreenPadding,
                top: 40,
                bottom: 80,
              ),
              child: Column(
                spacing: 30,
                children: [
                  BlocTextField<
                    UpdateProfileSettingsCubit,
                    UpdateProfileSettingsState
                  >(
                    errorSelector: (state) =>
                        state is UpdateProfileSettingsFormInvalid
                        ? state.errors['cardsPerSession']
                        : null,
                    labelText: "Flashcards per session",
                    textEditingController: _cardsPerSessionCont,
                    isEnabledState: (state) =>
                        state is! UpdateProfileSettingsDisabled,
                  ),
                  Spacer(),
                  BlocBuilder<
                    UpdateProfileSettingsCubit,
                    UpdateProfileSettingsState
                  >(
                    builder: (context, state) {
                      void onSave() {
                        context
                            .read<UpdateProfileSettingsCubit>()
                            .updateProfileSettings(
                              cardsPerSessionString: _cardsPerSessionCont.text,
                              currentSettings: widget.profile.profileSettings,
                            );
                      }

                      List<Widget> buttons = [];
                      switch (state) {
                        case UpdateProfileSettingsDisabled():
                          buttons.add(
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: FilledButton(
                                  onPressed: context
                                      .read<UpdateProfileSettingsCubit>()
                                      .enableForm,
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.basicText_edit,
                                  ),
                                ),
                              ),
                            ),
                          );
                          break;
                        default:
                          buttons.add(
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: OutlinedButton(
                                  onPressed: context
                                      .read<UpdateProfileSettingsCubit>()
                                      .disableForm,
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.basicText_cancel,
                                  ),
                                ),
                              ),
                            ),
                          );
                          buttons.add(
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: FilledButton(
                                  onPressed:
                                      state is! UpdateProfileSettingsLoading
                                      ? onSave
                                      : null,
                                  child: state is! UpdateProfileSettingsLoading
                                      ? Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.basicText_save,
                                        )
                                      : SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: CircularProgressIndicator(
                                            color: Colors.grey[200],
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          );
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10,
                        children: buttons,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
