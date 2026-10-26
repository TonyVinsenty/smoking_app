import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';
import '../../app/widgets/wheel_time_picker.dart';
import '../onboarding/onboarding_screen.dart';

/// Starts a new attempt. First asks when it starts (now or earlier, e.g. the relapse was marked late)
/// and whether to keep the progress or start «с чистого листа»; then, as the user may have switched products
/// since the last attempt (e.g. sticks → cigarettes), whether to keep the previous smoking habits or edit them.
/// Returns false if the user backed out.
Future<bool> startNewAttempt(BuildContext context, WidgetRef ref) async {
  final attempts = ref.read(attemptsProvider).value ?? const <Attempt>[];
  final previous = latestProducts(ref.read(productsProvider).value ?? const [], attempts);
  // The new attempt cannot start before the previous one ended.
  final earliest = attempts
      .map((a) => a.endedAt ?? a.startedAt)
      .fold<DateTime?>(null, (latest, t) => latest == null || t.isAfter(latest) ? t : latest);
  final start = earliest == null ? (fresh: false, at: null) : await _askStart(context, earliest);
  if (start == null || !context.mounted) return false;
  final keep = previous.isEmpty ? false : await _askKeep(context, previous);
  if (keep == null || !context.mounted) return false;
  final products = keep
      ? [for (final p in previous) p.toCompanion(false)]
      : await OnboardingScreen.editProducts(context, previous);
  if (products == null) return false;
  await ref.read(databaseProvider).startAttempt(start.at ?? DateTime.now(), products, freshStart: start.fresh);
  return true;
}

/// A moment between [first] and now: a date, then a time on the wheel. Null if dismissed.
Future<DateTime?> pickPastMoment(BuildContext context, {required DateTime first, DateTime? initial}) async {
  final now = DateTime.now();
  final date = await showDatePicker(
    context: context,
    initialDate: initial ?? now,
    firstDate: first.isAfter(now) ? now : first,
    lastDate: now,
  );
  if (date == null || !context.mounted) return null;
  final time = await showWheelTimePicker(context, initialTime: TimeOfDay.fromDateTime(initial ?? now));
  if (time == null) return null;
  final at = DateTime(date.year, date.month, date.day, time.hour, time.minute);
  return at.isAfter(now) ? now : (at.isBefore(first) ? first : at);
}

/// The start of the new attempt (at: null = now) and whether it is «с чистого листа»; null = dismissed.
Future<({bool fresh, DateTime? at})?> _askStart(BuildContext context, DateTime earliest) {
  final l = AppLocalizations.of(context);
  final theme = Theme.of(context);
  DateTime? at;
  return showDialog<({bool fresh, DateTime? at})>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        Widget option(IconData icon, String title, String text, bool fresh) => Card.outlined(
          margin: const EdgeInsets.only(top: 12),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(text),
            onTap: () => Navigator.pop(context, (fresh: fresh, at: at)),
          ),
        );
        return AlertDialog(
          title: Text(l.freshStartTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.newAttemptWhen, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l.newAttemptNow),
                      selected: at == null,
                      onSelected: (_) => setState(() => at = null),
                    ),
                    ChoiceChip(
                      avatar: const Icon(Icons.schedule, size: 18),
                      label: Text(at == null ? l.relapsePickTime : DateFormat('d MMMM, HH:mm', 'ru').format(at!)),
                      selected: at != null,
                      onSelected: (_) async {
                        final picked = await pickPastMoment(context, first: earliest, initial: at);
                        if (picked != null) setState(() => at = picked);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                option(Icons.trending_up, l.freshStartKeep, l.freshStartKeepText, false),
                option(Icons.restart_alt, l.freshStartReset, l.freshStartResetText, true),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel))],
        );
      },
    ),
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
