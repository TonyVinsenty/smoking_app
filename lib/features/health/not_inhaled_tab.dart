import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';
import 'health_common.dart';

/// Average puffs per cigarette (Pennsylvania Adult Smoking Study, Drug Alcohol Depend 2018).
const _puffsPerCigarette = 12;

/// IQOS stops heating a stick after 14 puffs: an upper bound for heated sticks.
const _maxPuffsPerStick = 14;

/// «Не попало в организм»: units not used and puffs not taken during the current attempt.
class NotInhaledTab extends ConsumerWidget {
  const NotInhaledTab({super.key});

  static IconData _icon(ProductType t) => switch (t) {
    ProductType.cigarettes => Icons.smoke_free,
    ProductType.sticks => Icons.whatshot_outlined,
    ProductType.disposable || ProductType.liquid => Icons.cloud_off_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = ref.watch(currentAttemptProvider).value;
    final products = ref.watch(productsProvider).value ?? const [];
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final fmt = NumberFormat('#,##0', 'ru');

    if (current == null) {
      return ListView(
        padding: healthTabPadding,
        children: [Text(l.notInhaledNoAttempt, style: theme.textTheme.bodyLarge)],
      );
    }
    final units = unitsAvoided(productsOf(products, current.id), attemptDuration(current, now));
    final hasVape = units.keys.any((t) => t == ProductType.disposable || t == ProductType.liquid);
    final notes = <String>[
      if (units.containsKey(ProductType.cigarettes)) l.notInhaledPuffsCigNote,
      if (units.containsKey(ProductType.sticks)) l.notInhaledPuffsSticksNote,
      if (hasVape) l.notInhaledVape,
      l.notInhaledHonest,
    ];

    return ListView(
      padding: healthTabPadding,
      children: [
        Text(l.notInhaledTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final e in units.entries) ...[
          Card(
            color: scheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                spacing: 16,
                children: [
                  Icon(_icon(e.key), size: 36, color: scheme.onPrimaryContainer),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.unitsAvoided(e.key.name, fmt.format(e.value.floor())),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (e.key == ProductType.cigarettes || e.key == ProductType.sticks) ...[
                          const SizedBox(height: 4),
                          Text(
                            _puffs(l, fmt, e.key, e.value.floor()),
                            style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onPrimaryContainer),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        for (final n in notes) ...[HealthDisclaimer(text: n), const SizedBox(height: 8)],
      ],
    );
  }

  static String _puffs(AppLocalizations l, NumberFormat fmt, ProductType t, int units) {
    if (t == ProductType.cigarettes) {
      final n = units * _puffsPerCigarette;
      return l.notInhaledPuffsCig(fmt.format(n), n);
    }
    final n = units * _maxPuffsPerStick;
    return l.notInhaledPuffsSticks(fmt.format(n), n);
  }
}
