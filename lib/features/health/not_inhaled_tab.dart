import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/widgets/cards.dart';
import '../../app/widgets/metric_text.dart';
import '../../content/content.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';
import 'health_common.dart';

/// Average puffs per cigarette (Pennsylvania Adult Smoking Study, Drug Alcohol Depend 2018).
const _puffsPerCigarette = 12;

/// IQOS stops heating a stick after 14 puffs or 6 minutes: upper bounds for heated sticks.
const _maxPuffsPerStick = 14;
const _maxMinutesPerStick = 6;

/// Our own rough estimate of one smoke break (stated as such in the UI).
const _minutesPerCigarette = 5;

/// «Не вдохнули»: units, packs, puffs and smoke-break time avoided, plus what is no longer breathed in.
class NotInhaledTab extends ConsumerWidget {
  const NotInhaledTab({super.key});

  static IconData _productIcon(ProductType t) => switch (t) {
    ProductType.cigarettes => Icons.smoke_free,
    ProductType.sticks => Icons.whatshot_outlined,
    ProductType.disposable || ProductType.liquid => Icons.vape_free,
  };

  static IconData _factIcon(String name) => switch (name) {
    'science' => Icons.science_outlined,
    'air' => Icons.air,
    'whatshot' => Icons.whatshot_outlined,
    'cloud' => Icons.cloud_outlined,
    _ => Icons.psychology_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final facts = ref.watch(contentProvider).value?.notInhaledFacts ?? const <NotInhaledFact>[];
    final attempts = ref.watch(attemptsProvider).value ?? const <Attempt>[];
    final current = attempts.where((a) => a.endedAt == null).firstOrNull;
    final products = ref.watch(productsProvider).value ?? const <SmokingProduct>[];
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final fmt = NumberFormat('#,##0', 'ru');

    if (current == null) {
      return ListView(
        padding: healthTabPadding,
        children: [Text(l.notInhaledNoAttempt, style: theme.textTheme.bodyLarge)],
      );
    }
    final mine = productsOf(products, current.id);
    final units = unitsAvoided(mine, attemptDuration(current, now));
    // Smoke-free units summed over every attempt, each with its own habits.
    final allTime = <ProductType, double>{};
    for (final a in attempts) {
      for (final e in unitsAvoided(productsOf(products, a.id), attemptDuration(a, now)).entries) {
        allTime[e.key] = (allTime[e.key] ?? 0) + e.value;
      }
    }
    final types = {for (final t in units.keys) t.name};
    final shownFacts = facts.where((f) => f.products.any(types.contains)).toList();
    final hasVape = units.keys.any((t) => t == ProductType.disposable || t == ProductType.liquid);
    final notes = <String>[
      if (units.containsKey(ProductType.cigarettes)) l.notInhaledPuffsCigNote,
      if (units.containsKey(ProductType.sticks)) l.notInhaledPuffsSticksNote,
      if (units.containsKey(ProductType.cigarettes) || units.containsKey(ProductType.sticks)) l.notInhaledTimeNote,
      if (hasVape) l.notInhaledVape,
      l.notInhaledHonest,
    ];
    final onCard = scheme.onPrimaryContainer;

    return ListView(
      padding: healthTabPadding,
      children: [
        Text(l.notInhaledTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        // One main block for every product of the current attempt.
        AppCard(
          tone: CardTone.hero,
          child: Column(
            children: [
              for (final (i, e) in units.entries.indexed) ...[
                if (i > 0) Divider(height: 32, color: onCard.withValues(alpha: 0.2)),
                Row(
                  spacing: 16,
                  children: [
                    Icon(_productIcon(e.key), size: 36, color: onCard),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          MetricText(l.unitsAvoided(e.key.name, fmt.format(e.value.floor())), color: onCard),
                          for (final line in _details(l, fmt, e.key, e.value.floor(), mine))
                            Text(line, style: theme.textTheme.bodyMedium?.copyWith(color: onCard)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (attempts.length > 1) ...[
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(l.notInhaledAllTime, style: theme.textTheme.titleMedium),
                for (final e in allTime.entries)
                  Text(
                    [
                      l.unitsAvoided(e.key.name, fmt.format(e.value.floor())),
                      if (e.key == ProductType.cigarettes || e.key == ProductType.sticks)
                        _puffs(l, fmt, e.key, e.value.floor()),
                    ].join(' · '),
                    style: theme.textTheme.bodyLarge,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (shownFacts.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(l.notInhaledWhat, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final f in shownFacts) ...[_FactCard(fact: f, icon: _factIcon(f.icon)), const SizedBox(height: 12)],
        ],
        const SizedBox(height: 4),
        for (final n in notes) ...[HealthDisclaimer(text: n), const SizedBox(height: 8)],
      ],
    );
  }

  /// Packs, puffs and smoke-break time for [units] of product [t].
  static List<String> _details(
    AppLocalizations l,
    NumberFormat fmt,
    ProductType t,
    int units,
    List<SmokingProduct> mine,
  ) {
    final perPack = mine.where((p) => p.type == t).firstOrNull?.unitsPerPack ?? 1;
    final minutes = switch (t) {
      ProductType.cigarettes => units * _minutesPerCigarette,
      ProductType.sticks => units * _maxMinutesPerStick,
      _ => 0,
    };
    return [
      if (perPack > 1) l.notInhaledPacks(fmt.format(units ~/ perPack), units ~/ perPack),
      if (t == ProductType.cigarettes || t == ProductType.sticks) _puffs(l, fmt, t, units),
      if (minutes > 0) l.notInhaledTime(minutes >= 60 ? l.durHours(minutes ~/ 60) : l.durMinutes(minutes)),
    ];
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

class _FactCard extends StatelessWidget {
  const _FactCard({required this.fact, required this.icon});

  final NotInhaledFact fact;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 12,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: scheme.secondaryContainer,
                child: Icon(icon, color: scheme.onSecondaryContainer),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${fact.value} ',
                        style: theme.textTheme.titleLarge?.copyWith(color: scheme.primary),
                      ),
                      TextSpan(text: fact.title, style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(fact.text, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(l.healthSource(fact.source), style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
