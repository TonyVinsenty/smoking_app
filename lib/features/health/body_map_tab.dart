import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/format.dart';
import '../../content/content.dart';
import '../../data/providers.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';
import 'health_common.dart';

/// «Карта тела»: a tile per body area that fills up as its recovery milestones are passed.
class BodyMapTab extends ConsumerWidget {
  const BodyMapTab({super.key});

  static const _areas = ['heart', 'lungs', 'circulation', 'energy', 'mind', 'taste_smell', 'risk'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final milestones = ref.watch(contentProvider).value?.milestones;
    final current = ref.watch(currentAttemptProvider).value;
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    if (milestones == null) return const Center(child: CircularProgressIndicator());

    final minutes = current == null ? 0.0 : attemptDuration(current, now).inSeconds / 60;
    final tiles = [
      for (final a in _areas)
        if (milestones.any((m) => m.category == a))
          _AreaTile(area: a, milestones: milestones.where((m) => m.category == a).toList(), minutes: minutes),
    ];
    return ListView(
      padding: healthTabPadding,
      children: [
        Text(l.bodyIntro, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        // Rows of two equal-height tiles; they grow with a large system font.
        for (var i = 0; i < tiles.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  Expanded(child: tiles[i]),
                  Expanded(child: i + 1 < tiles.length ? tiles[i + 1] : const SizedBox()),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        const HealthDisclaimer(),
      ],
    );
  }
}

class _AreaTile extends StatelessWidget {
  const _AreaTile({required this.area, required this.milestones, required this.minutes});

  final String area;
  final List<HealthMilestone> milestones;
  final double minutes;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final done = milestones.where((m) => minutes >= m.afterMinutes).length;
    final full = done == milestones.length;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showMilestones(context),
        child: Stack(
          children: [
            // The fill rises from the bottom as milestones are passed.
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: done / milestones.length),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => FractionallySizedBox(
                    heightFactor: v,
                    widthFactor: 1,
                    child: ColoredBox(color: scheme.primaryContainer),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: full ? scheme.primary : scheme.surface,
                        child: Icon(
                          categoryIcon(area, filled: full),
                          size: 18,
                          color: full ? scheme.onPrimary : scheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(l.bodyProgress(done, milestones.length), style: theme.textTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(l.bodyArea(area), maxLines: 2, style: theme.textTheme.titleSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMilestones(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.bodyArea(area), style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              for (final m in milestones) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Icon(
                      minutes >= m.afterMinutes ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: minutes >= m.afterMinutes ? scheme.primary : scheme.outline,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.title, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(m.description, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text(
                            minutes >= m.afterMinutes
                                ? l.healthReached
                                : l.healthRemaining(
                                    formatRemaining(l, Duration(seconds: ((m.afterMinutes - minutes) * 60).ceil())),
                                  ),
                            style: theme.textTheme.bodySmall?.copyWith(color: scheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
