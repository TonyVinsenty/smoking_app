import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/cards.dart';
import '../../app/widgets/toast.dart';
import '../../data/social.dart';
import '../../l10n/app_localizations.dart';
import '../leaderboard/social_widgets.dart';

/// Settings → «Приватность»: what friends see (with a live preview), nickname, account deletion.
class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final me = ref.watch(myProfileProvider).value;
    final share = ref.watch(shareSettingsProvider);
    final fields = [
      (ShareField.xp, l.shareXp, l.shareXpHint),
      (ShareField.badges, l.shareBadges, l.shareBadgesHint),
      (ShareField.days, l.shareDays, l.shareDaysHint),
      (ShareField.money, l.shareMoney, l.shareMoneyHint),
    ];
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Scaffold(
      appBar: AppBar(title: Text(l.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            l.privacyPreview,
            style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          MyPreviewCard(nick: me?.nick ?? '—'),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (final (f, title, hint) in fields)
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: share.contains(f),
                    onChanged: (_) => ref.read(shareSettingsProvider.notifier).toggle(f),
                    title: Text(title),
                    subtitle: Text(hint),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(me == null ? l.privacyNotJoined : l.privacyServerNote, style: muted),
          ),
          if (me != null) ...[
            const SizedBox(height: 14),
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text(l.privacyNick),
                subtitle: Text(me.nick),
                trailing: TextButton(
                  onPressed: () => _changeNick(context, ref, me.nick),
                  child: Text(l.privacyChangeNick),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(l.privacyDeleteTitle, style: theme.textTheme.titleMedium),
                  Text(l.privacyDeleteText, style: muted),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                    onPressed: () => _delete(context, ref),
                    child: Text(l.privacyDeleteButton),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _changeNick(BuildContext context, WidgetRef ref, String current) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        final l = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(l.socialNickChangeTitle)),
          body: NickPicker(
            initial: current,
            buttonText: (_) => l.save,
            onSubmit: (nick) async {
              await ref.read(socialServiceProvider).changeNick(nick);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        );
      },
    ),
  );

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.privacyDeleteConfirm),
        content: Text(l.privacyDeleteText),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.privacyDeleteButton),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(socialServiceProvider).deleteAccount().timeout(const Duration(seconds: 30));
      if (context.mounted) showToast(context, l.privacyDeleted);
    } catch (_) {
      if (context.mounted) showToast(context, l.socialOffline, icon: Icons.cloud_off);
    }
  }
}
