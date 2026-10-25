import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../app/widgets/motion.dart';
import '../../app/widgets/level_ring.dart';
import '../../app/format.dart';
import '../../app/widgets/sos_fab.dart';
import '../../app/widgets/cards.dart';
import '../../app/widgets/metric_text.dart';
import '../../app/widgets/reserve_largest.dart';
import '../../content/content.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/craving_stats.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';
import '../cravings/craving_map_screen.dart';
import '../achievements/achievements_screen.dart';
import '../relapse/new_attempt.dart';

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
    // Badges earned at least once (some may have been removed from the content since).
    final badges = unlocked.map((u) => u.achievementId).toSet().where(xpById.containsKey).length;
    final scheme = Theme.of(context).colorScheme;
    // Quote of the day; tapping the card shows the next one.
    final quoteOfDay = now.difference(DateTime(2026)).inDays % content.quotes.length;

    return Scaffold(
      // Cards scroll under the button and fade out softly instead of being cut by a hard edge.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: Theme.of(context).brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        flexibleSpace: SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [scheme.surface, scheme.surface, scheme.surface.withValues(alpha: 0)],
                stops: const [0, 0.62, 1],
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Badge(
              isLabelVisible: ref.watch(newAchievementIdsProvider).isNotEmpty,
              smallSize: 10,
              child: FilledButton.tonalIcon(
                icon: const Icon(Icons.emoji_events_outlined, size: 26),
                label: Text(l.homeAchievementsCount(badges)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(14, 8, 18, 8),
                  textStyle: Theme.of(context).textTheme.titleSmall,
                ),
                onPressed: () => AchievementsScreen.open(context),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        // Room below the last card so it can scroll clear of the SOS button.
        padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + kToolbarHeight + 8, 16, sosClearance),
        children: [
          for (final (i, card) in [
            if (current != null) ...[
              _TimerCard(attempt: current, now: now, milestones: content.milestones),
              _SavingsCard(products: productsOf(products, current.id), attempt: current, now: now),
            ] else
              const _NoAttemptCard(),
            _CravingCard(stats: CravingStats(cravings)),
            _LevelCard(content: content, xp: xp),
            _QuoteCard(quotes: content.quotes, startIndex: quoteOfDay),
          ].indexed) ...[if (i > 0) const SizedBox(height: 12), StaggerIn(screen: 'home', index: i, child: card)],
        ],
      ),
    );
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({required this.attempt, required this.now, required this.milestones});

  final Attempt attempt;
  final DateTime now;
  final List<HealthMilestone> milestones;

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
          Text('${u.$1}', style: theme.textTheme.displayLarge?.merge(clockStyle)),
          Text(u.$2, style: theme.textTheme.titleMedium?.copyWith(color: color)),
        ],
      ),
    );

    return AppCard(
      tone: CardTone.hero,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          if (shown.isEmpty)
            // Less than a day: the clock is the hero.
            Text(clock, style: theme.textTheme.displayLarge?.merge(clockStyle))
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
            Text(clock, style: theme.textTheme.titleLarge?.merge(clockStyle)),
            if (d.inDays >= 7)
              Text(l.homeTotal(l.durDays(d.inDays)), style: theme.textTheme.titleMedium?.merge(clockStyle)),
          ],
          const SizedBox(height: 8),
          Text(
            l.homeSmokeFreeSince(DateFormat('d MMMM yyyy', 'ru').format(attempt.startedAt)),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
          ..._nextMilestone(context, d, color),
        ],
      ),
    );
  }

  /// How far it is to the next recovery milestone: links the timer with the trail in «Здоровье».
  List<Widget> _nextMilestone(BuildContext context, Duration elapsed, Color color) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final minutes = elapsed.inSeconds / 60;
    final next = milestones.where((m) => m.afterMinutes > minutes).firstOrNull;
    if (next == null) return const [];
    // Counted from the previous milestone with an earlier time.
    final start = milestones.map((m) => m.afterMinutes).where((t) => t < next.afterMinutes).lastOrNull ?? 0;
    final progress = ((minutes - start) / (next.afterMinutes - start)).clamp(0.0, 1.0);
    final style = theme.textTheme.labelMedium?.copyWith(color: color);
    return [
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 12,
        children: [
          Expanded(child: Text(l.homeNextMilestone(next.title), style: style)),
          Text(
            formatRemaining(l, Duration(seconds: ((next.afterMinutes - minutes) * 60).ceil())),
            style: style?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      const SizedBox(height: 6),
      GrowBar(
        value: progress,
        minHeight: 6,
        color: theme.colorScheme.primary,
        backgroundColor: color.withValues(alpha: 0.14),
      ),
    ];
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
    final scheme = theme.colorScheme;
    final fmt = NumberFormat('#,##0', 'ru');
    final duration = attemptDuration(attempt, now);
    final units = unitsAvoided(products, duration);
    Widget cell(IconData icon, String title, List<Widget> values, {bool more = false}) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBubble(icon),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ...values,
          if (more)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${l.homeSavingsMore} ›',
                style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
    // The whole «Сэкономлено» half opens the details: a big target instead of a small link.
    final saved = Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () =>
            showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => const _SavingsDetails()),
        child: cell(Icons.savings_outlined, l.homeMoneySaved, [
          CountUp(value: moneySaved(products, duration), builder: (context, v) => MetricText(l.money(fmt.format(v)))),
        ], more: true),
      ),
    );
    final avoided = cell(Icons.smoke_free, l.homeNotSmoked, [
      for (final e in units.entries)
        CountUp(value: e.value, builder: (context, v) => MetricText(avoidedText(l, e.key, v))),
    ]);
    // With a large system font two columns would break words mid-way, so stack them.
    final stacked = MediaQuery.textScalerOf(context).scale(10) > 13;
    return AppCard(
      padding: EdgeInsets.zero,
      child: stacked
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [saved, avoided])
          : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: saved),
                  Expanded(child: avoided),
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
    final attempt = ref.watch(currentAttemptProvider).value;
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    if (attempt == null) return const SizedBox.shrink();
    final products = productsOf(ref.watch(productsProvider).value ?? const [], attempt.id);
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
      child: SingleChildScrollView(
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
                    CountUp(
                      value: moneySavedSince(products, attempt, from, now),
                      builder: (context, v) =>
                          Text(money(v), style: theme.textTheme.titleMedium?.copyWith(fontFeatures: tabular)),
                    ),
                  ],
                ),
              ),
            const Divider(height: 24),
            Text(l.savingsForecast(money(perDay * 30.4), money(perDay * 365)), style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(l.savingsPeriodsHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 16),
            Text(l.homeSavingsInfoTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              l.homeSavingsInfo(fmt.format(perDay), NumberFormat('#,##0.#', 'ru').format(perDay / 24)),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
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
    return AppCard(
      child: Row(
        spacing: 16,
        children: [
          LevelRing(level: level.level, progress: progress),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  l.homeLevel(level.level, NumberFormat('#,##0', 'ru').format(xp)),
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                Text(level.title, style: theme.textTheme.titleMedium),
                Text(
                  next == null ? l.homeMaxLevel : l.homeXpToNext(next.xpRequired - xp),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
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
    final color = theme.colorScheme.onSurface;
    final quote = widget.quotes[(widget.startIndex + _offset) % widget.quotes.length];
    Widget quoteView(Quote q) => Column(
      key: ValueKey(q),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          q.text,
          style: theme.textTheme.bodyLarge?.copyWith(color: color, fontWeight: FontWeight.w500),
        ),
        if (q.author != null) ...[
          const SizedBox(height: 8),
          Text('— ${q.author}', style: theme.textTheme.bodyMedium?.copyWith(color: color)),
        ],
      ],
    );
    void next() => setState(() => _offset++);
    return AppCard(
      onTap: next,
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, color: theme.colorScheme.primary),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.refresh, color: theme.colorScheme.onSurfaceVariant),
                tooltip: AppLocalizations.of(context).homeNextQuote,
                onPressed: next,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ReserveLargest(
              candidates: [for (final q in widget.quotes) quoteView(q)],
              child: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: quoteView(quote)),
            ),
          ),
        ],
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
    return AppCard(
      tone: CardTone.hero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.homeNoAttemptTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(l.homeNoAttemptText, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => startNewAttempt(context, ref), child: Text(l.homeStartAttempt)),
        ],
      ),
    );
  }
}

/// Short summary of the craving map; opens the full screen.
class _CravingCard extends StatelessWidget {
  const _CravingCard({required this.stats});

  final CravingStats stats;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final part = stats.topPart;
    final trigger = stats.topTrigger;
    final often = [
      if (part != null) l.dayPartWhen(part.name),
      if (trigger != null) l.triggerName(trigger.name).toLowerCase(),
    ].join(' · ');
    return AppCard(
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const CravingMapScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBubble(Icons.bar_chart_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.cravingTitle,
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 8),
          if (stats.isEmpty)
            Text(l.cravingHomeEmpty, style: theme.textTheme.bodyMedium)
          else ...[
            Text(l.cravingResistedTimes(stats.summary.resisted), style: theme.textTheme.titleLarge),
            if (often.isNotEmpty) Text(l.cravingOften(often), style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
