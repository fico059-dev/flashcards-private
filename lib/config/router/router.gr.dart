// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [AdminPackSearchPage]
class AdminPackSearchRoute extends PageRouteInfo<void> {
  const AdminPackSearchRoute({List<PageRouteInfo>? children})
    : super(AdminPackSearchRoute.name, initialChildren: children);

  static const String name = 'AdminPackSearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AdminPackSearchPage();
    },
  );
}

/// generated route for
/// [AdminTabPage]
class AdminTabRoute extends PageRouteInfo<void> {
  const AdminTabRoute({List<PageRouteInfo>? children})
    : super(AdminTabRoute.name, initialChildren: children);

  static const String name = 'AdminTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const AdminTabPage());
    },
  );
}

/// generated route for
/// [AnkiImportPage]
class AnkiImportRoute extends PageRouteInfo<AnkiImportRouteArgs> {
  AnkiImportRoute({
    Key? key,
    required AdminPack pack,
    List<PageRouteInfo>? children,
  }) : super(
         AnkiImportRoute.name,
         args: AnkiImportRouteArgs(key: key, pack: pack),
         initialChildren: children,
       );

  static const String name = 'AnkiImportRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AnkiImportRouteArgs>();
      return AnkiImportPage(key: args.key, pack: args.pack);
    },
  );
}

class AnkiImportRouteArgs {
  const AnkiImportRouteArgs({this.key, required this.pack});

  final Key? key;

  final AdminPack pack;

  @override
  String toString() {
    return 'AnkiImportRouteArgs{key: $key, pack: $pack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnkiImportRouteArgs) return false;
    return key == other.key && pack == other.pack;
  }

  @override
  int get hashCode => key.hashCode ^ pack.hashCode;
}

/// generated route for
/// [AssignAdminPage]
class AssignAdminRoute extends PageRouteInfo<void> {
  const AssignAdminRoute({List<PageRouteInfo>? children})
    : super(AssignAdminRoute.name, initialChildren: children);

  static const String name = 'AssignAdminRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AssignAdminPage();
    },
  );
}

/// generated route for
/// [ChangeEmailDuringVerificationPage]
class ChangeEmailDuringVerificationRoute
    extends PageRouteInfo<ChangeEmailDuringVerificationRouteArgs> {
  ChangeEmailDuringVerificationRoute({
    Key? key,
    required EmailVerificationBloc emailVerificationBloc,
    List<PageRouteInfo>? children,
  }) : super(
         ChangeEmailDuringVerificationRoute.name,
         args: ChangeEmailDuringVerificationRouteArgs(
           key: key,
           emailVerificationBloc: emailVerificationBloc,
         ),
         initialChildren: children,
       );

  static const String name = 'ChangeEmailDuringVerificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChangeEmailDuringVerificationRouteArgs>();
      return ChangeEmailDuringVerificationPage(
        key: args.key,
        emailVerificationBloc: args.emailVerificationBloc,
      );
    },
  );
}

class ChangeEmailDuringVerificationRouteArgs {
  const ChangeEmailDuringVerificationRouteArgs({
    this.key,
    required this.emailVerificationBloc,
  });

  final Key? key;

  final EmailVerificationBloc emailVerificationBloc;

  @override
  String toString() {
    return 'ChangeEmailDuringVerificationRouteArgs{key: $key, emailVerificationBloc: $emailVerificationBloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChangeEmailDuringVerificationRouteArgs) return false;
    return key == other.key &&
        emailVerificationBloc == other.emailVerificationBloc;
  }

  @override
  int get hashCode => key.hashCode ^ emailVerificationBloc.hashCode;
}

/// generated route for
/// [ChangeEmailPage]
class ChangeEmailRoute extends PageRouteInfo<void> {
  const ChangeEmailRoute({List<PageRouteInfo>? children})
    : super(ChangeEmailRoute.name, initialChildren: children);

  static const String name = 'ChangeEmailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangeEmailPage();
    },
  );
}

/// generated route for
/// [CreateFlashcardPage]
class CreateFlashcardRoute extends PageRouteInfo<CreateFlashcardRouteArgs> {
  CreateFlashcardRoute({
    Key? key,
    required AdminPack pack,
    List<PageRouteInfo>? children,
  }) : super(
         CreateFlashcardRoute.name,
         args: CreateFlashcardRouteArgs(key: key, pack: pack),
         initialChildren: children,
       );

  static const String name = 'CreateFlashcardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateFlashcardRouteArgs>();
      return CreateFlashcardPage(key: args.key, pack: args.pack);
    },
  );
}

class CreateFlashcardRouteArgs {
  const CreateFlashcardRouteArgs({this.key, required this.pack});

  final Key? key;

  final AdminPack pack;

