import 'package:flutter/cupertino.dart';
import 'package:flashcards/l10n/app_localizations.dart';

enum EducationLevel {
  highSchoolStudent,
  graduate,
  universityStudent,
  other;

  // استخدم هذه الدالة ليعمل التعريب.
  String toLocalizedString(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    switch (this) {
      case EducationLevel.highSchoolStudent:
        return loc.highSchoolStudent;
      case EducationLevel.graduate:
        return loc.graduate;
      case EducationLevel.universityStudent:
        return loc.universityStudent;
      case EducationLevel.other:
        return loc.otherLevel;
    }
  }
}

EducationLevel educationLevelFromJson(String level) => EducationLevel.values
    .firstWhere((e) => e.name == level, orElse: () => EducationLevel.other);

String educationLevelToJson(EducationLevel level) => level.name;
