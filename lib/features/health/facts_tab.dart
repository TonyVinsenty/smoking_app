import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/motion.dart';
import '../../app/widgets/cards.dart';
import '../../app/widgets/metric_text.dart';
import '../../content/content.dart';
import '../../l10n/app_localizations.dart';
import 'health_common.dart';

/// «Факты»: real numbers from research, each with its source.
class FactsTab extends ConsumerWidget {
  const FactsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facts = ref.watch(contentProvider).value?.healthFacts;
    if (facts == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: healthTabPadding,
      children: [
        for (final (i, f) in facts.indexed) ...[
          StaggerIn(
            screen: 'facts',
            index: i,
            child: _FactCard(fact: f),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
        const HealthDisclaimer(),
      ],
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({required this.fact});

  final HealthFact fact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetricText(fact.value, color: scheme.primary),
          const SizedBox(height: 4),
          Text(fact.text, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(l.healthSource(fact.source), style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