  @override
  String toString() {
    return 'CreateFlashcardRouteArgs{key: $key, pack: $pack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateFlashcardRouteArgs) return false;
    return key == other.key && pack == other.pack;
  }

  @override
  int get hashCode => key.hashCode ^ pack.hashCode;
}

/// generated route for
/// [CustomSessionResultPage]
class CustomSessionResultRoute
    extends PageRouteInfo<CustomSessionResultRouteArgs> {
  CustomSessionResultRoute({
    Key? key,
    required ScoreStatus scoreStatus,
    required int correctCount,
    required int allCount,
    List<PageRouteInfo>? children,
  }) : super(
         CustomSessionResultRoute.name,
         args: CustomSessionResultRouteArgs(
           key: key,
           scoreStatus: scoreStatus,
           correctCount: correctCount,
           allCount: allCount,
         ),
         initialChildren: children,
       );

  static const String name = 'CustomSessionResultRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CustomSessionResultRouteArgs>();
      return CustomSessionResultPage(
        key: args.key,
        scoreStatus: args.scoreStatus,
        correctCount: args.correctCount,
        allCount: args.allCount,
      );
    },
  );
}

class CustomSessionResultRouteArgs {
  const CustomSessionResultRouteArgs({
    this.key,
    required this.scoreStatus,
    required this.correctCount,
    required this.allCount,
  });

  final Key? key;

  final ScoreStatus scoreStatus;

  final int correctCount;

  final int allCount;

  @override
  String toString() {
    return 'CustomSessionResultRouteArgs{key: $key, scoreStatus: $scoreStatus, correctCount: $correctCount, allCount: $allCount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomSessionResultRouteArgs) return false;
    return key == other.key &&
        scoreStatus == other.scoreStatus &&
        correctCount == other.correctCount &&
        allCount == other.allCount;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      scoreStatus.hashCode ^
      correctCount.hashCode ^
      allCount.hashCode;
}

/// generated route for
/// [CustomSessionTestPage]
class CustomSessionTestRoute extends PageRouteInfo<CustomSessionTestRouteArgs> {
  CustomSessionTestRoute({
    Key? key,
    required CustomSessionSummary sessionSummary,
    List<PageRouteInfo>? children,
  }) : super(
         CustomSessionTestRoute.name,
         args: CustomSessionTestRouteArgs(
           key: key,
           sessionSummary: sessionSummary,
         ),
         initialChildren: children,
       );

  static const String name = 'CustomSessionTestRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CustomSessionTestRouteArgs>();
      return CustomSessionTestPage(
        key: args.key,
        sessionSummary: args.sessionSummary,
      );
    },
  );
}

class CustomSessionTestRouteArgs {
  const CustomSessionTestRouteArgs({this.key, required this.sessionSummary});

  final Key? key;

  final CustomSessionSummary sessionSummary;

  @override
  String toString() {
    return 'CustomSessionTestRouteArgs{key: $key, sessionSummary: $sessionSummary}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomSessionTestRouteArgs) return false;
    return key == other.key && sessionSummary == other.sessionSummary;
  }

  @override
  int get hashCode => key.hashCode ^ sessionSummary.hashCode;
}

/// generated route for
/// [CustomSessionWrapperPage]
class CustomSessionWrapperRoute extends PageRouteInfo<void> {
  const CustomSessionWrapperRoute({List<PageRouteInfo>? children})
    : super(CustomSessionWrapperRoute.name, initialChildren: children);

  static const String name = 'CustomSessionWrapperRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const CustomSessionWrapperPage());
    },
  );
}

/// generated route for
/// [DeleteAccountSuccessfulPage]
class DeleteAccountSuccessfulRoute extends PageRouteInfo<void> {
  const DeleteAccountSuccessfulRoute({List<PageRouteInfo>? children})
    : super(DeleteAccountSuccessfulRoute.name, initialChildren: children);

  static const String name = 'DeleteAccountSuccessfulRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DeleteAccountSuccessfulPage();
    },
  );
}

/// generated route for
/// [DeleteProfilePage]
class DeleteProfileRoute extends PageRouteInfo<void> {
  const DeleteProfileRoute({List<PageRouteInfo>? children})
    : super(DeleteProfileRoute.name, initialChildren: children);

  static const String name = 'DeleteProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DeleteProfilePage();
    },
  );
}

/// generated route for
/// [FlashcardBuilderPage]
class FlashcardBuilderRoute extends PageRouteInfo<void> {
  const FlashcardBuilderRoute({List<PageRouteInfo>? children})
    : super(FlashcardBuilderRoute.name, initialChildren: children);

  static const String name = 'FlashcardBuilderRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FlashcardBuilderPage();
    },
  );
}

