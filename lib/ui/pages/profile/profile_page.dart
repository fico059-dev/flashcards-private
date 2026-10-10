import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/authorization/auth/auth_bloc.dart';
import 'package:flashcards/bloc/authorization/auth/auth_state.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/theme_toggle_button.dart';
import 'package:flashcards/ui/widgets/profile/main_profile_page/more_profile_details.dart';
import 'package:flashcards/ui/widgets/profile/main_profile_page/profile_data.dart';
import 'package:flashcards/ui/widgets/profile/profile_reader_bloc_builder.dart';
import 'package:flashcards/ui/widgets/profile/profile_sliver_app_bar.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                mapFirebaseError(error: state.error, context: context).message,
              ),
            ),
          );
          return;
        }
      },
      child: ProfileReaderBlocBuilder(
        onLoadedContent: (profile) => Scaffold(
          body: ReadableWidth(
            maxWidth: 820,
            child: CustomScrollView(
              slivers: [
                ProfileSliverAppBar(
                  title: Text(
                    AppLocalizations.of(context)!.basicText_profile,
                    style: TextStyle(color: context.colors.onPrimary),
                  ),
                  actions: [
                    ThemeToggleButton(iconColor: context.colors.onPrimary),
                  ],
                  expandedHeight: 190,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      margin: EdgeInsets.only(top: 80),
                      child: MoreProfileDetails(profile: profile),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: ProfileData(profile: profile)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
