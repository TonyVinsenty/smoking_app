import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/format.dart';
import '../../content/content.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.tabHealth),
          bottom: TabBar(
            tabs: [
              Tab(text: l.healthTabRecovery),
              Tab(text: l.healthTabAchievements),
            ],
          ),
        ),
        body: const TabBarView(children: [_RecoveryTab(), _AchievementsTab()]),
      ),
    );
  }
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

class _AchievementsTab extends ConsumerWidget {
  const _AchievementsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final content = ref.watch(contentProvider).value;
    final unlocked = ref.watch(unlockedAchievementsProvider).value;
    if (content == null || unlocked == null) return const Center(child: CircularProgressIndicator());

    // First time each badge was earned.
    final firstUnlock = <String, UnlockedAchievement>{};
    for (final u in unlocked) {
      final prev = firstUnlock[u.achievementId];
      if (prev == null || u.unlockedAt.isBefore(prev.unlockedAt)) firstUnlock[u.achievementId] = u;
    }
    // Earned badges first, then the rest in content order.
    final all = [
      ...content.achievements.where((a) => firstUnlock.containsKey(a.id)),
      ...content.achievements.where((a) => !firstUnlock.containsKey(a.id)),
    ];
    // Icon + two lines of title, whatever the text size.
    final line = MediaQuery.textScalerOf(context).scale(theme.textTheme.labelMedium!.fontSize!) * 1.4;
    final tileHeight = 64 + 8 + 2 * line + 16;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(l.achUnlockedCount(firstUnlock.length, all.length), style: theme.textTheme.titleMedium),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 140, mainAxisExtent: tileHeight),
            itemCount: all.length,
            itemBuilder: (context, i) => _BadgeTile(achievement: all[i], unlocked: firstUnlock[all[i].id]),
          ),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.achievement, required this.unlocked});

  final Achievement achievement;
  final UnlockedAchievement? unlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showDetails(context),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            _BadgeIcon(achievement: achievement, unlocked: unlocked != null, size: 64),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: unlocked != null ? null : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final a = achievement;
    final at = unlocked?.unlockedAt;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BadgeIcon(achievement: a, unlocked: at != null, size: 96),
              const SizedBox(height: 16),
              Text(a.title, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(a.description, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              Text(
                at != null
                    ? l.achUnlockedAt(DateFormat('d MMMM yyyy', 'ru').format(at))
                    : l.achHowTo(_conditionText(l, a)),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Chip(label: Text('+${a.xp} XP')),
            ],
          ),
        ),
      ),
    );
  }

  static String _conditionText(AppLocalizations l, Achievement a) {
    final v = a.conditionValue.toInt();
    return switch (a.conditionType) {
      'smokeFreeMinutes' => l.achCondSmokeFree(formatPeriod(l, v)),
      'moneySavedRub' => l.achCondMoney(NumberFormat('#,##0', 'ru').format(v)),
      'cravingsResisted' => l.achCondCravings(v),
      'articlesRead' => l.achCondArticles(v),
      'attemptsStarted' => l.achCondAttempts(v),
      'comebackAfterRelapse' => l.achCondComeback(v),
      _ => '',
    };
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.achievement, required this.unlocked, required this.size});

  final Achievement achievement;
  final bool unlocked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = tierColor(achievement.tier);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: unlocked ? color.withValues(alpha: 0.18) : scheme.surfaceContainerHighest,
        border: Border.all(color: unlocked ? color : scheme.outlineVariant, width: 3),
      ),
      child: Icon(
        unlocked ? contentIcon(achievement.icon) : Icons.lock_outline,
        size: size * 0.5,
        color: unlocked ? color : scheme.outline,
      ),
    );
  }
}
