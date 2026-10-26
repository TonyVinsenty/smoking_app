import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';
import '../onboarding/onboarding_screen.dart';

/// Starts a new attempt from now. First asks whether to keep the progress or start «с чистого листа»;
/// then, as the user may have switched products since the last attempt (e.g. sticks → cigarettes),
/// whether to keep the previous smoking habits or edit them. Returns false if the user backed out.
Future<bool> startNewAttempt(BuildContext context, WidgetRef ref) async {
  final attempts = ref.read(attemptsProvider).value ?? const <Attempt>[];
  final previous = latestProducts(ref.read(productsProvider).value ?? const [], attempts);
  final fresh = attempts.isEmpty ? false : await _askFreshStart(context);
  if (fresh == null || !context.mounted) return false;
  final keep = previous.isEmpty ? false : await _askKeep(context, previous);
  if (keep == null || !context.mounted) return false;
  final products = keep
      ? [for (final p in previous) p.toCompanion(false)]
      : await OnboardingScreen.editProducts(context, previous);
  if (products == null) return false;
  await ref.read(databaseProvider).startAttempt(DateTime.now(), products, freshStart: fresh);
  return true;
}

/// true = «С чистого листа», false = keep the progress, null = dismissed.
Future<bool?> _askFreshStart(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showDialog<bool>(
    context: context,
    builder: (context) {
      Widget option(IconData icon, String title, String text, bool fresh) => Card.outlined(
        margin: const EdgeInsets.only(top: 12),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(text),
          onTap: () => Navigator.pop(context, fresh),
        ),
      );
      return AlertDialog(
        title: Text(l.freshStartTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              option(Icons.trending_up, l.freshStartKeep, l.freshStartKeepText, false),
              option(Icons.restart_alt, l.freshStartReset, l.freshStartResetText, true),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel))],
      );
    },
  );
}

/// true = keep, false = change, null = dismissed.
Future<bool?> _askKeep(BuildContext context, List<SmokingProduct> products) {
  final l = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final num = NumberFormat('#,##0.##', 'ru');
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.newAttemptTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.newAttemptText, style: theme.textTheme.bodyLarge),
            for (final p in products) ...[
              const SizedBox(height: 12),
              Text(l.productName(p.type.name), style: theme.textTheme.titleMedium),
              Text(
                l.productSummary(
                  num.format(p.amount),
                  l.periodName(p.period.name),
                  num.format(p.packPrice),
                  p.type.name,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.newAttemptChange)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.newAttemptKeep)),
      ],
    ),
  );
}
