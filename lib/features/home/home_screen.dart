import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../content/content.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final content = ref.watch(contentProvider).value;
    final attempts = ref.watch(attemptsProvider).value;
    final products = ref.watch(productsProvider).value;
    final cravings = ref.watch(cravingsProvider).value;
    final unlocked = ref.watch(unlockedAchievementsProvider).value;
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    if (content == null || attempts == null || products == null || cravings == null || unlocked == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final current = attempts.where((a) => a.endedAt == null).firstOrNull;
    final xpById = {for (final a in content.achievements) a.id: a.xp};
    final xp = totalXp(
      attempts: attempts,
      cravings: cravings,
      achievementXp: unlocked.map((u) => u.achievementId).toSet().map((id) => xpById[id] ?? 0),
      now: now,
    );
    // Quote of the day; tapping the card shows the next one.
    final quoteOfDay = now.difference(DateTime(2026)).inDays % content.quotes.length;

    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle)),
      body: ListView(
        // Room below the last card so it can scroll clear of the SOS button.
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          if (current != null) ...[
            _TimerCard(attempt: current, now: now),
            const SizedBox(height: 12),
            _SavingsCard(products: products, attempt: current, now: now),
          ] else
            const _NoAttemptCard(),
          const SizedBox(height: 12),
          _LevelCard(content: content, xp: xp),
          const SizedBox(height: 12),
          _QuoteCard(quotes: content.quotes, startIndex: quoteOfDay),
        ],
      ),
    );
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({required this.attempt, required this.now});

  final Attempt attempt;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimaryContainer;
    final d = attemptDuration(attempt, now);
    final p = calendarParts(attempt.startedAt, now);
    String two(int n) => n.toString().padLeft(2, '0');
    final clock = '${two(p.clock.inHours)}:${two(p.clock.inMinutes % 60)}:${two(p.clock.inSeconds % 60)}';
    final clockStyle = TextStyle(color: color, fontFeatures: const [FontFeature.tabularFigures()]);

    // Largest non-zero unit first, then everything down to days: "2 мес · 0 нед · 3 дня".
    final units = [
      (p.years, l.unitYears(p.years)),
      (p.months, l.unitMonths(p.months)),
      (p.weeks, l.unitWeeks(p.weeks)),
      (p.days, l.homeDays(p.days)),
    ];
    final first = units.indexWhere((u) => u.$1 > 0);
    final shown = first < 0 ? const <(int, String)>[] : units.sublist(first);

    Widget tile((int, String) u) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Text(
            '${u.$1}',
            style: theme.textTheme.displayMedium?.copyWith(color: color, fontWeight: FontWeight.bold, height: 1.1),
          ),
          Text(u.$2, style: theme.textTheme.titleMedium?.copyWith(color: color)),
        ],
      ),
    );

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            if (shown.isEmpty)
              // Less than a day: the clock is the hero.
              Text(clock, style: theme.textTheme.displayMedium?.merge(clockStyle).copyWith(fontWeight: FontWeight.bold))
            else ...[
              FittedBox(
                fit: BoxFit.scaleDown,
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final (i, u) in shown.indexed) ...[
                        if (i > 0)
                          VerticalDivider(
                            width: 12,
                            thickness: 1.5,
                            indent: 8,
                            endIndent: 8,
                            color: color.withValues(alpha: 0.35),
                          ),
                        tile(u),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(clock, style: theme.textTheme.headlineMedium?.merge(clockStyle)),
              if (d.inDays >= 7)
                Text(l.homeTotal(l.durDays(d.inDays)), style: theme.textTheme.titleMedium?.merge(clockStyle)),
            ],
            const SizedBox(height: 8),
            Text(
              l.homeSmokeFreeSince(DateFormat('d MMMM yyyy', 'ru').format(attempt.startedAt)),
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  const _SavingsCard({required this.products, required this.attempt, required this.now});

  final List<SmokingProduct> products;
  final Attempt attempt;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = NumberFormat('#,##0', 'ru');
    final duration = attemptDuration(attempt, now);
    final units = unitsAvoided(products, duration);
    Widget infoButton(VoidCallback onTap) => InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
      ),
    );
    Widget cell(IconData icon, String title, List<String> values, {VoidCallback? onInfo, VoidCallback? onMore}) =>
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onMore,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: theme.colorScheme.primary),
                    if (onInfo != null) ...[const SizedBox(width: 4), infoButton(onInfo)],
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: theme.textTheme.labelLarge),
                for (final v in values) Text(v, style: theme.textTheme.titleLarge),
                if (onMore != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${l.homeSavingsMore} ›',
                      style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
              ],
            ),
          ),
        );
    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cell(
              Icons.savings_outlined,
              l.homeMoneySaved,
              [l.money(fmt.format(moneySaved(products, duration)))],
              onInfo: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l.homeSavingsInfoTitle),
                  content: Text(
                    l.homeSavingsInfo(
                      fmt.format(dailyCost(products)),
                      NumberFormat('#,##0.#', 'ru').format(dailyCost(products) / 24),
                    ),
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l.done))],
                ),
              ),
              onMore: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (_) => const _SavingsDetails(),
              ),
            ),
            const SizedBox(width: 16),
            cell(Icons.smoke_free, l.homeNotSmoked, [
              for (final e in units.entries) l.unitsAvoided(e.key.name, fmt.format(e.value.floor())),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Money saved today, this calendar week (from Monday), this calendar month, and in total. Updates live.
class _SavingsDetails extends ConsumerWidget {
  const _SavingsDetails();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final products = ref.watch(productsProvider).value ?? const [];
    final attempt = ref.watch(currentAttemptProvider).value;
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    if (attempt == null) return const SizedBox.shrink();
    final fmt = NumberFormat('#,##0', 'ru');
    String money(double v) => l.money(fmt.format(v));
    final today = DateTime(now.year, now.month, now.day);
    final rows = [
      (l.savingsToday, today),
      (l.savingsWeek, DateTime(now.year, now.month, now.day - (now.weekday - 1))),
      (l.savingsMonth, DateTime(now.year, now.month)),
      (l.savingsTotal, attempt.startedAt),
    ];
    final perDay = dailyCost(products);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.homeMoneySaved, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final (label, from) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
                    Text(
                      money(moneySavedSince(products, attempt, from, now)),
                      style: theme.textTheme.titleMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                  ],
                ),
              ),
            const Divider(height: 24),
            Text(l.savingsForecast(money(perDay * 30.4), money(perDay * 365)), style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(l.savingsPeriodsHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.content, required this.xp});

  final AppContent content;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (level, next) = content.levelFor(xp);
    final progress = next == null ? 1.0 : (xp - level.xpRequired) / (next.xpRequired - level.xpRequired);
    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  child: Text('${level.level}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.homeLevel(level.level), style: theme.textTheme.labelLarge),
                      Text(level.title, style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
                Text('$xp XP', style: theme.textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress, minHeight: 8, borderRadius: BorderRadius.circular(4)),
            const SizedBox(height: 8),
            Text(
              next == null ? l.homeMaxLevel : l.homeXpToNext(next.xpRequired - xp),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatefulWidget {
  const _QuoteCard({required this.quotes, required this.startIndex});

  final List<Quote> quotes;
  final int startIndex;

  @override
  State<_QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<_QuoteCard> {
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSecondaryContainer;
    final quote = widget.quotes[(widget.startIndex + _offset) % widget.quotes.length];
    void next() => setState(() => _offset++);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: next,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.format_quote, color: color),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, color: color),
                    tooltip: AppLocalizations.of(context).homeNextQuote,
                    onPressed: next,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Column(
                    key: ValueKey(quote),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quote.text, style: theme.textTheme.titleMedium?.copyWith(color: color)),
                      if (quote.author != null) ...[
                        const SizedBox(height: 8),
                        Text('— ${quote.author}', style: theme.textTheme.bodyMedium?.copyWith(color: color)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoAttemptCard extends ConsumerWidget {
  const _NoAttemptCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.homeNoAttemptTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(l.homeNoAttemptText, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(databaseProvider).startAttempt(DateTime.now()),
              child: Text(l.homeStartAttempt),
            ),
          ],
        ),
      ),
    );
  }
}
