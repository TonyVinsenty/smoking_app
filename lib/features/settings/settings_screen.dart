import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/format.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/stats.dart';
import '../onboarding/onboarding_screen.dart';
import '../relapse/history_screen.dart';
import '../relapse/relapse_screen.dart';
import '../sos/sos_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final attempts = ref.watch(attemptsProvider).value ?? const [];
    final current = attempts.where((a) => a.endedAt == null).firstOrNull;
    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(text, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.tabSettings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          header(l.settingsAppearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                for (final m in const [ThemeMode.system, ThemeMode.dark, ThemeMode.light])
                  // Shrinks a little with «Крупный текст» instead of breaking «Системный» onto two lines.
                  ButtonSegment(
                    value: m,
                    label: FittedBox(fit: BoxFit.scaleDown, child: Text(l.themeModeName(m.name), maxLines: 1)),
                  ),
              ],
              selected: {ref.watch(themeModeProvider)},
              onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            secondary: const Icon(Icons.format_size),
            title: Text(l.settingsLargeText),
            subtitle: Text(l.settingsLargeTextHint),
            value: ref.watch(largeTextProvider),
            onChanged: (on) => ref.read(largeTextProvider.notifier).set(on),
          ),
          header(l.settingsAttempt),
          if (current != null)
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: Text(l.relapseButton),
              subtitle: Text(l.relapseButtonHint),
              onTap: () => RelapseScreen.start(context, current),
            ),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(l.historyButton),
            subtitle: Text(l.historyButtonHint(formatElapsed(l, bestAttempt(attempts, DateTime.now())))),
            onTap: () => HistoryScreen.open(context),
          ),
          header(l.settingsSos),
          ListTile(
            leading: const Icon(Icons.air),
            title: Text(l.settingsSosExercise),
            subtitle: Text(l.sosExerciseName(ref.watch(sosExerciseProvider).name)),
            onTap: () => showSosExercisePicker(context, ref),
          ),
          header(l.settingsNotifications),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_none),
            title: Text(l.settingsNotificationsMilestones),
            subtitle: Text(l.settingsNotificationsHint),
            value: ref.watch(notificationsEnabledProvider),
            onChanged: (on) => ref.read(notificationsEnabledProvider.notifier).set(on),
          ),
          header(l.settingsData),
          if (current != null)
            ListTile(
              leading: const Icon(Icons.tune),
              title: Text(l.settingsHabits),
              subtitle: Text(l.settingsHabitsHint),
              onTap: () => _editHabits(context, ref, current),
            ),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
            title: Text(l.settingsReset, style: TextStyle(color: theme.colorScheme.error)),
            subtitle: Text(l.settingsResetHint),
            onTap: () => _confirmReset(context, ref),
          ),
        ],
      ),
    );
  }

  /// «Мои привычки»: edits the smoking habits of the current attempt; savings are recalculated from them.
  Future<void> _editHabits(BuildContext context, WidgetRef ref, Attempt current) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = AppLocalizations.of(context).settingsHabitsSaved;
    final products = await OnboardingScreen.editProducts(
      context,
      productsOf(ref.read(productsProvider).value ?? const [], current.id),
    );
    if (products == null) return;
    await ref.read(databaseProvider).replaceProducts(current.id, products);
    messenger.showSnackBar(SnackBar(content: Text(saved)));
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.settingsResetConfirmTitle),
        content: Text(l.settingsResetConfirmText),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.settingsResetConfirm),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(databaseProvider).resetAll();
  }
}
