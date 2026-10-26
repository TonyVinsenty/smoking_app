import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/widgets/choice.dart';
import '../../app/widgets/cards.dart';
import '../../app/format.dart';
import '../../app/widgets/metric_text.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';

/// All attempts, newest first, with the record, badges earned and the relapse diary.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final attempts = ref.watch(attemptsProvider).value ?? const <Attempt>[];
    final unlocked = ref.watch(allUnlockedAchievementsProvider).value ?? const [];
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final best = bestAttempt(attempts, now);
    final bestId = attempts.where((a) => attemptDuration(a, now) == best).firstOrNull?.id;

    Widget stat(String title, String value) => Expanded(
      child: Column(
        children: [
          MetricText(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
            unitStyle: theme.textTheme.labelLarge,
          ),
          Text(title, textAlign: TextAlign.center, style: theme.textTheme.labelMedium),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.historyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          AppCard(
            tone: CardTone.hero,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                stat(l.historyBest, formatElapsed(l, best)),
                stat(l.historyTotal, formatElapsed(l, totalSmokeFree(attempts, now))),
                stat(l.historyCount, '${attempts.length}'),
              ],
            ),
          ),
          for (final (i, a) in attempts.indexed)
            _AttemptCard(
              attempt: a,
              number: attempts.length - i,
              isBest: a.id == bestId && attempts.length > 1,
              badges: unlocked.where((u) => u.attemptId == a.id).length,
              now: now,
            ),
        ],
      ),
    );
  }
}

class _AttemptCard extends StatelessWidget {
  const _AttemptCard({
    required this.attempt,
    required this.number,
    required this.isBest,
    required this.badges,
    required this.now,
  });

  final Attempt attempt;
  final int number;
  final bool isBest;
  final int badges;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final current = attempt.endedAt == null;
    final date = DateFormat('d MMMM yyyy', 'ru');
    final range = attempt.endedAt == null
        ? '${date.format(attempt.startedAt)} — ${l.historyNow}'
        : '${date.format(attempt.startedAt)} — ${date.format(attempt.endedAt!)}';
    final diary = [
      (l.relapseQ1, attempt.whatHappened),
      (l.relapseQ2, attempt.whatWouldHelp),
      (l.relapseQ3, attempt.nextTime),
    ].where((e) => e.$2 != null);

    return AppCard(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      borderColor: current ? theme.colorScheme.primary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  current ? l.historyCurrent(number) : l.historyAttempt(number),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: current ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    fontWeight: current ? FontWeight.w700 : null,
                  ),
                ),
              ),
              if (isBest) ...[
                Icon(Icons.star, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(l.historyBest, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
              ],
            ],
          ),
          const SizedBox(height: 4),
          MetricText(formatElapsed(l, attemptDuration(attempt, now)), style: theme.textTheme.headlineSmall),
          Text(range, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (badges > 0) InfoLabel(l.historyBadges(badges), icon: Icons.emoji_events_outlined),
              if (attempt.trigger != null) InfoLabel(l.triggerName(attempt.trigger!.name)),
            ],
          ),
          for (final (q, a) in diary) ...[
            const SizedBox(height: 12),
            Text(q, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
            Text(a!, style: theme.textTheme.bodyLarge),
          ],
        ],
      ),
    );
  }
}