/// generated route for
/// [FlashcardLimitPage]
class FlashcardLimitRoute extends PageRouteInfo<FlashcardLimitRouteArgs> {
  FlashcardLimitRoute({
    Key? key,
    required List<AdminPack> selectedPacks,
    required PackSelectedFilter filter,
    required List<Tag> selectedTags,
    required int packFilterCount,
    required bool areAllTagsSelected,
    List<PageRouteInfo>? children,
  }) : super(
         FlashcardLimitRoute.name,
         args: FlashcardLimitRouteArgs(
           key: key,
           selectedPacks: selectedPacks,
           filter: filter,
           selectedTags: selectedTags,
           packFilterCount: packFilterCount,
           areAllTagsSelected: areAllTagsSelected,
         ),
         initialChildren: children,
       );

  static const String name = 'FlashcardLimitRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FlashcardLimitRouteArgs>();
      return FlashcardLimitPage(
        key: args.key,
        selectedPacks: args.selectedPacks,
        filter: args.filter,
        selectedTags: args.selectedTags,
        packFilterCount: args.packFilterCount,
        areAllTagsSelected: args.areAllTagsSelected,
      );
    },
  );
}

class FlashcardLimitRouteArgs {
  const FlashcardLimitRouteArgs({
    this.key,
    required this.selectedPacks,
    required this.filter,
    required this.selectedTags,
    required this.packFilterCount,
    required this.areAllTagsSelected,
  });

  final Key? key;

  final List<AdminPack> selectedPacks;

  final PackSelectedFilter filter;

  final List<Tag> selectedTags;

  final int packFilterCount;

  final bool areAllTagsSelected;

  @override
  String toString() {
    return 'FlashcardLimitRouteArgs{key: $key, selectedPacks: $selectedPacks, filter: $filter, selectedTags: $selectedTags, packFilterCount: $packFilterCount, areAllTagsSelected: $areAllTagsSelected}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FlashcardLimitRouteArgs) return false;
    return key == other.key &&
        const ListEquality<AdminPack>().equals(
          selectedPacks,
          other.selectedPacks,
        ) &&
        filter == other.filter &&
        const ListEquality<Tag>().equals(selectedTags, other.selectedTags) &&
        packFilterCount == other.packFilterCount &&
        areAllTagsSelected == other.areAllTagsSelected;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const ListEquality<AdminPack>().hash(selectedPacks) ^
      filter.hashCode ^
      const ListEquality<Tag>().hash(selectedTags) ^
      packFilterCount.hashCode ^
      areAllTagsSelected.hashCode;
}

/// generated route for
/// [FlashcardPage]
class FlashcardRoute extends PageRouteInfo<FlashcardRouteArgs> {
  FlashcardRoute({
    Key? key,
    required TestType testType,
    Pack? pack,
    List<PageRouteInfo>? children,
  }) : super(
         FlashcardRoute.name,
         args: FlashcardRouteArgs(key: key, testType: testType, pack: pack),
         initialChildren: children,
       );

  static const String name = 'FlashcardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FlashcardRouteArgs>();
      return FlashcardPage(
        key: args.key,
        testType: args.testType,
        pack: args.pack,
      );
    },
  );
}

class FlashcardRouteArgs {
  const FlashcardRouteArgs({this.key, required this.testType, this.pack});

  final Key? key;

  final TestType testType;

  final Pack? pack;

  @override
  String toString() {
    return 'FlashcardRouteArgs{key: $key, testType: $testType, pack: $pack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FlashcardRouteArgs) return false;
    return key == other.key && testType == other.testType && pack == other.pack;
  }

  @override
  int get hashCode => key.hashCode ^ testType.hashCode ^ pack.hashCode;
}

/// generated route for
/// [FlashcardPreviewPage]
class FlashcardPreviewRoute extends PageRouteInfo<FlashcardPreviewRouteArgs> {
  FlashcardPreviewRoute({
    Key? key,
    required Flashcard flashcard,
    ImageDataWrapper? questionImageData,
    ImageDataWrapper? answerImageData,
    List<PageRouteInfo>? children,
  }) : super(
         FlashcardPreviewRoute.name,
         args: FlashcardPreviewRouteArgs(
           key: key,
           flashcard: flashcard,
           questionImageData: questionImageData,
           answerImageData: answerImageData,
         ),
         initialChildren: children,
       );

  static const String name = 'FlashcardPreviewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FlashcardPreviewRouteArgs>();
      return FlashcardPreviewPage(
        key: args.key,
        flashcard: args.flashcard,
        questionImageData: args.questionImageData,
        answerImageData: args.answerImageData,
      );
    },
  );
}

class FlashcardPreviewRouteArgs {
  const FlashcardPreviewRouteArgs({
    this.key,
    required this.flashcard,
    this.questionImageData,
    this.answerImageData,
  });

