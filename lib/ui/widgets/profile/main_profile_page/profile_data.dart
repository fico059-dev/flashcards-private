import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/authorization/auth/auth_bloc.dart';
import 'package:flashcards/bloc/authorization/auth/auth_event.dart';
import 'package:flashcards/bloc/authorization/auth/auth_state.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_event.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/domain/models/profile/profile.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/dialogs/profile/notification_options_bottom_sheet.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/profile/profile_menu_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

class ProfileData extends StatelessWidget {
  final Profile profile;

  const ProfileData({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    void onSignOut() {
      context.read<AuthBloc>().add(AuthSignOut());
    }

    void openBookmarkDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.profileData_bookmarks),
          content: Text(AppLocalizations.of(context)!.profileData_chooseEngage),
          actions: [
            TextButton(
              onPressed: () {
                context.router.pop();
                context.router.push(ReviewBookmarkRoute());
              },
              child: Text(AppLocalizations.of(context)!.profileData_review),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.router.push(
                  FlashcardRoute(testType: TestType.bookmark),
                );
              },
              child: Text(AppLocalizations.of(context)!.profileData_startTest),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalScreenPadding,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile.isAdmin) const SizedBox(height: 20),
          if (profile.isAdmin)
            Text(
              "Admin",
              style: TextStyle(color: context.colors.onSurfaceVariant),
            ),
          if (profile.isAdmin)
            ProfileMenuWidget(
              title: "Admin Dashboard",
              icon: Icons.admin_panel_settings,
              onPress: () {
                context.router.push(const AdminTabRoute());
              },
            ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.profileData_accountSettings,
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),

          ProfileMenuWidget(
            title: AppLocalizations.of(
              context,
            )!.personalInformationPage_personalInformation,
            icon: Icons.person,
            onPress: () => context.router.push(PersonalInformationRoute()),
          ),
          ProfileMenuWidget(
            title: AppLocalizations.of(context)!.profileData_privacySecurity,
            icon: Icons.lock,
            onPress: () => context.router.push(PrivacySecurityRoute()),
          ),

          // ProfileMenuWidget(
          //   title: AppLocalizations.of(context)!.profileData_billingDetails,
          //   icon: Icons.wallet,
          //   onPress: () {},
          // ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.profileData_flashcards,
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),

          ProfileMenuWidget(
            title: AppLocalizations.of(
              context,
            )!.profileData_bookmarkedFlashcards,
            icon: Icons.bookmark,
            onPress: openBookmarkDialog,
          ),
          ProfileMenuWidget(
            title: AppLocalizations.of(context)!.profileData_flashcardSettings,
            icon: Icons.settings,
            onPress: () => context.router.push(FlashcardSettingsRoute()),
          ),
          if (!kIsWeb)
            ProfileMenuWidget(
              title: "Notification Settings",
              icon: Icons.notifications,
              onPress: () =>
                  showNotificationOptionsBottomSheet(context: context),
            ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.basicText_other,
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          ProfileMenuWidget(
            title: AppLocalizations.of(context)!.profileData_privacyPolicy,
            icon: Icons.policy,
            onPress: () => context.router.push(const PrivacyPolicyRoute()),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return ProfileMenuWidget(
                title: AppLocalizations.of(context)!.basicText_logout,
                icon: state is! AuthLoading
                    ? Icons.logout
                    : Icons.incomplete_circle_outlined,
                textColor: context.colors.error,
                endIcon: false,
                onPress: state is! AuthLoading ? onSignOut : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
