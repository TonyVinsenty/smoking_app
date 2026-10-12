import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final cravingsProvider = StreamProvider<List<Craving>>(
  (ref) => ref.watch(databaseProvider).select(ref.watch(databaseProvider).cravings).watch(),
);

final unlockedAchievementsProvider = StreamProvider<List<UnlockedAchievement>>(
  (ref) => ref.watch(databaseProvider).select(ref.watch(databaseProvider).unlockedAchievements).watch(),
);

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
