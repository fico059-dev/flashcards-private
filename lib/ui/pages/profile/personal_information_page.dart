import 'package:auto_route/annotations.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/profile/personal_information/personal_info_content.dart';
import 'package:flashcards/ui/widgets/profile/personal_information/personal_info_flexible_space.dart';
import 'package:flashcards/ui/widgets/profile/profile_reader_bloc_builder.dart';
import 'package:flashcards/ui/widgets/profile/profile_sliver_app_bar.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class PersonalInformationPage extends StatelessWidget {
  const PersonalInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileReaderBlocBuilder(
      onLoadedContent: (profile) => Scaffold(
        body: ReadableWidth(
          maxWidth: 820,
          child: CustomScrollView(
            slivers: [
              ProfileSliverAppBar(
                expandedHeight: 165,
                title: Text(
                  AppLocalizations.of(
                    context,
                  )!.personalInformationPage_personalInformation,
                  style: TextStyle(color: context.colors.onPrimary),
                ),
                flexibleSpace: PersonalInfoFlexibleSpace(),
              ),
              SliverToBoxAdapter(child: PersonalInfoContent(profile: profile)),
            ],
          ),
        ),
      ),
    );
  }
}
