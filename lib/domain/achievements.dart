import '../content/content.dart';
import '../data/database.dart';
import 'stats.dart';

/// Current value of every achievement condition type at [now], or null without a current attempt.
/// unitsAvoided counts units of the main product (largest spend) of the current attempt, over all attempts
/// since the latest fresh start (as money does); [cravings] are expected to be filtered the same way.
/// Only events up to [now] count, so the same data can be evaluated "a few minutes ago".
Map<String, num>? conditionProgress({
  required List<Attempt> attempts,
  required List<SmokingProduct> products,
  required List<Craving> cravings,
  required List<DateTime> articlesReadAt,
  required DateTime now,
}) {
  attempts = attempts.where((a) => !a.startedAt.isAfter(now)).toList();
  final current = attempts.where((a) => a.endedAt == null).firstOrNull;
  if (current == null) return null;
  final main = mainProduct(productsOf(products, current.id));
  final counted = sinceFreshStart(attempts);
  return {
    'smokeFreeMinutes': attemptDuration(current, now).inMinutes,
    'moneySavedRub': counted.fold<double>(
      0,
      (sum, a) => sum + moneySaved(productsOf(products, a.id), attemptDuration(a, now)),
    ),
    'unitsAvoided': counted.fold<double>(
      0,
      (sum, a) => sum + (unitsAvoided(productsOf(products, a.id), attemptDuration(a, now))[main] ?? 0),
    ),
    'cravingsResisted': cravings.where((c) => c.resisted && !c.at.isAfter(now)).length,
    'articlesRead': articlesReadAt.where((t) => !t.isAfter(now)).length,
    'attemptsStarted': attempts.length,
    'comebackAfterRelapse': attempts.length - 1,
  };
}

/// Achievements whose condition is met at [now] but which are not unlocked yet.
///
/// Time-based badges belong to an attempt and are earned again in each new attempt
/// (they stay in the attempt history); all other badges are cumulative and earned once.
/// Thresholds of unitsAvoided badges are per product (the main one of the current attempt).
List<Achievement> dueAchievements({
  required List<Achievement> achievements,
  required List<Attempt> attempts,
  required List<SmokingProduct> products,
  required List<Craving> cravings,
  required List<DateTime> articlesReadAt,
  required List<UnlockedAchievement> unlocked,
  required DateTime now,
}) {
  final progress = conditionProgress(
    attempts: attempts,
    products: products,
    cravings: cravings,
    articlesReadAt: articlesReadAt,
    now: now,
  );
  final current = attempts.where((a) => a.endedAt == null && !a.startedAt.isAfter(now)).firstOrNull;
  if (progress == null || current == null) return [];
  final everUnlocked = unlocked.map((u) => u.achievementId).toSet();
  final unlockedNow = unlocked.where((u) => u.attemptId == current.id).map((u) => u.achievementId).toSet();
  final main = mainProduct(productsOf(products, current.id));
  return [
    for (final a in achievements)
      if (!(a.conditionType == 'smokeFreeMinutes' ? unlockedNow : everUnlocked).contains(a.id) &&
          (progress[a.conditionType] ?? -1) >= a.conditionValue(main?.name))
        a,
  ];
}
