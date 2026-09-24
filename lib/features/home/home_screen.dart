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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (current != null) ...[
            _TimerCard(attempt: current, now: now),
            const SizedBox(height: 12),
            _SavingsCard(products: products, duration: attemptDuration(current, now)),
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
    final d = attemptDuration(attempt, now);
    String two(int n) => n.toString().padLeft(2, '0');
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${d.inDays} ',
                    style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: l.homeDays(d.inDays), style: theme.textTheme.headlineSmall),
                ],
              ),
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
            ),
            Text(
              '${two(d.inHours % 24)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.homeSmokeFreeSince(DateFormat('d MMMM yyyy', 'ru').format(attempt.startedAt)),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  const _SavingsCard({required this.products, required this.duration});

  final List<SmokingProduct> products;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = NumberFormat('#,##0', 'ru');
    final units = unitsAvoided(products, duration);
    Widget cell(IconData icon, String title, List<String> values) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.labelLarge),
          for (final v in values) Text(v, style: theme.textTheme.titleLarge),
        ],
      ),
    );
    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cell(Icons.savings_outlined, l.homeMoneySaved, [l.money(fmt.format(moneySaved(products, duration)))]),
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