  final Key? key;

  final Flashcard flashcard;

  final ImageDataWrapper? questionImageData;

  final ImageDataWrapper? answerImageData;

  @override
  String toString() {
    return 'FlashcardPreviewRouteArgs{key: $key, flashcard: $flashcard, questionImageData: $questionImageData, answerImageData: $answerImageData}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FlashcardPreviewRouteArgs) return false;
    return key == other.key &&
        flashcard == other.flashcard &&
        questionImageData == other.questionImageData &&
        answerImageData == other.answerImageData;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      flashcard.hashCode ^
      questionImageData.hashCode ^
      answerImageData.hashCode;
}

/// generated route for
/// [FlashcardReportsPage]
class FlashcardReportsRoute extends PageRouteInfo<void> {
  const FlashcardReportsRoute({List<PageRouteInfo>? children})
    : super(FlashcardReportsRoute.name, initialChildren: children);

  static const String name = 'FlashcardReportsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FlashcardReportsPage();
    },
  );
}

/// generated route for
/// [FlashcardSessionSuccessPage]
class FlashcardSessionSuccessRoute
    extends PageRouteInfo<FlashcardSessionSuccessRouteArgs> {
  FlashcardSessionSuccessRoute({
    Key? key,
    required FlashcardBloc fcBloc,
    List<PageRouteInfo>? children,
  }) : super(
         FlashcardSessionSuccessRoute.name,
         args: FlashcardSessionSuccessRouteArgs(key: key, fcBloc: fcBloc),
         initialChildren: children,
       );

  static const String name = 'FlashcardSessionSuccessRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FlashcardSessionSuccessRouteArgs>();
      return FlashcardSessionSuccessPage(key: args.key, fcBloc: args.fcBloc);
    },
  );
}

class FlashcardSessionSuccessRouteArgs {
  const FlashcardSessionSuccessRouteArgs({this.key, required this.fcBloc});

  final Key? key;

  final FlashcardBloc fcBloc;

  @override
  String toString() {
    return 'FlashcardSessionSuccessRouteArgs{key: $key, fcBloc: $fcBloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FlashcardSessionSuccessRouteArgs) return false;
    return key == other.key && fcBloc == other.fcBloc;
  }

  @override
  int get hashCode => key.hashCode ^ fcBloc.hashCode;
}

/// generated route for
/// [FlashcardSettingsPage]
class FlashcardSettingsRoute extends PageRouteInfo<void> {
  const FlashcardSettingsRoute({List<PageRouteInfo>? children})
    : super(FlashcardSettingsRoute.name, initialChildren: children);

  static const String name = 'FlashcardSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FlashcardSettingsPage();
    },
  );
}

/// generated route for
/// [FlashcardTagSelectionPage]
class FlashcardTagSelectionRoute
    extends PageRouteInfo<FlashcardTagSelectionRouteArgs> {
  FlashcardTagSelectionRoute({
    Key? key,
    required List<AdminPack> packs,
    List<PageRouteInfo>? children,
  }) : super(
         FlashcardTagSelectionRoute.name,
         args: FlashcardTagSelectionRouteArgs(key: key, packs: packs),
         initialChildren: children,
       );

  static const String name = 'FlashcardTagSelectionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FlashcardTagSelectionRouteArgs>();
      return FlashcardTagSelectionPage(key: args.key, packs: args.packs);
    },
  );
}

class FlashcardTagSelectionRouteArgs {
  const FlashcardTagSelectionRouteArgs({this.key, required this.packs});

  final Key? key;

  final List<AdminPack> packs;

  @override
  String toString() {
    return 'FlashcardTagSelectionRouteArgs{key: $key, packs: $packs}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FlashcardTagSelectionRouteArgs) return false;
    return key == other.key &&
        const ListEquality<AdminPack>().equals(packs, other.packs);
  }

  @override
  int get hashCode =>
      key.hashCode ^ const ListEquality<AdminPack>().hash(packs);
}

/// generated route for
/// [FlashcardsFilterPage]
class FlashcardsFilterRoute extends PageRouteInfo<FlashcardsFilterRouteArgs> {
  FlashcardsFilterRoute({
    Key? key,
    required List<String> selectedPacks,
    required int allCount,
    List<PageRouteInfo>? children,
  }) : super(
         FlashcardsFilterRoute.name,
         args: FlashcardsFilterRouteArgs(
           key: key,
           selectedPacks: selectedPacks,
           allCount: allCount,
         ),
         initialChildren: children,
       );

  static const String name = 'FlashcardsFilterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FlashcardsFilterRouteArgs>();
      return FlashcardsFilterPage(
        key: args.key,
        selectedPacks: args.selectedPacks,
        allCount: args.allCount,
      );
    },
  );
}

