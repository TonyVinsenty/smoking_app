import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/format.dart';
import '../../content/content.dart';
import '../../data/providers.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context).tabHealth)),
    body: const _RecoveryTab(),
  );
}

class _RecoveryTab extends ConsumerWidget {
  const _RecoveryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final content = ref.watch(contentProvider).value;
    final current = ref.watch(currentAttemptProvider).value;
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    if (content == null) return const Center(child: CircularProgressIndicator());

    final elapsed = current == null ? 0.0 : attemptDuration(current, now).inSeconds / 60;
    final milestones = content.milestones;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Card(
          color: theme.colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(child: Text(l.healthDisclaimer, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ),
        ),
        if (current == null) ...[const SizedBox(height: 12), Text(l.healthNoAttempt, style: theme.textTheme.bodyLarge)],
        for (var i = 0; i < milestones.length; i++) ...[
          const SizedBox(height: 12),
          _MilestoneCard(
            milestone: milestones[i],
            elapsedMinutes: elapsed,
            // Milestones sharing the same time all count from the previous distinct one.
            segmentStart:
                milestones.take(i).map((m) => m.afterMinutes).where((t) => t < milestones[i].afterMinutes).lastOrNull ??
                0,
          ),
        ],
      ],
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({required this.milestone, required this.elapsedMinutes, required this.segmentStart});

  final HealthMilestone milestone;
  final double elapsedMinutes;

  /// Previous milestone time: progress towards this one is counted from there.
  final int segmentStart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final m = milestone;
    final reached = elapsedMinutes >= m.afterMinutes;
    final span = m.afterMinutes - segmentStart;
    final progress = span <= 0 ? 0.0 : ((elapsedMinutes - segmentStart) / span).clamp(0.0, 1.0);
    final inProgress = !reached && progress > 0;
    return Opacity(
      opacity: reached || inProgress ? 1 : 0.7,
      child: Card(
        color: reached ? scheme.primaryContainer : scheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: reached ? scheme.primary : scheme.surfaceContainerHighest,
                foregroundColor: reached ? scheme.onPrimary : scheme.onSurfaceVariant,
                child: Icon(reached ? Icons.check : categoryIcon(m.category)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatPeriod(l, m.afterMinutes),
                      style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(m.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(m.description, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    if (reached)
                      Text(l.healthReached, style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary))
                    else ...[
                      LinearProgressIndicator(value: progress, minHeight: 6, borderRadius: BorderRadius.circular(3)),
                      const SizedBox(height: 4),
                      Text(
                        l.healthRemaining(
                          formatRemaining(l, Duration(seconds: ((m.afterMinutes - elapsedMinutes) * 60).ceil())),
                        ),
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                    if (m.source != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l.healthSource(m.source!),
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
