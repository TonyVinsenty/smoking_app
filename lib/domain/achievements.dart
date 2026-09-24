import '../content/content.dart';
import '../data/database.dart';
import 'stats.dart';

/// Achievements whose condition is met at [now] but which are not unlocked yet.
///
/// Time-based badges belong to an attempt and are earned again in each new attempt
/// (they stay in the attempt history); all other badges are cumulative and earned once.
/// Only events up to [now] count, so the same data can be evaluated "a few minutes ago".
List<Achievement> dueAchievements({
  required List<Achievement> achievements,
  required List<Attempt> attempts,
  required List<SmokingProduct> products,
  required List<Craving> cravings,
  required List<DateTime> articlesReadAt,
  required List<UnlockedAchievement> unlocked,
  required DateTime now,
}) {
  attempts = attempts.where((a) => !a.startedAt.isAfter(now)).toList();
  final current = attempts.where((a) => a.endedAt == null).firstOrNull;
  if (current == null) return [];
  final everUnlocked = unlocked.map((u) => u.achievementId).toSet();
  final unlockedNow = unlocked.where((u) => u.attemptId == current.id).map((u) => u.achievementId).toSet();
  final money = attempts.fold<double>(0, (sum, a) => sum + moneySaved(products, attemptDuration(a, now)));
  final units = attempts.fold<double>(
    0,
    (sum, a) => sum + unitsAvoided(products, attemptDuration(a, now)).values.fold(0.0, (s, v) => s + v),
  );

  num? progress(Achievement a) => switch (a.conditionType) {
    'smokeFreeMinutes' => attemptDuration(current, now).inMinutes,
    'moneySavedRub' => money,
    'unitsAvoided' => units,
    'cravingsResisted' => cravings.where((c) => c.resisted && !c.at.isAfter(now)).length,
    'articlesRead' => articlesReadAt.where((t) => !t.isAfter(now)).length,
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
