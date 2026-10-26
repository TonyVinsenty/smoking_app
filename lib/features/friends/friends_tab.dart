import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/cards.dart';
import '../../app/widgets/sos_fab.dart';
import '../../app/widgets/toast.dart';
import '../../content/content.dart';
import '../../data/social.dart';
import '../../l10n/app_localizations.dart';
import 'add_friend_sheet.dart';
import 'friend_page.dart';
import 'social_widgets.dart';

/// «Друзья» → «Мои друзья»: everyone with what they share; tap opens their page. Below — adding a friend
/// and the user's own code.
class FriendsTab extends ConsumerWidget {
  const FriendsTab({super.key, required this.me});

  final SocialProfile me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ids = ref.watch(friendIdsProvider).value ?? const [];
    // Highest level first (those who hide it — after), then by name.
    final friends = [for (final id in ids) ?ref.watch(friendProfileProvider(id)).value]
      ..sort(
        (a, b) => (b.xp ?? -1) != (a.xp ?? -1)
            ? (b.xp ?? -1).compareTo(a.xp ?? -1)
            : a.nick.toLowerCase().compareTo(b.nick.toLowerCase()),
      );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, sosClearance),
      children: [
        // "Друзья 16", as in Steam.
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${l.tabFriends}  ', style: theme.textTheme.titleLarge),
                TextSpan(
                  text: '${ids.length}',
                  style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        if (friends.isNotEmpty) ...[
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(children: [for (final f in friends) _FriendRow(friend: f)]),
          ),
          const SizedBox(height: 16),
        ],
        if (ids.isEmpty) ...[
          AppCard(
            tone: CardTone.tip,
            child: Text(l.socialNoFriends, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        FilledButton.tonalIcon(
          onPressed: () => showAddFriendSheet(context),
          icon: const Icon(Icons.person_add_alt),
          label: Text(l.friendsAdd),
        ),
        const SizedBox(height: 16),
        _CodeCard(code: me.code),
      ],
    );
  }
}

/// One friend, Steam-style: photo, name, "Не курит 9 дней" under it, level in a ring on the right.
class _FriendRow extends ConsumerWidget {
  const _FriendRow({required this.friend});

  final SocialProfile friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final content = ref.watch(contentProvider).value;
    final xp = friend.xp;
    final days = friend.days;
    return InkWell(
      onTap: () => FriendPage.open(context, friend.uid),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          spacing: 14,
          children: [
            FriendAvatar(nick: friend.nick, uid: friend.uid, size: 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(friend.nick, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
                  if (days != null)
                    Text(
                      l.friendDaysLine(days),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                    ),
                ],
              ),
            ),
            if (xp != null && content != null) LevelBadge(level: content.levelFor(xp).$1.level),
          ],
        ),
      ),
    );
  }
}

/// "Мой код друга K7M4-Q2XP": tap the code to copy it.
class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pretty = formatCode(code);
    void copy() {
      Clipboard.setData(ClipboardData(text: pretty));
      showToast(context, l.socialCodeCopied, icon: Icons.copy);
    }

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: copy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.socialMyCode, style: theme.textTheme.labelMedium),
                  Text(
                    pretty,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          FilledButton.icon(onPressed: copy, icon: const Icon(Icons.copy, size: 18), label: Text(l.socialCopy)),
        ],
      ),
    );
  }
}
