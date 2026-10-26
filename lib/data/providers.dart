import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/content.dart';
import '../domain/stats.dart';
import 'database.dart';
import 'settings.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Smoking habits of all attempts; use `productsOf` to pick one attempt's.
final productsProvider = StreamProvider<List<SmokingProduct>>(
  (ref) => ref.watch(databaseProvider).select(ref.watch(databaseProvider).smokingProducts).watch(),
);

final attemptsProvider = StreamProvider<List<Attempt>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.attempts)..orderBy([(a) => OrderingTerm.desc(a.startedAt)])).watch();
});

/// The running attempt, or null if the user has not started (or just relapsed).
final currentAttemptProvider = Provider<AsyncValue<Attempt?>>(
  (ref) => ref.watch(attemptsProvider).whenData((list) => list.where((a) => a.endedAt == null).firstOrNull),
);

/// Start of the latest «С чистого листа» attempt (null = never): money, units, cravings, XP and most badges
/// count only from then on. The record, the attempt history and read articles stay.
final freshStartProvider = Provider<AsyncValue<DateTime?>>(
  (ref) => ref.watch(attemptsProvider).whenData((list) => list.where((a) => a.freshStart).firstOrNull?.startedAt),
);

final _allCravingsProvider = StreamProvider<List<Craving>>(
  (ref) => ref.watch(databaseProvider).select(ref.watch(databaseProvider).cravings).watch(),
);

/// Cravings since the latest fresh start.
final cravingsProvider = Provider<AsyncValue<List<Craving>>>((ref) {
  final since = ref.watch(freshStartProvider);
  if (!since.hasValue) return const AsyncLoading();
  return ref
      .watch(_allCravingsProvider)
      .whenData(
        (list) => [
          for (final c in list)
            if (since.value == null || !c.at.isBefore(since.value!)) c,
        ],
      );
});

/// Every badge ever earned, also before a fresh start (the attempt history shows them).
final allUnlockedAchievementsProvider = StreamProvider<List<UnlockedAchievement>>(
  (ref) => ref.watch(databaseProvider).select(ref.watch(databaseProvider).unlockedAchievements).watch(),
);

/// Badges that count now: earned in attempts since the latest fresh start, plus the ones a fresh start keeps.
/// By attempt, not by time: a fresh start may be dated back over days of the attempt it follows.
final unlockedAchievementsProvider = Provider<AsyncValue<List<UnlockedAchievement>>>((ref) {
  final attempts = ref.watch(attemptsProvider);
  final content = ref.watch(contentProvider);
  if (!attempts.hasValue || !content.hasValue) return const AsyncLoading();
  final counted = {for (final a in sinceFreshStart(attempts.value!)) a.id};
  final kept = {
    for (final a in content.value!.achievements)
      if (a.keptOnFreshStart) a.id,
  };
  return ref
      .watch(allUnlockedAchievementsProvider)
      .whenData(
        (list) => [
          for (final u in list)
            if (counted.contains(u.attemptId) || kept.contains(u.achievementId)) u,
        ],
      );
});

/// Badges earned but not opened yet: a red dot leads to them (Home → group → badge).
final newAchievementIdsProvider = Provider<Set<String>>((ref) {
  final seen = ref.watch(seenAchievementsProvider);
  final unlocked = ref.watch(unlockedAchievementsProvider).value ?? const [];
  return {
    for (final u in unlocked)
      if (u.unlockedAt.isAfter(seen.since) && !seen.ids.contains(u.achievementId)) u.achievementId,
  };
});

final articlesReadProvider = StreamProvider<List<ArticlesReadData>>(
  (ref) => ref.watch(databaseProvider).select(ref.watch(databaseProvider).articlesRead).watch(),
);

/// Current time, updated every second (drives timers).
final nowProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

/// Main product (largest spend) of the current or latest attempt: unitsAvoided badges count its units.
final mainProductProvider = Provider<ProductType?>((ref) {
  final products = ref.watch(productsProvider).value;
  final attempts = ref.watch(attemptsProvider).value;
  if (products == null || attempts == null) return null;
  return mainProduct(latestProducts(products, attempts));
});

/// Names of the product types of the current or latest attempt (null while loading): picks tips and articles.
final productTypesProvider = Provider<Set<String>?>((ref) {
  final products = ref.watch(productsProvider).value;
  final attempts = ref.watch(attemptsProvider).value;
  if (products == null || attempts == null) return null;
  return {for (final p in latestProducts(products, attempts)) p.type.name};
});

/// «Дневник самочувствия», oldest first.
final wellbeingProvider = StreamProvider<List<WellbeingEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.wellbeingEntries)..orderBy([(e) => OrderingTerm.asc(e.at)])).watch();
});

/// Red dots on «Здоровье» and «Дневник»: reminders are on and a diary entry is due.
final diaryDueProvider = Provider<bool>((ref) {
  final entries = ref.watch(wellbeingProvider).value;
  if (entries == null) return false;
  final due = ref.watch(diaryReminderProvider).dueAt(entries.lastOrNull?.at);
  final now = ref.watch(nowProvider).value ?? DateTime.now();
  return due != null && !now.isBefore(due);
});
