import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/cards.dart';
import '../../app/widgets/sos_fab.dart';
import '../../app/widgets/toast.dart';
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
    final ids = ref.watch(friendIdsProvider).value ?? const [];
    final friends = [for (final id in ids) ?ref.watch(friendProfileProvider(id)).value]
      ..sort((a, b) => a.nick.toLowerCase().compareTo(b.nick.toLowerCase()));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, sosClearance),
      children: [
        for (final f in friends) ...[_FriendCard(friend: f), const SizedBox(height: 10)],
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

class _FriendCard extends StatelessWidget {
  const _FriendCard({required this.friend});

  final SocialProfile friend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      onTap: () => FriendPage.open(context, friend.uid),
      child: Row(
        spacing: 14,
        children: [
          FriendAvatar(nick: friend.nick, uid: friend.uid, size: 52),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(friend.nick, style: theme.textTheme.titleMedium),
                StatPills(values: friend.shared),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
        ],
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
