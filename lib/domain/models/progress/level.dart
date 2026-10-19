import 'dart:math';

/// A study level, earned with XP (see `StudyLog.xp`).
class LevelInfo {
  final int level;
  final int xp;

  /// Total XP at which [level] started and the next one starts.
  final int levelStartXp;
  final int nextLevelXp;

  const LevelInfo({
    required this.level,
    required this.xp,
    required this.levelStartXp,
    required this.nextLevelXp,
  });

  factory LevelInfo.fromXp(int xp) {
    final safeXp = max(0, xp);
    var level = 1;
    while (xpForLevel(level + 1) <= safeXp) {
      level++;
    }
    return LevelInfo(
      level: level,
      xp: safeXp,
      levelStartXp: xpForLevel(level),
      nextLevelXp: xpForLevel(level + 1),
    );
  }

  int get xpIntoLevel => xp - levelStartXp;
  int get xpToNextLevel => nextLevelXp - xp;
  double get progress =>
      (xpIntoLevel / (nextLevelXp - levelStartXp)).clamp(0.0, 1.0);

  String get title => levelTitle(level);
}

/// Total XP needed to reach [level]: 0, 100, 300, 600, 1000, … Each level
/// takes 100 XP more than the one before (about 10 more new cards).
int xpForLevel(int level) => level <= 1 ? 0 : 50 * level * (level - 1);

/// A training grade for each range of levels.
String levelTitle(int level) => switch (level) {
  < 5 => 'Medical Student',
  < 10 => 'Intern',
  < 15 => 'Junior Resident',
  < 20 => 'Senior Resident',
  < 30 => 'Fellow',
  < 40 => 'Consultant',
  _ => 'Professor',
};
