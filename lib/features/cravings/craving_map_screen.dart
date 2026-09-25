import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../content/content.dart';
import '../../data/providers.dart';
import '../../domain/craving_stats.dart';
import '../../l10n/app_localizations.dart';

enum _Period { week, month, all }

/// «Карта тяги»: when and why the user craves, and how often they resisted.
class CravingMapScreen extends ConsumerStatefulWidget {
  const CravingMapScreen({super.key});

  @override
  ConsumerState<CravingMapScreen> createState() => _CravingMapScreenState();
}

class _CravingMapScreenState extends ConsumerState<CravingMapScreen> {
  _Period _period = _Period.all;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cravings = ref.watch(cravingsProvider).value ?? const [];
    final tips = ref.watch(contentProvider).value?.triggerTips ?? const {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = switch (_period) {
      _Period.week => today.subtract(const Duration(days: 6)),
      _Period.month => today.subtract(const Duration(days: 29)),
      _Period.all => null,
    };
    final s = CravingStats(cravings, from: from);
    final top = s.topTrigger;
    final tip = top == null ? null : tips[top.name];

    return Scaffold(
      appBar: AppBar(title: Text(l.cravingTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SegmentedButton<_Period>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: _Period.week, label: Text(l.cravingPeriodWeek)),
              ButtonSegment(value: _Period.month, label: Text(l.cravingPeriodMonth)),
              ButtonSegment(value: _Period.all, label: Text(l.cravingPeriodAll)),
            ],
            selected: {_period},
            onSelectionChanged: (v) => setState(() => _period = v.first),
          ),
          const SizedBox(height: 16),
          if (s.isEmpty)
            Card(
              color: theme.colorScheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(l.cravingNoData, style: theme.textTheme.bodyLarge),
              ),
            )
          else ...[
            _SummaryCard(count: s.summary),
            const SizedBox(height: 12),
            _Section(
              title: l.cravingTimeOfDay,
              subtitle: s.peakHour == null
                  ? null
                  : l.cravingPeakHour(
                      s.peakHour!.toString().padLeft(2, '0'),
                      ((s.peakHour! + 1) % 24).toString().padLeft(2, '0'),
                    ),
              child: _Columns(
                items: [
                  for (final p in DayPart.values) (l.dayPartName(p.name), l.dayPartHours(p.name), s.byPart[p]!),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: l.cravingTriggers,
              child: Column(
                children: [
                  for (final e in s.triggersSorted)
                    _Row(
                      label: e.key == null ? l.cravingNoTrigger : l.triggerName(e.key!.name),
                      count: e.value,
                      max: s.triggersSorted.first.value.total,
                    ),
                ],
              ),
            ),
            if (tip != null) ...[
              const SizedBox(height: 12),
              Card(
                color: theme.colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: theme.colorScheme.onSecondaryContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l.cravingTipTitle(l.triggerName(top!.name)),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tip,
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _Section(
              title: l.cravingWeekdays,
              child: _Columns(
                items: [
                  for (var i = 0; i < 7; i++)
                    // 1 January 2024 is a Monday.
                    (DateFormat.E('ru').format(DateTime(2024, 1, 1 + i)), null, s.byWeekday[i]),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(l.cravingSource, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.count});

  final CravingCount count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimaryContainer;
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${count.resisted}',
                  style: theme.textTheme.displayMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(l.cravingOfTotal(count.total), style: theme.textTheme.titleLarge?.copyWith(color: color)),
              ],
            ),
            Text(l.cravingSummary(count.resisted), style: theme.textTheme.titleMedium?.copyWith(color: color)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: count.resisted / count.total,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.subtitle, required this.child});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            child,
            const SizedBox(height: 12),
            const _Legend(),
          ],
        ),
      ),
    );
  }
}

/// Bar split in two: resisted (primary) and smoked (muted).
class _SplitBar extends StatelessWidget {
  const _SplitBar({required this.count, required this.vertical});

  final CravingCount count;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final parts = [
      (count.total - count.resisted, scheme.outline),
      (count.resisted, scheme.primary),
    ];
    final children = [
      for (final (n, color) in vertical ? parts : parts.reversed)
        if (n > 0) Expanded(flex: n, child: Container(color: color)),
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: vertical ? Column(children: children) : Row(children: children),
    );
  }
}

/// Vertical bars in a row (parts of the day, weekdays).
class _Columns extends StatelessWidget {
  const _Columns({required this.items});

  final List<(String label, String? hint, CravingCount count)> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const height = 120.0;
    final max = items.fold(1, (m, e) => e.$3.total > m ? e.$3.total : m);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final (label, hint, count) in items)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Text('${count.total}', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: height,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: count.total == 0
                          ? Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.outlineVariant,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )
                          : SizedBox(
                              height: height * count.total / max,
                              width: double.infinity,
                              child: _SplitBar(count: count, vertical: true),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(label, style: theme.textTheme.labelLarge, maxLines: 1, overflow: TextOverflow.fade),
                  if (hint != null)
                    Text(
                      hint,
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                      maxLines: 1,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Horizontal bar with a label (triggers).
class _Row extends StatelessWidget {
  const _Row({required this.label, required this.count, required this.max});

  final String label;
  final CravingCount count;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
              Text('${count.total}', style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 4),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: count.total / max,
            child: SizedBox(height: 12, child: _SplitBar(count: count, vertical: false)),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    Widget item(Color color, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );
    return Wrap(
      spacing: 16,
      children: [
        item(theme.colorScheme.primary, l.cravingLegendResisted),
        item(theme.colorScheme.outline, l.cravingLegendSmoked),
      ],
    );
  }
}
