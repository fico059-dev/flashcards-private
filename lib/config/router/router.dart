import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flashcards/bloc/authorization/email_verification/email_verification_bloc.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_bloc.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_event.dart';
import 'package:flashcards/config/router/guards/admin_guard.dart';
import 'package:flashcards/config/router/guards/auth_guard.dart';
import 'package:flashcards/config/router/guards/guest_guard.dart';
import 'package:flashcards/config/router/guards/profile_loaded_guard.dart';
import 'package:flashcards/config/router/guards/verify_email_guard.dart';
import 'package:flashcards/config/router/sign_out_handler_wrapper_page.dart';
import 'package:flashcards/domain/enums/pack_selected_filter.dart';
import 'package:flashcards/domain/enums/score_status.dart';
import 'package:flashcards/domain/models/core/image_data_wrapper.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/domain/models/flashcards/custom_session_summary/custom_session_summary.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/domain/models/flashcards/pack/pack.dart';
import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:flashcards/domain/models/osce/osce.dart';
import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';
import 'package:flashcards/ui/dialogs/change_email_during_verification_page.dart';
import 'package:flashcards/ui/dialogs/profile/privacy_security/change_email_page.dart';
import 'package:flashcards/ui/dialogs/profile/privacy_security/delete_profile_page.dart';
import 'package:flashcards/ui/dialogs/report_flashcard_page.dart';
import 'package:flashcards/ui/dialogs/profile/privacy_security/update_password_page.dart';
import 'package:flashcards/ui/pages/auth/forgot_password_page.dart';
import 'package:flashcards/ui/pages/auth/login_page.dart';
import 'package:flashcards/ui/pages/auth/register_page.dart';
import 'package:flashcards/ui/pages/auth/verify_email_page.dart';
import 'package:flashcards/ui/pages/custom_session/custom_session_maker/custom_session_wrapper_page.dart';
import 'package:flashcards/ui/pages/custom_session/custom_session_maker/flashcard_limit_page.dart';
import 'package:flashcards/ui/pages/custom_session/custom_session_maker/flashcard_tag_selection_page.dart';
import 'package:flashcards/ui/pages/custom_session/custom_session_maker/flashcards_filter_page.dart';
import 'package:flashcards/ui/pages/custom_session/custom_session_maker/pack_selection_page.dart';
import 'package:flashcards/ui/pages/custom_session/custom_session_test/custom_session_test_page.dart';
import 'package:flashcards/ui/pages/flashcards/flashcard_page.dart';
import 'package:flashcards/ui/pages/flashcards/flashcard_preview_page.dart';
import 'package:flashcards/ui/pages/flashcards/review_bookmark_page.dart';
import 'package:flashcards/ui/pages/notebook/notebook_page.dart';
import 'package:flashcards/ui/pages/main_tab_pages/home_page.dart';
import 'package:flashcards/ui/pages/main_tab_pages/learning_progress/learning_progress_page.dart';
import 'package:flashcards/ui/pages/main_tab_pages/learning_progress/started_packs_page.dart';
import 'package:flashcards/ui/pages/main_tab_pages/main_tab_page.dart';
import 'package:flashcards/ui/pages/main_tab_pages/osce_list_page.dart';
import 'package:flashcards/ui/pages/main_tab_pages/packs_tab_page/packs_tab_page.dart';
import 'package:flashcards/ui/pages/osces/osce_page.dart';
import 'package:flashcards/ui/pages/osces/osce_performances_page.dart';
import 'package:flashcards/ui/pages/osces/osce_submit_page.dart';
import 'package:flashcards/ui/pages/main_tab_pages/packs_tab_page/packs_page.dart';
import 'package:flashcards/ui/pages/paywall/prod_paywall_page.dart';
import 'package:flashcards/ui/pages/permission_denied_page.dart';
import 'package:flashcards/ui/pages/custom_session/previous_sessions/previous_sessions_page.dart';
import 'package:flashcards/ui/pages/profile/admin_dashboard/admin_tab_page.dart';
import 'package:flashcards/ui/pages/profile/admin_dashboard/assign_admin_page.dart';
import 'package:flashcards/ui/pages/profile/admin_dashboard/flashcard_builder/anki_import_page.dart';
import 'package:flashcards/ui/pages/profile/admin_dashboard/flashcard_builder/create_flashcard_page.dart';
import 'package:flashcards/ui/pages/profile/admin_dashboard/flashcard_builder/flashcard_builder_page.dart';
import 'package:flashcards/ui/pages/profile/admin_dashboard/flashcard_builder/manage_pack_flashcards_page.dart';
import 'package:flashcards/ui/pages/profile/admin_dashboard/osce_builder/osce_builder_page.dart';
import 'package:flashcards/ui/pages/profile/admin_dashboard/question_builder/create_question_page.dart';
import 'package:flashcards/ui/pages/profile/admin_dashboard/reports/flashcard_reports_page.dart';
import 'package:flashcards/ui/pages/profile/flashcard_settings_pages/manage_ignored_flashcards_page.dart';
import 'package:flashcards/ui/pages/profile/flashcard_settings_pages/update_cards_per_session_page.dart';
import 'package:flashcards/ui/pages/profile/privacy_policy_page.dart';
import 'package:flashcards/ui/pages/profile/personal_information_page.dart';
import 'package:flashcards/ui/pages/profile/privacy_security_page.dart';
import 'package:flashcards/ui/pages/profile/profile_page.dart';
import 'package:flashcards/ui/pages/profile/flashcard_settings_pages/flashcard_settings_page.dart';
import 'package:flashcards/ui/pages/search/admin_pack_search_page.dart';
import 'package:flashcards/ui/pages/search/flashcards_searcher_page.dart';
import 'package:flashcards/ui/pages/search/pack_search_page.dart';
import 'package:flashcards/ui/pages/splash_page.dart';
import 'package:flashcards/ui/pages/main_tab_pages/stats_page.dart';
import 'package:flashcards/ui/pages/success_pages/custom_session_result_page.dart';
import 'package:flashcards/ui/pages/success_pages/delete_account_successful_page.dart';
import 'package:flashcards/ui/pages/success_pages/flashcard_session_success_page.dart';
import 'package:flashcards/ui/pages/success_pages/pack_finished_page.dart';
import 'package:flashcards/ui/pages/success_pages/update_email_successful_page.dart';
import 'package:flashcards/ui/pages/tutorials/flashcards_tutorial_page.dart';
import 'package:flashcards/ui/pages/tutorials/osce_tutorial_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final AuthGuard authGuard;
  final GuestGuard guestGuard;
  final VerifyEmailGuard verifyEmailGuard;
  final ProfileLoadedGuard profileLoadedGuard;
  final AdminGuard adminGuard;

  AppRouter({
    required this.authGuard,
    required this.guestGuard,
    required this.verifyEmailGuard,
    required this.profileLoadedGuard,
    required this.adminGuard,
  });

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: PermissionDeniedRoute.page),

    // This wrapper is used to detect sign out event and handle it properly
    // Basically put all pages inside this wrapper that require user to be signed in
    AutoRoute(
      page: SignOutHandlerWrapperRoute.page,
      children: [
        AutoRoute(page: ProdPaywallRoute.page, guards: [authGuard]),

        // Navigation bar route
        AutoRoute(
          page: MainTabRoute.page,
          children: [
            AutoRoute(page: HomeRoute.page, guards: [authGuard]),
            AutoRoute(page: OsceListRoute.page, guards: [authGuard]),
            AutoRoute(page: PacksTabRoute.page, children: [
              AutoRoute(page: PacksRoute.page, guards: [authGuard]),
              AutoRoute(page: PreviousSessionsRoute.page, guards: [authGuard]),
              AutoRoute(page: NotebookRoute.page, guards: [authGuard]),
            ]),
            AutoRoute(page: LearningProgressRoute.page, guards: [authGuard]),
          ],
        ),

        // Profile routes
        AutoRoute(page: ProfileRoute.page, guards: [authGuard]),
        AutoRoute(page: PersonalInformationRoute.page, guards: [authGuard]),
        AutoRoute(page: PrivacySecurityRoute.page, guards: [authGuard]),
        AutoRoute(page: FlashcardSettingsRoute.page, guards: [authGuard]),
        AutoRoute(page: PrivacyPolicyRoute.page, guards: [authGuard]),
        // Admin dashboard
        AutoRoute(
          page: AdminTabRoute.page,
          guards: [authGuard, profileLoadedGuard, adminGuard],
          children: [
            AutoRoute(
              page: FlashcardBuilderRoute.page,
              guards: [authGuard, adminGuard],
            ),
            AutoRoute(
              page: AssignAdminRoute.page,
              guards: [authGuard, adminGuard],
            ),
            AutoRoute(
              page: OsceBuilderRoute.page,
              guards: [authGuard, adminGuard],
            ),
            AutoRoute(
              page: FlashcardReportsRoute.page,
              guards: [authGuard, adminGuard],
            ),

            // Search page
            AutoRoute(
              page: AdminPackSearchRoute.page,
              guards: [adminGuard, authGuard],
            ),
          ],
        ),
        AutoRoute(
          page: ManagePackFlashcardsRoute.page,
          guards: [authGuard, adminGuard],
        ),
        AutoRoute(
          page: CreateFlashcardRoute.page,
          guards: [authGuard, adminGuard],
        ),
        AutoRoute(
          page: AnkiImportRoute.page,
          guards: [authGuard, adminGuard],
        ),
        AutoRoute(
          page: QuestionEditorRoute.page,
          guards: [authGuard, adminGuard],
        ),

        // Learning progress routes
        AutoRoute(page: StartedPacksRoute.page, guards: [authGuard]),

        // Flashcard settings routes
        AutoRoute(page: UpdateCardsPerSessionRoute.page, guards: [authGuard]),
        AutoRoute(page: ManageIgnoredFlashcardsRoute.page, guards: [authGuard]),

        // Flashcard features
        AutoRoute(
          page: FlashcardRoute.page,
          guards: [authGuard, profileLoadedGuard],
        ),
        AutoRoute(page: ReviewBookmarkRoute.page, guards: [authGuard]),
        CustomRoute(
          page: ReportFlashcardRoute.page,
          fullscreenDialog: true,
          transitionsBuilder: TransitionsBuilders.slideBottom,
          guards: [authGuard],
        ),
        CustomRoute(
          page: FlashcardPreviewRoute.page,
          fullscreenDialog: true,
          transitionsBuilder: TransitionsBuilders.slideBottom,
          guards: [authGuard],
        ),

        // Custom sessions routes
        AutoRoute(
          page: CustomSessionWrapperRoute.page,
          guards: [authGuard],
          children: [
            CustomRoute(
              page: PackSelectionRoute.page,
              initial: true,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      ),
            ),
            CustomRoute(
              page: FlashcardsFilterRoute.page,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      ),
            ),
            CustomRoute(
              page: FlashcardTagSelectionRoute.page,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      ),
            ),
            CustomRoute(
              page: FlashcardLimitRoute.page,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      ),
            ),
          ],
        ),
        AutoRoute(
          page: CustomSessionTestRoute.page,
          guards: [authGuard, profileLoadedGuard],
        ),

        // Search pages
        CustomRoute(
          page: PackSearchRoute.page,
          fullscreenDialog: true,
          transitionsBuilder: TransitionsBuilders.slideBottom,
          guards: [authGuard],
        ),
        CustomRoute(
          page: FlashcardsSearcherRoute.page,
          fullscreenDialog: true,
          transitionsBuilder: TransitionsBuilders.slideBottom,
          guards: [authGuard, profileLoadedGuard],
        ),

        // Osce pages
        AutoRoute(page: OsceListRoute.page, guards: [authGuard]),
        AutoRoute(page: OsceRoute.page, guards: [authGuard]),
        AutoRoute(page: OsceSubmitRoute.page, guards: [authGuard]),
        AutoRoute(page: OscePerformancesRoute.page, guards: [authGuard]),

        // Update dialogs
        CustomRoute(
          page: DeleteProfileRoute.page,
          fullscreenDialog: true,
          transitionsBuilder: TransitionsBuilders.slideBottom,
          guards: [authGuard],
        ),
        CustomRoute(
          page: UpdatePasswordRoute.page,
          fullscreenDialog: true,
          transitionsBuilder: TransitionsBuilders.slideBottom,
          guards: [authGuard],
        ),
        CustomRoute(
          page: ChangeEmailRoute.page,
          fullscreenDialog: true,
          transitionsBuilder: TransitionsBuilders.slideBottom,
          guards: [authGuard],
        ),
      ],
    ),

    // Tutorial pages
    AutoRoute(page: FlashcardsTutorialRoute.page, guards: [authGuard]),
    AutoRoute(page: OsceTutorialRoute.page, guards: [authGuard]),

    // Success pages
    AutoRoute(page: DeleteAccountSuccessfulRoute.page, guards: [guestGuard]),
    AutoRoute(page: UpdateEmailSuccessfulRoute.page, guards: [guestGuard]),
    AutoRoute(page: FlashcardSessionSuccessRoute.page, guards: [authGuard]),
    AutoRoute(page: PackFinishedRoute.page, guards: [authGuard]),
    AutoRoute(page: CustomSessionResultRoute.page, guards: [authGuard]),

    // Auth pages
    AutoRoute(page: ForgotPasswordRoute.page, guards: [guestGuard]),
    AutoRoute(page: LoginRoute.page, guards: [guestGuard]),
    AutoRoute(page: RegisterRoute.page, guards: [guestGuard]),
    AutoRoute(page: VerifyEmailRoute.page, guards: [verifyEmailGuard]),
    CustomRoute(
      page: ChangeEmailDuringVerificationRoute.page,
      fullscreenDialog: true,
      transitionsBuilder: TransitionsBuilders.slideBottom,
      guards: [verifyEmailGuard],
    ),
  ];
}