class FlashcardsFilterRouteArgs {
  const FlashcardsFilterRouteArgs({
    this.key,
    required this.selectedPacks,
    required this.allCount,
  });

  final Key? key;

  final List<String> selectedPacks;

  final int allCount;

  @override
  String toString() {
    return 'FlashcardsFilterRouteArgs{key: $key, selectedPacks: $selectedPacks, allCount: $allCount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FlashcardsFilterRouteArgs) return false;
    return key == other.key &&
        const ListEquality<String>().equals(
          selectedPacks,
          other.selectedPacks,
        ) &&
        allCount == other.allCount;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const ListEquality<String>().hash(selectedPacks) ^
      allCount.hashCode;
}

/// generated route for
/// [FlashcardsSearcherPage]
class FlashcardsSearcherRoute extends PageRouteInfo<void> {
  const FlashcardsSearcherRoute({List<PageRouteInfo>? children})
    : super(FlashcardsSearcherRoute.name, initialChildren: children);

  static const String name = 'FlashcardsSearcherRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FlashcardsSearcherPage();
    },
  );
}

/// generated route for
/// [FlashcardsTutorialPage]
class FlashcardsTutorialRoute
    extends PageRouteInfo<FlashcardsTutorialRouteArgs> {
  FlashcardsTutorialRoute({
    Key? key,
    VoidCallback? onFinish,
    List<PageRouteInfo>? children,
  }) : super(
         FlashcardsTutorialRoute.name,
         args: FlashcardsTutorialRouteArgs(key: key, onFinish: onFinish),
         initialChildren: children,
       );

  static const String name = 'FlashcardsTutorialRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FlashcardsTutorialRouteArgs>(
        orElse: () => const FlashcardsTutorialRouteArgs(),
      );
      return FlashcardsTutorialPage(key: args.key, onFinish: args.onFinish);
    },
  );
}

class FlashcardsTutorialRouteArgs {
  const FlashcardsTutorialRouteArgs({this.key, this.onFinish});

  final Key? key;

  final VoidCallback? onFinish;

  @override
  String toString() {
    return 'FlashcardsTutorialRouteArgs{key: $key, onFinish: $onFinish}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FlashcardsTutorialRouteArgs) return false;
    return key == other.key && onFinish == other.onFinish;
  }

  @override
  int get hashCode => key.hashCode ^ onFinish.hashCode;
}

/// generated route for
/// [ForgotPasswordPage]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordPage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LearningProgressPage]
class LearningProgressRoute extends PageRouteInfo<void> {
  const LearningProgressRoute({List<PageRouteInfo>? children})
    : super(LearningProgressRoute.name, initialChildren: children);

  static const String name = 'LearningProgressRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LearningProgressPage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [MainTabPage]
class MainTabRoute extends PageRouteInfo<void> {
  const MainTabRoute({List<PageRouteInfo>? children})
    : super(MainTabRoute.name, initialChildren: children);

  static const String name = 'MainTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const MainTabPage());
    },
  );
}

/// generated route for
/// [ManageIgnoredFlashcardsPage]
class ManageIgnoredFlashcardsRoute extends PageRouteInfo<void> {
  const ManageIgnoredFlashcardsRoute({List<PageRouteInfo>? children})
    : super(ManageIgnoredFlashcardsRoute.name, initialChildren: children);

  static const String name = 'ManageIgnoredFlashcardsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ManageIgnoredFlashcardsPage();
    },
  );
}

/// generated route for
/// [ManagePackFlashcardsPage]
class ManagePackFlashcardsRoute
    extends PageRouteInfo<ManagePackFlashcardsRouteArgs> {
  ManagePackFlashcardsRoute({
    Key? key,
    required AdminPack pack,
    List<PageRouteInfo>? children,
  }) : super(
         ManagePackFlashcardsRoute.name,
         args: ManagePackFlashcardsRouteArgs(key: key, pack: pack),
         initialChildren: children,
       );

  static const String name = 'ManagePackFlashcardsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ManagePackFlashcardsRouteArgs>();
      return ManagePackFlashcardsPage(key: args.key, pack: args.pack);
    },
  );
}

class ManagePackFlashcardsRouteArgs {
  const ManagePackFlashcardsRouteArgs({this.key, required this.pack});

  final Key? key;

  final AdminPack pack;

  @override
  String toString() {
    return 'ManagePackFlashcardsRouteArgs{key: $key, pack: $pack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ManagePackFlashcardsRouteArgs) return false;
    return key == other.key && pack == other.pack;
  }

  @override
  int get hashCode => key.hashCode ^ pack.hashCode;
}

