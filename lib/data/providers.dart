import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

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
