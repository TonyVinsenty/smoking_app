import 'package:flutter_test/flutter_test.dart';

import 'package:smoking_app/data/database.dart';
import 'package:smoking_app/domain/stats.dart';

void main() {
  test('money saved: 20 cigarettes a day, 200 ₽ per pack of 20', () {
    const cigs = SmokingProduct(
        id: 1, type: ProductType.cigarettes, amount: 20, period: ConsumptionPeriod.day, unitsPerPack: 20, packPrice: 200);
    const liquid = SmokingProduct(
        id: 2, type: ProductType.liquid, amount: 1, period: ConsumptionPeriod.week, unitsPerPack: 1, packPrice: 700);
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
}
