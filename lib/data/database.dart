import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// What the user used to smoke: cigarettes, heated sticks, disposable vapes, vape liquid.
enum ProductType { cigarettes, sticks, disposable, liquid }

/// Period for which [SmokingProducts.amount] is given.
enum ConsumptionPeriod { day, week, month }

extension ConsumptionPeriodDays on ConsumptionPeriod {
  double get days => switch (this) {
    ConsumptionPeriod.day => 1,
    ConsumptionPeriod.week => 7,
    ConsumptionPeriod.month => 30.44,
  };
}

/// What provoked a craving (SOS) or a relapse («Я закурил»).
enum Trigger { stress, alcohol, company, coffee, afterMeal, boredom, ritual, other }

class SmokingProducts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The attempt these smoking habits belong to: each attempt keeps its own products, so a switch
  /// (e.g. sticks → cigarettes) after a relapse does not change the savings of earlier attempts.
  /// Nullable only because SQLite cannot add a NOT NULL column; always set.
  IntColumn get attemptId => integer().nullable().references(Attempts, #id)();
  TextColumn get type => textEnum<ProductType>()();

  /// Units consumed per [period]: cigarettes/sticks, devices, or bottles.
  RealColumn get amount => real()();
  TextColumn get period => textEnum<ConsumptionPeriod>()();

  /// Units in one purchased pack (20 cigarettes; 1 for a disposable or a bottle).
  IntColumn get unitsPerPack => integer()();
  RealColumn get packPrice => real()();
}

class Attempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get trigger => textEnum<Trigger>().nullable()();

  // "No-guilt diary" answers after a relapse, all optional.
  TextColumn get whatHappened => text().nullable()();
  TextColumn get whatWouldHelp => text().nullable()();
  TextColumn get nextTime => text().nullable()();
}

class Cravings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get attemptId => integer().references(Attempts, #id)();
  DateTimeColumn get at => dateTime()();
  BoolColumn get resisted => boolean()();
  TextColumn get trigger => textEnum<Trigger>().nullable()();
}

class UnlockedAchievements extends Table {
  TextColumn get achievementId => text()();
  IntColumn get attemptId => integer().references(Attempts, #id)();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {achievementId, attemptId};
}

class ArticlesRead extends Table {
  TextColumn get articleId => text()();
  DateTimeColumn get readAt => dateTime()();

  @override
  Set<Column> get primaryKey => {articleId};
}

@DriftDatabase(tables: [Attempts, SmokingProducts, Cravings, UnlockedAchievements, ArticlesRead])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'smoking_app'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Products become per attempt: every existing attempt gets a copy of the old shared settings.
        await m.addColumn(smokingProducts, smokingProducts.attemptId);
        await customStatement(
          'INSERT INTO smoking_products (type, amount, period, units_per_pack, pack_price, attempt_id) '
          'SELECT p.type, p.amount, p.period, p.units_per_pack, p.pack_price, a.id '
          'FROM smoking_products p CROSS JOIN attempts a WHERE p.attempt_id IS NULL',
        );
        await customStatement('DELETE FROM smoking_products WHERE attempt_id IS NULL');
      }
    },
  );

  /// Saves onboarding answers and starts the first attempt.
  Future<void> completeOnboarding(List<SmokingProductsCompanion> products, DateTime startedAt) => transaction(() async {
    await delete(smokingProducts).go();
    await startAttempt(startedAt, products);
  });

  /// Starts a new attempt with its own smoking habits (a copy of the previous ones, or edited).
  Future<int> startAttempt(DateTime startedAt, List<SmokingProductsCompanion> products) => transaction(() async {
    final id = await into(attempts).insert(AttemptsCompanion.insert(startedAt: startedAt));
    await batch(
      (b) => b.insertAll(smokingProducts, [for (final p in products) p.copyWith(id: const Value.absent(), attemptId: Value(id))]),
    );
    return id;
  });

  /// Replaces the smoking habits of attempt [attemptId] (e.g. «Мои данные»).
  Future<void> replaceProducts(int attemptId, List<SmokingProductsCompanion> products) => transaction(() async {
    await (delete(smokingProducts)..where((p) => p.attemptId.equals(attemptId))).go();
    await batch(
      (b) => b.insertAll(smokingProducts, [for (final p in products) p.copyWith(id: const Value.absent(), attemptId: Value(attemptId))]),
    );
  });

  /// «Я закурил»: ends the attempt with the no-guilt diary. The relapse is also logged as a craving
  /// that was not resisted, so it shows up in the craving map.
  Future<void> endAttempt({
    required int attemptId,
    required DateTime at,
    Trigger? trigger,
    String? whatHappened,
    String? whatWouldHelp,
    String? nextTime,
  }) => transaction(() async {
    await (update(attempts)..where((a) => a.id.equals(attemptId))).write(
      AttemptsCompanion(
        endedAt: Value(at),
        trigger: Value(trigger),
        whatHappened: Value(whatHappened),
        whatWouldHelp: Value(whatWouldHelp),
        nextTime: Value(nextTime),
      ),
    );
    await into(cravings)
        .insert(CravingsCompanion.insert(attemptId: attemptId, at: at, resisted: false, trigger: Value(trigger)));
  });

  Future<void> logCraving({required int attemptId, required bool resisted, Trigger? trigger}) => into(cravings).insert(
    CravingsCompanion.insert(attemptId: attemptId, at: DateTime.now(), resisted: resisted, trigger: Value(trigger)),
  );

  Future<void> unlockAchievements(Iterable<String> ids, int attemptId) {
    final at = DateTime.now();
    return batch(
      (b) => b.insertAll(unlockedAchievements, [
        for (final id in ids)
          UnlockedAchievementsCompanion.insert(achievementId: id, attemptId: attemptId, unlockedAt: at),
      ], mode: InsertMode.insertOrIgnore),
    );
  }

  /// Wipes all user data («Полный сброс»).
  Future<void> resetAll() => transaction(() async {
    for (final table in allTables.toList().reversed) {
      await delete(table).go();
    }
  });
}
