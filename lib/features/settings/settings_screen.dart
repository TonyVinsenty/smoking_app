import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/widgets/cards.dart';
import '../../app/widgets/sos_fab.dart';
import '../../app/widgets/choice.dart';
import '../../app/widgets/toast.dart';
import '../../app/widgets/wheel_time_picker.dart';
import '../../app/app_icon.dart';
import '../../app/format.dart';
import '../../app/theme.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/settings.dart';
import '../../app/widgets/tab_page.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/stats.dart';
import '../onboarding/onboarding_screen.dart';
import 'privacy_screen.dart';
import 'thanks_screen.dart';
import '../relapse/history_screen.dart';
import '../relapse/relapse_screen.dart';
import '../sos/sos_screen.dart';

/// «О приложении» (Спасибо + Boosty) is hidden for now: the owner is rethinking support (2026-10-25).
const _showAboutSection = false;

/// The developer's page (owner's decision 2026-10-13).
final _developerPage = Uri.parse('https://boosty.to/tony_vinsenty');

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final attempts = ref.watch(attemptsProvider).value ?? const [];
    final current = attempts.where((a) => a.endedAt == null).firstOrNull;
    return TabPage(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, sosClearance),
        children: [
          _Group(
            title: l.settingsAttempt,
            children: [
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
                trailing: const Icon(Icons.chevron_right),
                onTap: () => HistoryScreen.open(context),
              ),
              if (current != null)
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: Text(l.settingsHabits),
                  subtitle: Text(l.settingsHabitsHint),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editHabits(context, ref, current),
                ),
            ],
          ),
          _Group(
            title: l.settingsSos,
            children: [
              ListTile(
                leading: const Icon(Icons.air),
                title: Text(l.settingsSosExercise),
                subtitle: Text(l.sosExerciseName(ref.watch(sosExerciseProvider).name)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showSosExercisePicker(context, ref),
              ),
            ],
          ),
          _Group(
            title: l.settingsRating,
            children: [
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: Text(l.privacyTitle),
                subtitle: Text(l.settingsPrivacyHint),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => PrivacyScreen.open(context),
              ),
            ],
          ),
          _Group(
            title: l.settingsNotifications,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_none),
                title: Text(l.settingsNotificationsMilestones),
                subtitle: Text(l.settingsNotificationsHint),
                value: ref.watch(notificationsEnabledProvider),
                onChanged: (on) => ref.read(notificationsEnabledProvider.notifier).set(on),
              ),
              ..._diaryReminder(context, ref),
            ],
          ),
          _Group(
            title: l.settingsAppearance,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Row(
                      spacing: 16,
                      children: [
                        Icon(Icons.palette_outlined, color: theme.colorScheme.onSurfaceVariant),
                        Expanded(child: Text(l.settingsThemeMode, style: theme.textTheme.bodyLarge)),
                      ],
                    ),
                    AppSegments<ThemeMode>(
                      options: [
                        for (final m in const [ThemeMode.system, ThemeMode.dark, ThemeMode.light])
                          (m, l.themeModeName(m.name)),
                      ],
                      selected: ref.watch(themeModeProvider),
                      onChanged: (m) => ref.read(themeModeProvider.notifier).set(m),
                    ),
                    const SizedBox(height: 6),
                    Text(l.settingsPalette, style: theme.textTheme.labelMedium),
                    const _PalettePicker(),
                  ],
                ),
              ),
              const _AppIconPicker(),
            ],
          ),
          if (_showAboutSection)
            _Group(
              title: l.settingsAbout,
              children: [
                ListTile(
                  leading: const Icon(Icons.favorite_outline),
                  title: Text(l.thanksRow),
                  subtitle: Text(l.thanksRowHint),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ThanksScreen.open(context, _developerPage),
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(l.settingsDeveloper),
                  subtitle: Text(l.settingsDeveloperHint),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => launchUrl(_developerPage, mode: LaunchMode.externalApplication),
                ),
              ],
            ),
          _Group(
            title: l.settingsData,
            children: [
              ListTile(
                leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
                title: Text(l.settingsReset, style: TextStyle(color: theme.colorScheme.error)),
                subtitle: Text(l.settingsResetHint),
                onTap: () => _confirmReset(context, ref),
              ),
            ],
          ),
          const _Version(),
        ],
      ),
    );
  }

  /// Switch for «Дневник самочувствия» reminders; once on, how often and at what time.
  List<Widget> _diaryReminder(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final r = ref.watch(diaryReminderProvider);
    void set(DiaryReminder value) => ref.read(diaryReminderProvider.notifier).set(value);
    return [
      SwitchListTile(
        secondary: const Icon(Icons.edit_calendar_outlined),
        title: Text(l.settingsDiaryReminder),
        subtitle: Text(l.settingsDiaryReminderHint),
        value: r.enabled,
        onChanged: (on) => set(r.copyWith(enabled: on)),
      ),
      if (r.enabled) ...[
        ListTile(
          contentPadding: const EdgeInsets.only(left: 56, right: 16),
          title: Text(l.settingsDiaryPeriod),
          subtitle: Text(l.diaryPeriod('${r.periodDays}')),
          onTap: () async {
            final days = await showDialog<int>(
              context: context,
              builder: (context) => SimpleDialog(
                title: Text(l.settingsDiaryPeriod),
                children: [
                  RadioGroup<int>(
                    groupValue: r.periodDays,
                    onChanged: (v) => Navigator.pop(context, v),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final d in DiaryReminder.periods)
                          RadioListTile<int>(value: d, title: Text(l.diaryPeriod('$d'))),
                      ],
                    ),
                  ),
                ],
              ),
            );
            if (days != null) set(r.copyWith(periodDays: days));
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.only(left: 56, right: 16),
          title: Text(l.settingsDiaryTime),
          subtitle: Text(r.time.format(context)),
          onTap: () async {
            final time = await showWheelTimePicker(context, initialTime: r.time, title: l.settingsDiaryTime);
            if (time != null) set(r.copyWith(time: time));
          },
        ),
      ],
    ];
  }

  /// «Мои привычки»: edits the smoking habits of the current attempt; savings are recalculated from them.
  Future<void> _editHabits(BuildContext context, WidgetRef ref, Attempt current) async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final saved = AppLocalizations.of(context).settingsHabitsSaved;
    final products = await OnboardingScreen.editProducts(
      context,
      productsOf(ref.read(productsProvider).value ?? const [], current.id),
    );
    if (products == null) return;
    await ref.read(databaseProvider).replaceProducts(current.id, products);
    showToastWith(messenger, theme, saved);
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

