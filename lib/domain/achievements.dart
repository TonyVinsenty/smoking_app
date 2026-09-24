import '../content/content.dart';
import '../data/database.dart';
import 'stats.dart';

/// Achievements whose condition is met now but which are not unlocked yet.
///
/// Time-based badges belong to an attempt and are earned again in each new attempt
/// (they stay in the attempt history); all other badges are cumulative and earned once.
List<Achievement> dueAchievements({
  required List<Achievement> achievements,
  required List<Attempt> attempts,
  required List<SmokingProduct> products,
  required List<Craving> cravings,
  required int articlesRead,
  required List<UnlockedAchievement> unlocked,
  required DateTime now,
}) {
  final current = attempts.where((a) => a.endedAt == null).firstOrNull;
  if (current == null) return [];
  final everUnlocked = unlocked.map((u) => u.achievementId).toSet();
  final unlockedNow = unlocked.where((u) => u.attemptId == current.id).map((u) => u.achievementId).toSet();
  final money = attempts.fold<double>(0, (sum, a) => sum + moneySaved(products, attemptDuration(a, now)));

  num? progress(Achievement a) => switch (a.conditionType) {
    'smokeFreeMinutes' => attemptDuration(current, now).inMinutes,
    'moneySavedRub' => money,
    'cravingsResisted' => cravings.where((c) => c.resisted).length,
    'articlesRead' => articlesRead,
    'attemptsStarted' => attempts.length,
    'comebackAfterRelapse' => attempts.length - 1,
    _ => null,
  };

  return [
    for (final a in achievements)
      if (!(a.conditionType == 'smokeFreeMinutes' ? unlockedNow : everUnlocked).contains(a.id) &&
          (progress(a) ?? -1) >= a.conditionValue)
        a,
  ];
}
