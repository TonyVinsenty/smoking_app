import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/format.dart';
import '../../app/widgets/badge_icon.dart';
import '../../content/content.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';

/// All badges by group; opened from the home screen trophy button.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AchievementsScreen()));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context).healthTabAchievements)),
    body: const _AchievementsList(),
  );
}

class _AchievementsList extends ConsumerWidget {
  const _AchievementsList();
  static const _screen = 'achievements';

  static IconData _groupIcon(String group) => switch (group) {
    'streak' => Icons.timer,
    'cravings' => Icons.self_improvement,
    'money' => Icons.savings,
    'units' => Icons.smoke_free,
    'articles' => Icons.menu_book,
    _ => Icons.flag,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final expanded = ref.watch(expandedSectionsProvider(_screen));
    final allOpen = Achievement.groups.every(expanded.contains);
    final content = ref.watch(contentProvider).value;
    final unlocked = ref.watch(unlockedAchievementsProvider).value;
    final main = ref.watch(mainProductProvider);
    if (content == null || unlocked == null) return const Center(child: CircularProgressIndicator());

    // First time each badge was earned.
    final firstUnlock = <String, UnlockedAchievement>{};
    for (final u in unlocked) {
      if (!content.achievements.any((a) => a.id == u.achievementId)) continue; // removed from content
      final prev = firstUnlock[u.achievementId];
      if (prev == null || u.unlockedAt.isBefore(prev.unlockedAt)) firstUnlock[u.achievementId] = u;
    }
    // Icon + two lines of title, whatever the text size.
    final line = MediaQuery.textScalerOf(context).scale(theme.textTheme.labelMedium!.fontSize!) * 1.4;
    final textScale = line / (theme.textTheme.labelMedium!.fontSize! * 1.4);
    final tileHeight = 64 + 8 + 2 * line + 16;
    final total = content.achievements.length;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: _Progress(
              title: Text(
                l.achUnlockedCount(firstUnlock.length, total, percentOf(firstUnlock.length, total)),
                style: theme.textTheme.titleMedium,
              ),
              value: firstUnlock.length / total,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
          sliver: SliverToBoxAdapter(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () =>
                  ref.read(expandedSectionsProvider(_screen).notifier).setAll(allOpen ? const [] : Achievement.groups),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(allOpen ? Icons.unfold_less : Icons.unfold_more, color: theme.colorScheme.primary),
                    Text(
                      allOpen ? l.collapseAll : l.expandAll,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        for (final group in Achievement.groups)
          ...() {
            // Easiest first within a group.
            final items = content.achievements.where((a) => a.group == group).toList()
              ..sort((a, b) => a.conditionValue(main?.name).compareTo(b.conditionValue(main?.name)));
            final done = items.where((a) => firstUnlock.containsKey(a.id)).length;
            final open = expanded.contains(group);
            return [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                sliver: SliverToBoxAdapter(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => ref.read(expandedSectionsProvider(_screen).notifier).toggle(group),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _Progress(
                        title: Row(
                          spacing: 8,
                          children: [
                            Icon(_groupIcon(group), color: theme.colorScheme.primary),
                            Expanded(
                              child: Text(
                                l.achGroup(group),
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              l.achGroupProgress(done, items.length, percentOf(done, items.length)),
                              style: theme.textTheme.labelLarge,
                            ),
                            AnimatedRotation(
                              turns: open ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(Icons.expand_more),
                            ),
                          ],
                        ),
                        value: done / items.length,
                      ),
                    ),
                  ),
                ),
              ),
              if (open)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      // Wider tiles (fewer columns) with a large system font, so titles do not break mid-word.
                      maxCrossAxisExtent: 140 * textScale.clamp(1.0, 2.0),
                      mainAxisExtent: tileHeight,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) => _BadgeTile(achievement: items[i], unlocked: firstUnlock[items[i].id]),
                  ),
                ),
            ];
          }(),
        const SliverPadding(padding: EdgeInsets.only(bottom: 96)),
      ],
    );
  }
}

/// Title above a thin progress bar.
class _Progress extends StatelessWidget {
  const _Progress({required this.title, required this.value});

  final Widget title;
  final double value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 6,
    children: [
      title,
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: value, minHeight: 6),
      ),
    ],
  );
}

class _BadgeTile extends ConsumerWidget {
  const _BadgeTile({required this.achievement, required this.unlocked});

  final Achievement achievement;
  final UnlockedAchievement? unlocked;

  /// Earned titles take their rarity colour, like item names in RPGs (grey "common" stays plain).
  static Color? titleColor(ThemeData theme, Achievement a, bool earned) => !earned
      ? theme.colorScheme.onSurfaceVariant
      : a.tier == 'common'
      ? null
      : Color.lerp(tierColor(a.tier), theme.colorScheme.onSurface, theme.brightness == Brightness.dark ? 0.1 : 0.25);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showDetails(context, ref.read(mainProductProvider)),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            BadgeIcon(achievement: achievement, unlocked: unlocked != null, size: 64),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: titleColor(theme, achievement, unlocked != null),
                fontWeight: unlocked != null ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, ProductType? main) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final a = achievement;
    final at = unlocked?.unlockedAt;
    final rarity = tierColor(a.tier);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BadgeIcon(achievement: a, unlocked: at != null, size: 96, pulse: true),
              const SizedBox(height: 16),
              Text(
                a.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(color: titleColor(theme, a, true)),
              ),
              const SizedBox(height: 8),
              Text(achievementDescription(l, a, main), textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              Text(
                at != null
                    ? l.achUnlockedAt(DateFormat('d MMMM yyyy', 'ru').format(at))
                    : l.achHowTo(_conditionText(l, a, main)),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  Chip(
                    avatar: Icon(Icons.diamond, color: rarity, size: 18),
                    label: Text(l.tierName(a.tier)),
                    side: BorderSide(color: rarity),
                  ),
                  Chip(label: Text('+${a.xp} XP')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _conditionText(AppLocalizations l, Achievement a, ProductType? main) {
    final v = a.conditionValue(main?.name).toInt();
    return switch (a.conditionType) {
      'smokeFreeMinutes' => l.achCondSmokeFree(formatPeriod(l, v)),
      'moneySavedRub' => l.achCondMoney(NumberFormat('#,##0', 'ru').format(v)),
      'unitsAvoided' => l.achCondUnits(unitsText(l, main ?? ProductType.cigarettes, v)),
      'cravingsResisted' => l.achCondCravings(v),
      'articlesRead' => l.achCondArticles(v),
      'attemptsStarted' => l.achCondAttempts(v),
      'comebackAfterRelapse' => l.achCondComeback(v),
      _ => '',
    };
  }
}

/// Whole percent, never rounded up to 100 before everything is done.
int percentOf(int done, int total) => total == 0 ? 0 : done * 100 ~/ total;
