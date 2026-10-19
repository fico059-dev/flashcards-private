import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/authorization/auth/auth_bloc.dart';
import 'package:flashcards/bloc/authorization/auth/auth_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/profile/profile_menu_widget.dart';
import 'package:flashcards/ui/widgets/profile/profile_reader_bloc_builder.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileReaderBlocBuilder(
      onLoadedContent: (profile) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.privacySecurityPage_title),
          leading: IconButton(
            onPressed: () => context.router.pop(),
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: ReadableWidth(
          maxWidth: 820,
          child: Container(
            margin: EdgeInsets.only(top: 25),
            padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
            child: Column(
              children: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    var textString = AppLocalizations.of(
                      context,
                    )!.privacySecurityPage_verified;
                    var textColor = context.customColors.success;
                    var pendingVer = false;
                    switch (state) {
                      case Authenticated(:final pendingEmailVerification):
                        pendingVer = pendingEmailVerification;
                        if (pendingEmailVerification) {
                          textColor = context.colors.error;
                          textString = AppLocalizations.of(
                            context,
                          )!.privacySecurityPage_pendingVerification;
                        }
                      default:
                    }
                    return Tooltip(
                      message: pendingVer
                          ? AppLocalizations.of(
                              context,
                            )!.privacySecurityPage_changeEmailText
                          : "",
                      child: ProfileMenuWidget(
                        title: AppLocalizations.of(
                          context,
                        )!.privacySecurityPage_changeEmail,
                        icon: Icons.email,
                        subtitle: textString,
                        subtitleStyle: TextStyle(color: textColor),
                        onPress: () => context.router.push(ChangeEmailRoute()),
                      ),
                    );
                  },
                ),
                ProfileMenuWidget(
                  title: AppLocalizations.of(
                    context,
                  )!.privacySecurityPage_changePassword,
                  subtitle: AppLocalizations.of(
                    context,
                  )!.privacySecurityPage_hiddenPassword,
                  subtitleStyle: TextStyle(
                    color: context.colors.onSurfaceVariant,
                  ),
                  icon: Icons.password,
                  onPress: () => context.router.push(UpdatePasswordRoute()),
                ),

                // ProfileMenuWidget(
                //   title:
                //       AppLocalizations.of(
                //         context,
                //       )!.privacySecurityPage_changePhone,
                //   icon: Icons.phone,
                //   subtitle:
                //       AppLocalizations.of(
                //         context,
                //       )!.privacySecurityPage_notVerified,
                //   subtitleStyle: TextStyle(color: context.colors.onSurfaceVariant),
                //   onPress: () {},
                // ),
                const SizedBox(height: 10),
                Divider(),
                const SizedBox(height: 10),

                ProfileMenuWidget(
                  title: AppLocalizations.of(
                    context,
                  )!.privacySecurityPage_deleteAccount,
                  icon: Icons.delete,
                  subtitle: AppLocalizations.of(
                    context,
                  )!.privacySecurityPage_deleteAccountSubtitle,
                  subtitleStyle: TextStyle(color: context.colors.error),
                  onPress: () => context.router.push(DeleteProfileRoute()),
                  iconColor: context.colors.error,
                  trailingIcon: Icons.keyboard_arrow_up,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