/// A titled group of settings on one card, rows separated by thin lines.
class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            // Rows paint their ripple on this layer, above the card colour.
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  for (final (i, c) in children.indexed) ...[
                    if (i > 0)
                      Divider(height: 1, indent: 56, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
                    c,
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// «Версия 0.1.0 (сборка 6)» at the very bottom of the settings.
class _Version extends StatelessWidget {
  const _Version();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, info) => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Text(
          info.hasData ? AppLocalizations.of(context).settingsVersion(info.data!.version, info.data!.buildNumber) : '',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

/// «Значок приложения»: four launcher icons to choose from, like in Telegram.
class _AppIconPicker extends ConsumerWidget {
  const _AppIconPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selected = ref.watch(appIconProvider);
    final ios = theme.platform == TargetPlatform.iOS;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            spacing: 16,
            children: [
              Icon(Icons.apps_outlined, color: theme.colorScheme.onSurfaceVariant),
              Expanded(child: Text(l.settingsAppIcon, style: theme.textTheme.bodyLarge)),
            ],
          ),
          Row(
            children: [
              for (final (i, v) in AppIconVariant.values.indexed)
                Expanded(
                  child: Center(
                    child: _AppIconTile(
                      variant: v,
                      label: l.appIconOption(i + 1),
                      selected: v == selected,
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await ref.read(appIconProvider.notifier).set(v);
                        if (!ok) showToastWith(messenger, theme, l.appIconFailed, icon: Icons.error_outline);
                      },
                    ),
                  ),
                ),
            ],
          ),
          Text(
            ios ? l.settingsAppIconHintIos : l.settingsAppIconHintAndroid,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _AppIconTile extends StatelessWidget {
  const _AppIconTile({required this.variant, required this.label, required this.selected, required this.onTap});

  final AppIconVariant variant;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: selected ? scheme.primary : Colors.transparent, width: 2.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(variant.preview, width: 60, height: 60),
              ),
            ),
            Positioned(
              right: -4,
              bottom: -4,
              child: AnimatedScale(
                scale: selected ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.surfaceContainerLow, width: 2),
                  ),
                  child: Icon(Icons.check, size: 16, color: scheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Six colour themes: 6 swatches in a row, or 3 × 2 when the row gets tight (narrow screen, large font).
class _PalettePicker extends ConsumerWidget {
  const _PalettePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    final selected = ref.watch(appPaletteProvider);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = AppPalette.values.length;
        final perRow = constraints.maxWidth / count >= 58 * textScale ? count : count ~/ 2;
        final width = constraints.maxWidth / perRow;
        return Wrap(
          runSpacing: 12,
          children: [
            for (final p in AppPalette.values)
              SizedBox(
                width: width,
                child: _PaletteSwatch(
                  scheme: ColorScheme.fromSeed(
                    seedColor: p.seed,
                    brightness: brightness,
                    dynamicSchemeVariant: p.variant,
                  ),
                  label: l.paletteName(p.name),
                  selected: p == selected,
                  onTap: () => ref.read(appPaletteProvider.notifier).set(p),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({required this.scheme, required this.label, required this.selected, required this.onTap});

  /// The scheme this swatch would switch to (not the current one).
  final ColorScheme scheme;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            spacing: 6,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: selected ? scheme.primary : Colors.transparent, width: 2.5),
                ),
                // Light container with the main colour in the middle: how cards and buttons will look.
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                    child: AnimatedOpacity(
                      opacity: selected ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.check, size: 16, color: scheme.onPrimary),
                    ),
                  ),
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
