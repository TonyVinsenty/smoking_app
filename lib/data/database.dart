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

/// Why the user smoked (asked after «Я закурил»).
enum RelapseTrigger { stress, alcohol, company, coffee, afterMeal, boredom, ritual, other }

class SmokingProducts extends Table {
  IntColumn get id => integer().autoIncrement()();
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
  TextColumn get trigger => textEnum<RelapseTrigger>().nullable()();
  TextColumn get note => text().nullable()();
}

class Cravings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get attemptId => integer().references(Attempts, #id)();
  DateTimeColumn get at => dateTime()();
  BoolColumn get resisted => boolean()();
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

@DriftDatabase(tables: [SmokingProducts, Attempts, Cravings, UnlockedAchievements, ArticlesRead])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'smoking_app'));

  @override
  int get schemaVersion => 1;

  /// Saves onboarding answers and starts the first attempt.
  Future<void> completeOnboarding(List<SmokingProductsCompanion> products, DateTime startedAt) =>
      transaction(() async {
        await delete(smokingProducts).go();
        await batch((b) => b.insertAll(smokingProducts, products));
        await startAttempt(startedAt);
      });

  Future<int> startAttempt(DateTime startedAt) =>
      into(attempts).insert(AttemptsCompanion.insert(startedAt: startedAt));

  /// Wipes all user data («Полный сброс»).
  Future<void> resetAll() => transaction(() async {
        for (final table in allTables.toList().reversed) {
          await delete(table).go();
        }
      });
}
