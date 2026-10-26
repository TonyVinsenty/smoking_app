import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/widgets/cards.dart';
import '../../app/widgets/toast.dart';
import '../../content/content.dart';
import '../../data/social.dart';
import '../../l10n/app_localizations.dart';
import 'chat_screen.dart';
import 'social_widgets.dart';

/// A friend's page: photo, name, «Написать» and only the stats they chose to show. The menu removes the friend.
class FriendPage extends ConsumerWidget {
  const FriendPage({super.key, required this.uid});

  final String uid;

  static Future<void> open(BuildContext context, String uid) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => FriendPage(uid: uid)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profile = ref.watch(friendProfileProvider(uid));
    final friend = profile.value;
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (friend != null)
            PopupMenuButton<void>(
              itemBuilder: (_) => [
                PopupMenuItem(onTap: () => _remove(context, ref, friend), child: Text(l.friendRemoveMenu)),
              ],
            ),
        ],
      ),
      body: switch (friend) {
        _ when profile.isLoading => const Center(child: CircularProgressIndicator()),
        null => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(l.friendGone, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          ),
        ),
        final f => ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            Center(
              child: FriendAvatar(nick: f.nick, uid: f.uid, size: 112),
            ),
            const SizedBox(height: 14),
            Text(f.nick, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 14),
            Center(
              child: FilledButton.tonalIcon(
                onPressed: () => ChatScreen.openDirect(context, ref, f.uid),
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(l.friendWrite),
              ),
            ),
            const SizedBox(height: 24),
            if (f.shared.isEmpty)
              AppCard(
                tone: CardTone.tip,
                child: Text(l.friendShowsNothing(f.nick), style: theme.textTheme.bodyMedium),
              )
            else
              _StatGrid(values: f.shared),
          ],
        ),
      },
    );
  }

  Future<void> _remove(BuildContext context, WidgetRef ref, SocialProfile friend) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.socialRemoveTitle(friend.nick)),
        content: Text(l.socialRemoveText),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.socialRemove)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(socialServiceProvider).removeFriend(friend.uid).timeout(const Duration(seconds: 20));
      if (context.mounted) Navigator.pop(context);
    } catch (_) {
      if (context.mounted) showToast(context, l.socialOffline, icon: Icons.cloud_off);
    }
  }
}

/// Shared stats as tiles, two per row (one per row with a large system font).
class _StatGrid extends ConsumerWidget {
  const _StatGrid({required this.values});

  final Map<ShareField, int> values;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final content = ref.watch(contentProvider).value;
    final tiles = [
      for (final MapEntry(key: f, value: v) in values.entries)
        switch (f) {
          ShareField.xp => _StatTile(
            icon: Icons.trending_up,
            value: content == null ? formatNumber(v) : l.friendStatLevel(content.levelFor(v).$1.level),
            label: l.friendStatXp(formatNumber(v)),
          ),
          ShareField.badges => _StatTile(icon: Icons.emoji_events_outlined, value: '$v', label: l.friendStatBadges(v)),
          ShareField.days => _StatTile(icon: Icons.smoke_free, value: '$v', label: l.friendStatDays(v)),
          ShareField.money => _StatTile(
            icon: Icons.savings_outlined,
            value: l.money(formatNumber(v)),
            label: l.friendStatMoney,
            reward: true,
          ),
        },
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final perRow = MediaQuery.textScalerOf(context).scale(1) > 1.4 ? 1 : 2;
        final width = (box.maxWidth - 12 * (perRow - 1)) / perRow;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [for (final t in tiles) SizedBox(width: width, child: t)],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.value, required this.label, this.reward = false});

  final IconData icon;
  final String value;
  final String label;
  final bool reward;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = reward ? AppColors.of(context).onRewardContainer : theme.colorScheme.primary;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Icon(icon, color: color),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(color: color, fontFeatures: tabular),
          ),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
