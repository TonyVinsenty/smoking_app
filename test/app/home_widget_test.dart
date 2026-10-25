import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smoking_app/app/home_widget.dart';
import 'package:smoking_app/app/theme.dart';
import 'package:smoking_app/data/database.dart';
import 'package:smoking_app/l10n/app_localizations.dart';

void main() {
  final l = lookupAppLocalizations(const Locale('ru'));

  test('the widgets get rates, word forms and both colour sets of the chosen theme', () {
    final start = DateTime(2026, 10, 1, 8);
    final payload = homeWidgetPayload(
      l: l,
      attempt: Attempt(id: 1, startedAt: start),
      products: const [
        SmokingProduct(
          id: 1,
          type: ProductType.cigarettes,
          amount: 20,
          period: ConsumptionPeriod.day,
          unitsPerPack: 20,
          packPrice: 200,
        ),
      ],
      palette: AppPalette.ocean,
    );
    expect(payload['start'], start.millisecondsSinceEpoch);
    expect(payload['moneyPerDay'], 200);
    expect(payload['unitsPerDay'], 20);
    expect(payload['days'], {'one': 'день', 'few': 'дня', 'many': 'дней', 'other': 'дня'});
    expect((payload['units']! as Map)['many'], '{n} сиг.');
    expect(payload['clock'], '{h} ч {m} мин');
    expect(payload['money'], '{n} ₽');
    final light = payload['light']! as Map<String, int>;
    final dark = payload['dark']! as Map<String, int>;
    expect(light['reward'], AppPalette.ocean.lightColors.reward.toARGB32());
    expect(dark['reward'], AppPalette.ocean.darkColors.reward.toARGB32());
    expect(light['card'], isNot(dark['card']));
  });

  test('between attempts the widgets show no time and count nothing', () {
    final payload = homeWidgetPayload(l: l, attempt: null, products: const [], palette: AppPalette.mint);
    expect(payload['start'], isNull);
    expect(payload['moneyPerDay'], 0);
    expect(payload['unitsPerDay'], 0);
  });
}
