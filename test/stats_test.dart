import 'package:flutter_test/flutter_test.dart';

import 'package:smoking_app/content/content.dart';
import 'package:smoking_app/data/database.dart';
import 'package:smoking_app/domain/achievements.dart';
import 'package:smoking_app/domain/stats.dart';

void main() {
  test('money saved: 20 cigarettes a day, 200 ₽ per pack of 20', () {
    const cigs = SmokingProduct(
      id: 1,
      type: ProductType.cigarettes,
      amount: 20,
      period: ConsumptionPeriod.day,
      unitsPerPack: 20,
      packPrice: 200,
    );
    const liquid = SmokingProduct(
      id: 2,
      type: ProductType.liquid,
      amount: 1,
      period: ConsumptionPeriod.week,
      unitsPerPack: 1,
      packPrice: 700,
    );
    expect(dailyCost([cigs]), 200);
    expect(moneySaved([cigs, liquid], const Duration(days: 7)), closeTo(200 * 7 + 700, 0.001));
    expect(unitsAvoided([cigs], const Duration(days: 3))[ProductType.cigarettes], 60);
  });

  test('xp keeps smoke-free hours from ended attempts', () {
    final start = DateTime(2026, 1, 1);
    final attempts = [
      Attempt(id: 1, startedAt: start, endedAt: start.add(const Duration(hours: 10))),
      Attempt(id: 2, startedAt: start.add(const Duration(hours: 20))),
    ];
    final xp = totalXp(
      attempts: attempts,
      cravings: [Craving(id: 1, attemptId: 2, at: start, resisted: true)],
      achievementXp: const [25],
      now: start.add(const Duration(hours: 25)),
    );
    expect(xp, 10 + 5 + xpPerResistedCraving + 25);
  });

  test('units badges count the main product with its own threshold', () {
    final start = DateTime(2026, 1, 1);
    // Main product = largest spend: disposables (175 ₽/day) over a few cigarettes (28 ₽/day).
    final products = [
      SmokingProduct(
        id: 1,
        attemptId: 1,
        type: ProductType.disposable,
        amount: 1,
        period: ConsumptionPeriod.day,
        unitsPerPack: 1,
        packPrice: 175,
      ),
      SmokingProduct(
        id: 2,
        attemptId: 1,
        type: ProductType.cigarettes,
        amount: 2,
        period: ConsumptionPeriod.day,
        unitsPerPack: 20,
        packPrice: 280,
      ),
    ];
    expect(mainProduct(products), ProductType.disposable);
    final badge = Achievement.fromJson({
      'id': 'u',
      'title': '',
      'description': '',
      'icon': '',
      'tier': 'common',
      'xp': 30,
      'condition': {
        'type': 'unitsAvoided',
        'value': {'cigarettes': 10, 'sticks': 10, 'disposable': 2, 'liquid': 1},
      },
    });
    List<Achievement> dueAfter(int hours) => dueAchievements(
      achievements: [badge],
      attempts: [Attempt(id: 1, startedAt: start)],
      products: products,
      cravings: const [],
      articlesReadAt: const [],
      unlocked: const [],
      now: start.add(Duration(hours: hours)),
    );
    expect(dueAfter(47), isEmpty); // 1.96 disposables (and 3.9 cigarettes, which do not count)
    expect(dueAfter(48), [badge]);
  });
}
