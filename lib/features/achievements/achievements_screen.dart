import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/widgets/cards.dart';
import '../../app/format.dart';
import '../../app/widgets/badge_icon.dart';
import '../../domain/achievements.dart';
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
    'streak' => Icons.timer_outlined,
    'cravings' => Icons.self_improvement,
    'money' => Icons.savings_outlined,
    'units' => Icons.smoke_free,
    'articles' => Icons.menu_book_outlined,
    _ => Icons.flag_outlined,
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
    // How far each condition is now (read once: the screen does not need to tick every second).
    final progress = conditionProgress(
      attempts: ref.watch(attemptsProvider).value ?? const [],
      products: ref.watch(productsProvider).value ?? const [],
      cravings: ref.watch(cravingsProvider).value ?? const [],
      articlesReadAt: [for (final r in ref.watch(articlesReadProvider).value ?? const []) r.readAt],
      now: DateTime.now(),
    );
    // Icon + two lines of title + one small line (rarity or progress), whatever the text size.
    final line = MediaQuery.textScalerOf(context).scale(theme.textTheme.labelMedium!.fontSize!) * 1.4;
    final textScale = line / (theme.textTheme.labelMedium!.fontSize! * 1.4);
    final small = MediaQuery.textScalerOf(context).scale(theme.textTheme.labelSmall!.fontSize!) * 1.35;
    final tileHeight = 64 + 8 + 2 * line + small + 16;
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
                      style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
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
                            Expanded(child: Text(l.achGroup(group), style: theme.textTheme.titleMedium)),
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
                    itemBuilder: (context, i) => _BadgeTile(
                      achievement: items[i],
                      unlocked: firstUnlock[items[i].id],
                      current: progress?[items[i].conditionType],
                    ),
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
  const _BadgeTile({required this.achievement, required this.unlocked, required this.current});

  final Achievement achievement;

  /// Current value of the badge's condition (null without a current attempt).
  final num? current;
  final UnlockedAchievement? unlocked;

  /// Earned titles take their rarity colour, like item names in RPGs (grey "common" stays plain).
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final main = ref.watch(mainProductProvider);
    final earned = unlocked != null;
    final target = achievement.conditionValue(main?.name);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showDetails(context, ref.read(mainProductProvider)),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            BadgeIcon(
              achievement: achievement,
              unlocked: earned,
              size: 64,
              progress: current == null || target <= 0 ? null : current! / target,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: earned ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                fontWeight: earned ? FontWeight.w600 : null,
              ),
            ),
            Text(
              earned ? l.tierName(achievement.tier) : progressText(l, achievement, main, current),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
              BadgeIcon(
                achievement: a,
                unlocked: at != null,
                size: 96,
                pulse: true,
                progress: current == null ? null : current! / a.conditionValue(main?.name),
              ),
              const SizedBox(height: 16),
              Text(a.title, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
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
              if (at == null && current != null)
                Text(
                  progressText(l, a, main, current),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: rarity),
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
                  RewardPill('+${a.xp} XP'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "18 из 200 дней", "1 200 из 5 000 ₽": progress towards a badge not earned yet, in the badge's units.
  static String progressText(AppLocalizations l, Achievement a, ProductType? main, num? current) {
    if (current == null) return '';
    final fmt = NumberFormat('#,##0', 'ru');
    final target = a.conditionValue(main?.name).toInt();
    final now = current.floor().clamp(0, target);
    String of(String total, int Function(int) unit) => l.achProgress(fmt.format(unit(now)), total);
    return switch (a.conditionType) {
      // After «из» the unit takes the genitive: «из 21 дня», «из 200 дней».
      'smokeFreeMinutes' when target >= 1440 => of(l.achOfDays(target ~/ 1440), (m) => m ~/ 1440),
      'smokeFreeMinutes' when target >= 60 => of(l.achOfHours(target ~/ 60), (m) => m ~/ 60),
      'smokeFreeMinutes' => of(l.achOfMinutes(target), (m) => m),
      'moneySavedRub' => of(l.money(fmt.format(target)), (v) => v),
      'unitsAvoided' => of('${fmt.format(target)} ${l.achOfUnits((main ?? ProductType.cigarettes).name)}', (v) => v),
      _ => l.achProgress(fmt.format(now), fmt.format(target)),
    };
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

/// Whole percent, rounded as usual (16.7 → 17), but 100 only once everything is done.
int percentOf(int done, int total) => total == 0 ? 0 : (done < total ? (done * 100 / total).round().clamp(0, 99) : 100);
