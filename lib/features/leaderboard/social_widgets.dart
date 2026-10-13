import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../app/widgets/cards.dart';
import '../../app/widgets/toast.dart';
import '../../content/content.dart';
import '../../data/social.dart';
import '../../l10n/app_localizations.dart';

final _fmt = NumberFormat('#,##0', 'ru');

/// "Тихий Кедр" → "ТК".
String initials(String nick) => nick.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join();

/// A round avatar with the nick's initials; the colour comes from the nick, so it is the same on every phone.
class FriendAvatar extends StatelessWidget {
  const FriendAvatar({super.key, required this.nick, this.size = 40, this.ring = false});

  final String nick;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = [
      (scheme.primaryContainer, scheme.onPrimaryContainer),
      (AppColors.of(context).rewardContainer, AppColors.of(context).onRewardContainer),
      (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      (scheme.secondaryContainer, scheme.onSecondaryContainer),
    ];
    final (bg, fg) = colors[nick.codeUnits.fold(0, (a, b) => a + b) % colors.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: ring ? Border.all(color: scheme.primary, width: 3) : null,
      ),
      child: Text(
        initials(nick),
        textScaler: TextScaler.noScaling,
        style: TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w700, color: fg, fontSize: size * 0.34),
      ),
    );
  }
}

/// A shared stat as a small pill: "Ур. 14 · 1 240 XP", "23 значка", "21 дн. без курения", "6 800 ₽ сэкономлено".
String shareChipText(AppLocalizations l, AppContent content, ShareField f, int v) => switch (f) {
  ShareField.xp => l.chipLevel(content.levelFor(v).$1.level, _fmt.format(v)),
  ShareField.badges => l.chipBadges(v),
  ShareField.days => l.chipDays(v),
  ShareField.money => l.chipMoney(l.money(_fmt.format(v))),
};

/// Short value for the leaderboard: "1 240 XP", "23 зн.", "21 дн.", "6 800 ₽".
String shareValueText(AppLocalizations l, ShareField f, int v) => switch (f) {
  ShareField.xp => l.valueXp(_fmt.format(v)),
  ShareField.badges => l.valueBadges(v),
  ShareField.days => l.valueDays(v),
  ShareField.money => l.money(_fmt.format(v)),
};

class StatPill extends StatelessWidget {
  const StatPill(this.text, {super.key, this.reward = false});

  final String text;
  final bool reward;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: reward ? c.rewardContainer : theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: reward ? c.onRewardContainer : theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// "Так вас видят друзья": the user's own card with only the stats they share.
class MyPreviewCard extends ConsumerWidget {
  const MyPreviewCard({super.key, required this.nick});

  final String nick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final content = ref.watch(contentProvider).value;
    final stats = ref.watch(myStatsProvider);
    final share = ref.watch(shareSettingsProvider);
    final shown = [
      for (final f in ShareField.values)
        if (share.contains(f)) f,
    ];
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 14,
        children: [
          FriendAvatar(nick: nick, size: 48),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(nick, style: theme.textTheme.titleMedium),
                if (content == null || stats == null || shown.isEmpty)
                  Text(l.privacyOnlyNick, style: theme.textTheme.bodySmall)
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final f in shown)
                        StatPill(shareChipText(l, content, f, stats.value(f)), reward: f == ShareField.money),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ready-made nicknames to pick from: six at a time, "Другие варианты" shows the next six.
class NickPicker extends ConsumerStatefulWidget {
  const NickPicker({super.key, required this.buttonText, required this.onSubmit, this.initial, this.header});

  final String Function(String nick) buttonText;
  final Future<void> Function(String nick) onSubmit;
  final String? initial;
  final Widget? header;

  @override
  ConsumerState<NickPicker> createState() => _NickPickerState();
}

class _NickPickerState extends ConsumerState<NickPicker> {
  List<String>? _all;
  int _page = 0;
  String? _nick;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final loaded = ref.watch(nicknamesProvider).value;
    if (loaded == null) return const Center(child: CircularProgressIndicator());
    _all ??= ([...loaded]..shuffle());
    final all = _all!;
    final options = [for (var i = 0; i < 6; i++) all[(_page * 6 + i) % all.length]];
    final nick = _nick ?? widget.initial ?? options.first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        ?widget.header,
        FriendAvatar(nick: nick, size: 64),
        const SizedBox(height: 16),
        Text(l.socialJoinTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(l.socialJoinText, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in options)
              ChoiceChip(label: Text(o), selected: o == nick, onSelected: (_) => setState(() => _nick = o)),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() {
              _page++;
              _nick = all[(_page * 6) % all.length];
            }),
            icon: const Icon(Icons.refresh),
            label: Text(l.socialJoinMore),
          ),
        ),
        const SizedBox(height: 12),
        Text(l.privacyPreview, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        MyPreviewCard(nick: nick),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _busy ? null : () => _submit(nick),
          child: _busy
              ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
              : Text(widget.buttonText(nick), textAlign: TextAlign.center),
        ),
      ],
    );
  }

  Future<void> _submit(String nick) async {
    setState(() => _busy = true);
    try {
      await widget.onSubmit(nick).timeout(const Duration(seconds: 20));
    } catch (_) {
      if (mounted) showToast(context, AppLocalizations.of(context).socialOffline, icon: Icons.cloud_off);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