/// generated route for
/// [OsceBuilderPage]
class OsceBuilderRoute extends PageRouteInfo<void> {
  const OsceBuilderRoute({List<PageRouteInfo>? children})
    : super(OsceBuilderRoute.name, initialChildren: children);

  static const String name = 'OsceBuilderRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OsceBuilderPage();
    },
  );
}

/// generated route for
/// [OsceListPage]
class OsceListRoute extends PageRouteInfo<void> {
  const OsceListRoute({List<PageRouteInfo>? children})
    : super(OsceListRoute.name, initialChildren: children);

  static const String name = 'OsceListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OsceListPage();
    },
  );
}

/// generated route for
/// [OscePage]
class OsceRoute extends PageRouteInfo<OsceRouteArgs> {
  OsceRoute({
    Key? key,
    required SimpleOsce simpleOsce,
    List<PageRouteInfo>? children,
  }) : super(
         OsceRoute.name,
         args: OsceRouteArgs(key: key, simpleOsce: simpleOsce),
         initialChildren: children,
       );

  static const String name = 'OsceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OsceRouteArgs>();
      return OscePage(key: args.key, simpleOsce: args.simpleOsce);
    },
  );
}

class OsceRouteArgs {
  const OsceRouteArgs({this.key, required this.simpleOsce});

  final Key? key;

  final SimpleOsce simpleOsce;

  @override
  String toString() {
    return 'OsceRouteArgs{key: $key, simpleOsce: $simpleOsce}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OsceRouteArgs) return false;
    return key == other.key && simpleOsce == other.simpleOsce;
  }

  @override
  int get hashCode => key.hashCode ^ simpleOsce.hashCode;
}

/// generated route for
/// [OscePerformancesPage]
class OscePerformancesRoute extends PageRouteInfo<void> {
  const OscePerformancesRoute({List<PageRouteInfo>? children})
    : super(OscePerformancesRoute.name, initialChildren: children);

  static const String name = 'OscePerformancesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OscePerformancesPage();
    },
  );
}

/// generated route for
/// [OsceSubmitPage]
class OsceSubmitRoute extends PageRouteInfo<OsceSubmitRouteArgs> {
  OsceSubmitRoute({
    Key? key,
    required Osce submittedOsce,
    List<PageRouteInfo>? children,
  }) : super(
         OsceSubmitRoute.name,
         args: OsceSubmitRouteArgs(key: key, submittedOsce: submittedOsce),
         initialChildren: children,
       );

  static const String name = 'OsceSubmitRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OsceSubmitRouteArgs>();
      return OsceSubmitPage(key: args.key, submittedOsce: args.submittedOsce);
    },
  );
}

class OsceSubmitRouteArgs {
  const OsceSubmitRouteArgs({this.key, required this.submittedOsce});

  final Key? key;

  final Osce submittedOsce;

  @override
  String toString() {
    return 'OsceSubmitRouteArgs{key: $key, submittedOsce: $submittedOsce}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OsceSubmitRouteArgs) return false;
    return key == other.key && submittedOsce == other.submittedOsce;
  }

  @override
  int get hashCode => key.hashCode ^ submittedOsce.hashCode;
}

/// generated route for
/// [OsceTutorialPage]
class OsceTutorialRoute extends PageRouteInfo<OsceTutorialRouteArgs> {
  OsceTutorialRoute({
    Key? key,
    VoidCallback? onFinish,
    List<PageRouteInfo>? children,
  }) : super(
         OsceTutorialRoute.name,
         args: OsceTutorialRouteArgs(key: key, onFinish: onFinish),
         initialChildren: children,
       );

  static const String name = 'OsceTutorialRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OsceTutorialRouteArgs>(
        orElse: () => const OsceTutorialRouteArgs(),
      );
      return OsceTutorialPage(key: args.key, onFinish: args.onFinish);
    },
  );
}

class OsceTutorialRouteArgs {
  const OsceTutorialRouteArgs({this.key, this.onFinish});

  final Key? key;

  final VoidCallback? onFinish;

  @override
  String toString() {
    return 'OsceTutorialRouteArgs{key: $key, onFinish: $onFinish}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OsceTutorialRouteArgs) return false;
    return key == other.key && onFinish == other.onFinish;
  }

  @override
  int get hashCode => key.hashCode ^ onFinish.hashCode;
}

/// generated route for
/// [PackFinishedPage]
class PackFinishedRoute extends PageRouteInfo<PackFinishedRouteArgs> {
  PackFinishedRoute({
    Key? key,
    required TestType testType,
    List<PageRouteInfo>? children,
  }) : super(
         PackFinishedRoute.name,
         args: PackFinishedRouteArgs(key: key, testType: testType),
         initialChildren: children,
       );

