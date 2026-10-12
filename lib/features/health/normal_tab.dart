import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content.dart';
import '../../data/providers.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';
import 'health_common.dart';

/// «Что сейчас нормально»: withdrawal symptoms typical for the current stage, how long they last, what helps.
class NormalTab extends ConsumerWidget {
  const NormalTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final symptoms = ref.watch(contentProvider).value?.withdrawal;
    final current = ref.watch(currentAttemptProvider).value;
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    if (symptoms == null) return const Center(child: CircularProgressIndicator());

    final hours = current == null ? 0 : attemptDuration(current, now).inHours;
    final active = symptoms.where((s) => hours < s.untilHours).toList();
    final past = symptoms.where((s) => hours >= s.untilHours).toList();
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(text, style: theme.textTheme.titleLarge),
    );

    return ListView(
      padding: healthTabPadding,
      children: [
        Text(l.normalIntro, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        if (active.isNotEmpty) ...[
          heading(l.normalNow),
          for (final s in active) ...[_SymptomCard(symptom: s, active: true), const SizedBox(height: 12)],
        ],
        if (past.isNotEmpty) ...[
          heading(l.normalPast),
          Text(l.normalPastHint, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          for (final s in past) ...[_SymptomCard(symptom: s, active: false), const SizedBox(height: 12)],
        ],
        const SizedBox(height: 12),
        HealthDisclaimer(text: l.normalSources),
        const SizedBox(height: 8),
        const HealthDisclaimer(),
      ],
    );
  }
}

class _SymptomCard extends StatelessWidget {
  const _SymptomCard({required this.symptom, required this.active});

  final WithdrawalSymptom symptom;

  /// Typical for the current stage: shown open with tips; past ones are compact and expand on tap.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = symptom;
    final details = <Widget>[
      Text(s.text, style: theme.textTheme.bodyMedium),
      const SizedBox(height: 12),
      Text(l.normalHelps, style: theme.textTheme.titleSmall?.copyWith(color: scheme.primary)),
      const SizedBox(height: 4),
      for (final t in s.tips)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Icon(Icons.check_circle_outline, size: 18, color: scheme.primary),
              Expanded(child: Text(t, style: theme.textTheme.bodyMedium)),
            ],
          ),
        ),
    ];
    final title = Text(s.title, style: theme.textTheme.titleMedium);
    final lasts = Text(l.normalLasts(s.duration), style: theme.textTheme.bodySmall?.copyWith(color: scheme.primary));
    if (!active) {
      return Card(
        color: scheme.surfaceContainer,
        clipBehavior: Clip.antiAlias,
        child: Theme(
          // No divider lines around the expanded tile inside the card.
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: title,
            subtitle: lasts,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: details,
          ),
        ),
      );
    }
    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [title, const SizedBox(height: 2), lasts, const SizedBox(height: 8), ...details],
        ),
      ),
    );
  }
}
