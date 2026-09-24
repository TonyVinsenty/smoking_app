import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/format.dart';
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
    final unlocked = ref.watch(unlockedAchievementsProvider).value ?? const [];
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final best = bestAttempt(attempts, now);
    final bestId = attempts.where((a) => attemptDuration(a, now) == best).firstOrNull?.id;

    Widget stat(String title, String value) => Expanded(
      child: Column(
        children: [
          Text(value, textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
          Text(title, textAlign: TextAlign.center, style: theme.textTheme.labelMedium),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.historyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
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
    final date = DateFormat('d MMMM yyyy', 'ru');
    final range = attempt.endedAt == null
        ? '${date.format(attempt.startedAt)} — ${l.historyNow}'
        : '${date.format(attempt.startedAt)} — ${date.format(attempt.endedAt!)}';
    final diary = [
      (l.relapseQ1, attempt.whatHappened),
      (l.relapseQ2, attempt.whatWouldHelp),
      (l.relapseQ3, attempt.nextTime),
    ].where((e) => e.$2 != null);

    return Card(
      color: attempt.endedAt == null ? theme.colorScheme.secondaryContainer : theme.colorScheme.surfaceContainerHigh,
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(l.historyAttempt(number), style: theme.textTheme.labelLarge)),
                if (isBest) ...[
                  Icon(Icons.star, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(l.historyBest, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(formatElapsed(l, attemptDuration(attempt, now)), style: theme.textTheme.headlineSmall),
            Text(range, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (badges > 0)
                  Chip(avatar: const Icon(Icons.military_tech, size: 18), label: Text(l.historyBadges(badges))),
                if (attempt.trigger != null) Chip(label: Text(l.triggerName(attempt.trigger!.name))),
              ],
            ),
            for (final (q, a) in diary) ...[
              const SizedBox(height: 12),
              Text(q, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
              Text(a!, style: theme.textTheme.bodyLarge),
            ],
          ],
        ),
      ),
    );
  }
}