  static const String name = 'PackFinishedRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PackFinishedRouteArgs>();
      return PackFinishedPage(key: args.key, testType: args.testType);
    },
  );
}

class PackFinishedRouteArgs {
  const PackFinishedRouteArgs({this.key, required this.testType});

  final Key? key;

  final TestType testType;

  @override
  String toString() {
    return 'PackFinishedRouteArgs{key: $key, testType: $testType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PackFinishedRouteArgs) return false;
    return key == other.key && testType == other.testType;
  }

  @override
  int get hashCode => key.hashCode ^ testType.hashCode;
}

/// generated route for
/// [PackSearchPage]
class PackSearchRoute extends PageRouteInfo<void> {
  const PackSearchRoute({List<PageRouteInfo>? children})
    : super(PackSearchRoute.name, initialChildren: children);

  static const String name = 'PackSearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PackSearchPage();
    },
  );
}

/// generated route for
/// [PackSelectionPage]
class PackSelectionRoute extends PageRouteInfo<void> {
  const PackSelectionRoute({List<PageRouteInfo>? children})
    : super(PackSelectionRoute.name, initialChildren: children);

  static const String name = 'PackSelectionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PackSelectionPage();
    },
  );
}

/// generated route for
/// [PacksPage]
class PacksRoute extends PageRouteInfo<void> {
  const PacksRoute({List<PageRouteInfo>? children})
    : super(PacksRoute.name, initialChildren: children);

  static const String name = 'PacksRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PacksPage();
    },
  );
}

/// generated route for
/// [PacksTabPage]
class PacksTabRoute extends PageRouteInfo<void> {
  const PacksTabRoute({List<PageRouteInfo>? children})
    : super(PacksTabRoute.name, initialChildren: children);

  static const String name = 'PacksTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PacksTabPage();
    },
  );
}

/// generated route for
/// [PermissionDeniedPage]
class PermissionDeniedRoute extends PageRouteInfo<void> {
  const PermissionDeniedRoute({List<PageRouteInfo>? children})
    : super(PermissionDeniedRoute.name, initialChildren: children);

  static const String name = 'PermissionDeniedRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PermissionDeniedPage();
    },
  );
}

/// generated route for
/// [PersonalInformationPage]
class PersonalInformationRoute extends PageRouteInfo<void> {
  const PersonalInformationRoute({List<PageRouteInfo>? children})
    : super(PersonalInformationRoute.name, initialChildren: children);

  static const String name = 'PersonalInformationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PersonalInformationPage();
    },
  );
}

/// generated route for
/// [PreviousSessionsPage]
class PreviousSessionsRoute extends PageRouteInfo<void> {
  const PreviousSessionsRoute({List<PageRouteInfo>? children})
    : super(PreviousSessionsRoute.name, initialChildren: children);

  static const String name = 'PreviousSessionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PreviousSessionsPage();
    },
  );
}

/// generated route for
/// [PrivacyPolicyPage]
class PrivacyPolicyRoute extends PageRouteInfo<void> {
  const PrivacyPolicyRoute({List<PageRouteInfo>? children})
    : super(PrivacyPolicyRoute.name, initialChildren: children);

  static const String name = 'PrivacyPolicyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PrivacyPolicyPage();
    },
  );
}

/// generated route for
/// [PrivacySecurityPage]
class PrivacySecurityRoute extends PageRouteInfo<void> {
  const PrivacySecurityRoute({List<PageRouteInfo>? children})
    : super(PrivacySecurityRoute.name, initialChildren: children);

  static const String name = 'PrivacySecurityRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PrivacySecurityPage();
    },
  );
}

/// generated route for
/// [ProdPaywallPage]
class ProdPaywallRoute extends PageRouteInfo<void> {
  const ProdPaywallRoute({List<PageRouteInfo>? children})
    : super(ProdPaywallRoute.name, initialChildren: children);

  static const String name = 'ProdPaywallRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProdPaywallPage();
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
}

/// generated route for
/// [QuestionEditorPage]
class QuestionEditorRoute extends PageRouteInfo<QuestionEditorRouteArgs> {
  QuestionEditorRoute({
    Key? key,
    required String osceId,
    List<PageRouteInfo>? children,
  }) : super(
         QuestionEditorRoute.name,
         args: QuestionEditorRouteArgs(key: key, osceId: osceId),
         initialChildren: children,
       );

  static const String name = 'QuestionEditorRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<QuestionEditorRouteArgs>();
      return QuestionEditorPage(key: args.key, osceId: args.osceId);
    },
  );
}

class QuestionEditorRouteArgs {
  const QuestionEditorRouteArgs({this.key, required this.osceId});

  final Key? key;

  final String osceId;

  @override
  String toString() {
    return 'QuestionEditorRouteArgs{key: $key, osceId: $osceId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QuestionEditorRouteArgs) return false;
    return key == other.key && osceId == other.osceId;
  }

