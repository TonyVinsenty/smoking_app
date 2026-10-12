import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/cards.dart';
import '../../app/widgets/choice.dart';
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
        // Rows of two equal-height tiles; one per row when a name would not fit whole (large system font).
        LayoutBuilder(
          builder: (context, box) {
            final perRow =
                wordsFit(
                  context,
                  [for (final a in _areas) l.bodyArea(a)],
                  theme.textTheme.titleSmall,
                  (box.maxWidth - 12) / 2 - 24,
                )
                ? 2
                : 1;
            return Column(
              children: [
                for (var i = 0; i < tiles.length; i += perRow)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 12,
                        children: [
                          for (var j = i; j < i + perRow; j++)
                            Expanded(child: j < tiles.length ? tiles[j] : const SizedBox()),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
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
    // A finished area turns mint with a check: a small celebration. Otherwise dots show the progress.
    final tone = full ? CardTone.hero : CardTone.plain;
    final on = AppCard.onColor(context, tone);
    return AppCard(
      tone: tone,
      padding: const EdgeInsets.all(14),
      onTap: () => _showMilestones(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              full
                  ? Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(11)),
                      child: Icon(Icons.check_rounded, size: 22, color: scheme.onPrimary),
                    )
                  : IconBubble(categoryIcon(area), size: 36),
              const Spacer(),
              Text(
                l.bodyProgress(done, milestones.length),
                style: theme.textTheme.labelLarge?.copyWith(color: on, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(l.bodyArea(area), style: theme.textTheme.titleSmall?.copyWith(color: on)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (var i = 0; i < milestones.length; i++)
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < done ? (full ? scheme.onPrimaryContainer : scheme.primary) : scheme.outlineVariant,
                  ),
                ),
            ],
          ),
        ],
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
