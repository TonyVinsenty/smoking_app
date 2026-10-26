import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smoking_app/app/theme.dart';
import 'package:smoking_app/data/database.dart';
import 'package:smoking_app/data/providers.dart';
import 'package:smoking_app/data/settings.dart';
import 'package:smoking_app/features/achievements/achievements_screen.dart';
import 'package:smoking_app/features/cravings/craving_map_screen.dart';
import 'package:smoking_app/features/health/health_screen.dart';
import 'package:smoking_app/features/home/home_screen.dart';
import 'package:smoking_app/features/knowledge/knowledge_screen.dart';
import 'package:smoking_app/features/friends/friends_screen.dart';
import 'package:smoking_app/features/relapse/history_screen.dart';
import 'package:smoking_app/features/settings/settings_screen.dart';
import 'package:smoking_app/features/sos/sos_screen.dart';
import 'package:smoking_app/l10n/app_localizations.dart';

/// Builds every screen and health tab with realistic data, in both themes and with a normal and a very
/// large system font, and fails on any layout error (overflow, unbounded size, intrinsic problems).
void main() {
  // SOS keeps the screen on (wakelock_plus); there is no platform side in tests, so answer "done".
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger.setMockMessageHandler(
      'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
      (_) async => const StandardMessageCodec().encodeMessage(<Object?>[null]),
    );
  });

  Future<AppDatabase> seed() async {
    final db = AppDatabase(NativeDatabase.memory());
    final now = DateTime.now();
    final products = [
      SmokingProductsCompanion.insert(
        type: ProductType.cigarettes,
        amount: 10,
        period: ConsumptionPeriod.day,
        unitsPerPack: 20,
        packPrice: 250,
      ),
      SmokingProductsCompanion.insert(
        type: ProductType.disposable,
        amount: 1,
        period: ConsumptionPeriod.week,
        unitsPerPack: 1,
        packPrice: 900,
      ),
    ];
    final first = await db.startAttempt(now.subtract(const Duration(days: 40)), products);
    await db.endAttempt(attemptId: first, at: now.subtract(const Duration(days: 19)), trigger: Trigger.stress);
    final current = await db.startAttempt(now.subtract(const Duration(days: 18, hours: 2)), products);
    for (final (i, t) in [Trigger.stress, Trigger.coffee, null, Trigger.afterMeal].indexed) {
      await db
          .into(db.cravings)
          .insert(
            CravingsCompanion.insert(
              attemptId: current,
              at: now.subtract(Duration(days: i, hours: 3 * i)),
              resisted: i != 1,
              trigger: Value(t),
            ),
          );
    }
    await db.unlockAchievements(['smoke_free_1h', 'smoke_free_1d'], current);
    for (var i = 0; i < 3; i++) {
      await db
          .into(db.wellbeingEntries)
          .insert(
            WellbeingEntriesCompanion.insert(
              at: now.subtract(Duration(days: 4 - 2 * i)),
              sleep: 2 + i,
              breathing: 2 + i,
              mood: 3,
              tasteSmell: 2 + i,
            ),
          );
    }
    return db;
  }

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('all screens build (${dark ? 'dark' : 'light'}, font ×$scale)', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.reset);
        final db = await tester.runAsync(seed);
        addTearDown(db!.close);
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        Future<void> show(Widget screen) async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [databaseProvider.overrideWithValue(db), prefsProvider.overrideWithValue(prefs)],
              child: MaterialApp(
                theme: buildTheme(dark ? Brightness.dark : Brightness.light),
                locale: const Locale('ru'),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: screen,
              ),
            ),
          );
          // Streams and asset content load asynchronously; repeating animations never settle.
          for (var i = 0; i < 6; i++) {
            await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
            await tester.pump(const Duration(milliseconds: 300));
          }
          expect(tester.takeException(), isNull, reason: '$screen');
        }

        for (final screen in const [
          HomeScreen(),
          KnowledgeScreen(),
          FriendsScreen(),
          SettingsScreen(),
          AchievementsScreen(),
          CravingMapScreen(),
          HistoryScreen(),
          SosScreen(),
        ]) {
          await show(screen);
        }

        await show(const HealthScreen());
        final controller = DefaultTabController.of(tester.element(find.byType(TabBarView)));
        for (var i = 1; i < controller.length; i++) {
          controller.index = i;
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull, reason: 'health tab $i');
        }

        await tester.pumpWidget(const SizedBox());
        await tester.pump(Duration.zero);
      });
    }
  }
}