  @override
  int get hashCode => key.hashCode ^ osceId.hashCode;
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterPage();
    },
  );
}

/// generated route for
/// [ReportFlashcardPage]
class ReportFlashcardRoute extends PageRouteInfo<ReportFlashcardRouteArgs> {
  ReportFlashcardRoute({
    Key? key,
    required Flashcard flashcard,
    required String packId,
    String? packName,
    List<PageRouteInfo>? children,
  }) : super(
         ReportFlashcardRoute.name,
         args: ReportFlashcardRouteArgs(
           key: key,
           flashcard: flashcard,
           packId: packId,
           packName: packName,
         ),
         initialChildren: children,
       );

  static const String name = 'ReportFlashcardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReportFlashcardRouteArgs>();
      return ReportFlashcardPage(
        key: args.key,
        flashcard: args.flashcard,
        packId: args.packId,
        packName: args.packName,
      );
    },
  );
}

class ReportFlashcardRouteArgs {
  const ReportFlashcardRouteArgs({
    this.key,
    required this.flashcard,
    required this.packId,
    this.packName,
  });

  final Key? key;

  final Flashcard flashcard;

  final String packId;

  final String? packName;

  @override
  String toString() {
    return 'ReportFlashcardRouteArgs{key: $key, flashcard: $flashcard, packId: $packId, packName: $packName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReportFlashcardRouteArgs) return false;
    return key == other.key &&
        flashcard == other.flashcard &&
        packId == other.packId &&
        packName == other.packName;
  }

  @override
  int get hashCode =>
      key.hashCode ^ flashcard.hashCode ^ packId.hashCode ^ packName.hashCode;
}

/// generated route for
/// [ReviewBookmarkPage]
class ReviewBookmarkRoute extends PageRouteInfo<void> {
  const ReviewBookmarkRoute({List<PageRouteInfo>? children})
    : super(ReviewBookmarkRoute.name, initialChildren: children);

  static const String name = 'ReviewBookmarkRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ReviewBookmarkPage();
    },
  );
}

/// generated route for
/// [SignOutHandlerWrapperPage]
class SignOutHandlerWrapperRoute extends PageRouteInfo<void> {
  const SignOutHandlerWrapperRoute({List<PageRouteInfo>? children})
    : super(SignOutHandlerWrapperRoute.name, initialChildren: children);

  static const String name = 'SignOutHandlerWrapperRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return WrappedRoute(child: const SignOutHandlerWrapperPage());
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPage();
    },
  );
}

/// generated route for
/// [StartedPacksPage]
class StartedPacksRoute extends PageRouteInfo<void> {
  const StartedPacksRoute({List<PageRouteInfo>? children})
    : super(StartedPacksRoute.name, initialChildren: children);

  static const String name = 'StartedPacksRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StartedPacksPage();
    },
  );
}

/// generated route for
/// [StatsPage]
class StatsRoute extends PageRouteInfo<void> {
  const StatsRoute({List<PageRouteInfo>? children})
    : super(StatsRoute.name, initialChildren: children);

  static const String name = 'StatsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StatsPage();
    },
  );
}

/// generated route for
/// [UpdateCardsPerSessionPage]
class UpdateCardsPerSessionRoute extends PageRouteInfo<void> {
  const UpdateCardsPerSessionRoute({List<PageRouteInfo>? children})
    : super(UpdateCardsPerSessionRoute.name, initialChildren: children);

  static const String name = 'UpdateCardsPerSessionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UpdateCardsPerSessionPage();
    },
  );
}

/// generated route for
/// [UpdateEmailSuccessfulPage]
class UpdateEmailSuccessfulRoute extends PageRouteInfo<void> {
  const UpdateEmailSuccessfulRoute({List<PageRouteInfo>? children})
    : super(UpdateEmailSuccessfulRoute.name, initialChildren: children);

  static const String name = 'UpdateEmailSuccessfulRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UpdateEmailSuccessfulPage();
    },
  );
}

/// generated route for
/// [UpdatePasswordPage]
class UpdatePasswordRoute extends PageRouteInfo<void> {
  const UpdatePasswordRoute({List<PageRouteInfo>? children})
    : super(UpdatePasswordRoute.name, initialChildren: children);

  static const String name = 'UpdatePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UpdatePasswordPage();
    },
  );
}

/// generated route for
/// [VerifyEmailPage]
class VerifyEmailRoute extends PageRouteInfo<void> {
  const VerifyEmailRoute({List<PageRouteInfo>? children})
    : super(VerifyEmailRoute.name, initialChildren: children);

  static const String name = 'VerifyEmailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const VerifyEmailPage();
    },
  );
}
