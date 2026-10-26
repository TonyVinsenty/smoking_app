import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/widgets/cards.dart';
import '../../app/widgets/sos_fab.dart';
import '../../app/widgets/toast.dart';
import '../../data/chat.dart';
import '../../data/social.dart';
import '../../l10n/app_localizations.dart';
import 'chat_screen.dart';
import 'social_widgets.dart';

/// «Друзья» → «Чаты»: conversations, the latest first, with unread counters. Below — writing to a friend
/// and starting a group.
class ChatsTab extends ConsumerWidget {
  const ChatsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final chats = ref.watch(chatsProvider).value ?? const [];
    final hasFriends = (ref.watch(friendIdsProvider).value ?? const []).isNotEmpty;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, sosClearance),
      children: [
        if (chats.isNotEmpty) ...[
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(children: [for (final c in chats) _ChatRow(chat: c)]),
          ),
          const SizedBox(height: 16),
        ] else ...[
          AppCard(
            tone: CardTone.tip,
            child: Text(hasFriends ? l.chatsEmpty : l.chatsNoFriends, style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(height: 16),
        ],
        if (hasFriends) ...[
          FilledButton.tonalIcon(
            onPressed: () async {
              final picked = await showFriendPicker(context, title: l.chatPickFriend);
              if (picked != null && context.mounted) ChatScreen.openDirect(context, ref, picked.people.keys.first);
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(l.chatWriteFriend),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _newGroup(context, ref),
            icon: const Icon(Icons.group_add_outlined),
            label: Text(l.chatNewGroup),
          ),
          const SizedBox(height: 16),
          Text(
            l.chatsNoPush,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  Future<void> _newGroup(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final picked = await showFriendPicker(
      context,
      title: l.groupPickTitle,
      max: maxChatMembers - 1,
      withName: true,
      button: l.groupCreate,
    );
    if (picked == null || !context.mounted) return;
    try {
      final id = await ref
          .read(chatServiceProvider)
          .createGroup(picked.people, picked.name)
          .timeout(const Duration(seconds: 20));
      if (context.mounted) ChatScreen.open(context, id);
    } catch (_) {
      if (context.mounted) showOfflineToast(context);
    }
  }
}

class _ChatRow extends ConsumerWidget {
  const _ChatRow({required this.chat});

  final Chat chat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final me = ref.watch(authUserProvider).value?.uid ?? '';
    final unread = ref.watch(unreadCountProvider(chat.id)).value ?? 0;
    final last = chat.last;
    final muted = theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: () => ChatScreen.open(context, chat.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          spacing: 14,
          children: [
            ChatAvatar(chat: chat, size: 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    chatTitle(ref, l, chat, me),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (last != null)
                    Text(
                      lastLine(ref, l, chat, last, me),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: unread > 0 ? theme.colorScheme.onSurface : muted,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 6,
              children: [
                if (last?.at != null)
                  Text(listTime(l, last!.at!), style: theme.textTheme.labelSmall?.copyWith(color: muted)),
                if (unread > 0) Badge.count(count: unread, backgroundColor: theme.colorScheme.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A friend's photo for a one-to-one chat, a group icon for a group.
class ChatAvatar extends ConsumerWidget {
  const ChatAvatar({super.key, required this.chat, this.size = 40});

  final Chat chat;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final me = ref.watch(authUserProvider).value?.uid ?? '';
    final other = chat.otherThan(me);
    if (other != null) return MemberAvatar(chat: chat, uid: other, size: size);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: scheme.secondaryContainer, shape: BoxShape.circle),
      child: Icon(Icons.groups, size: size * 0.55, color: scheme.onSecondaryContainer, semanticLabel: l.chatNewGroup),
    );
  }
}

/// A chat member's avatar; the photo only of friends (others' photos cannot be read).
class MemberAvatar extends ConsumerWidget {
  const MemberAvatar({super.key, required this.chat, required this.uid, this.size = 40});

  final Chat chat;
  final String uid;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final me = ref.watch(authUserProvider).value?.uid;
    final visible = uid == me || isFriend(ref, uid);
    return FriendAvatar(nick: memberName(ref, l, chat, uid), uid: visible ? uid : null, size: size);
  }
}

bool isFriend(WidgetRef ref, String uid) => (ref.watch(friendIdsProvider).value ?? const []).contains(uid);

/// A member's name: a friend's current one, the user's own, otherwise the one kept in the chat.
String memberName(WidgetRef ref, AppLocalizations l, Chat chat, String uid) {
  final me = ref.watch(myProfileProvider).value;
  if (me != null && uid == ref.watch(authUserProvider).value?.uid) return me.nick;
  if (isFriend(ref, uid)) {
    final nick = ref.watch(friendProfileProvider(uid)).value?.nick;
    if (nick != null) return nick;
  }
  return chat.names[uid] ?? '…';
}

/// The friend's name for a one-to-one chat; for a group — its title or the members' names.
String chatTitle(WidgetRef ref, AppLocalizations l, Chat chat, String me) {
  final other = chat.otherThan(me);
  if (other != null) return memberName(ref, l, chat, other);
  if (chat.title?.isNotEmpty ?? false) return chat.title!;
  return [for (final u in chat.members) memberName(ref, l, chat, u)].join(', ');
}

/// "Вы: текст", "Аня: текст" (groups), just "текст" (from the friend), or an event line
/// (a one-to-one chat is left only when the friend deletes their account).
String lastLine(WidgetRef ref, AppLocalizations l, Chat chat, ChatMessage last, String me) {
  if (!chat.group && last.event == ChatEvent.left) return l.chatAccountDeleted;
  if (last.event != null) return eventText(l, last, memberName(ref, l, chat, last.from), mine: last.from == me);
  if (last.from == me) return l.chatYou(last.text);
  return chat.group ? l.chatFrom(memberName(ref, l, chat, last.from), last.text) : last.text;
}

String eventText(AppLocalizations l, ChatMessage m, String nick, {required bool mine}) => switch (m.event!) {
  ChatEvent.created => mine ? l.chatEventCreatedMe : l.chatEventCreated(nick),
  ChatEvent.added => mine ? l.chatEventAddedMe(m.text) : l.chatEventAdded(nick, m.text),
  ChatEvent.left => mine ? l.chatEventLeftMe : l.chatEventLeft(nick),
  ChatEvent.renamed when m.text.isEmpty => mine ? l.chatEventUntitledMe : l.chatEventUntitled(nick),
  ChatEvent.renamed => mine ? l.chatEventRenamedMe(m.text) : l.chatEventRenamed(nick, m.text),
};

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// "14:05" today, «Вчера», otherwise "12 окт.".
String listTime(AppLocalizations l, DateTime at) {
  final now = DateTime.now();
  if (_sameDay(at, now)) return DateFormat('HH:mm', 'ru').format(at);
  if (_sameDay(at, now.subtract(const Duration(days: 1)))) return l.chatYesterday;
  return DateFormat('d MMM', 'ru').format(at);
}

/// «Сегодня», «Вчера», "12 октября", "12 октября 2025" — the chip between days in a chat.
String dayLabel(AppLocalizations l, DateTime at) {
  final now = DateTime.now();
  if (_sameDay(at, now)) return l.chatToday;
  if (_sameDay(at, now.subtract(const Duration(days: 1)))) return l.chatYesterday;
  return DateFormat(at.year == now.year ? 'd MMMM' : 'd MMMM yyyy', 'ru').format(at);
}

void showOfflineToast(BuildContext context) =>
    showToast(context, AppLocalizations.of(context).socialOffline, icon: Icons.cloud_off);

/// Friends picked in [showFriendPicker] (uid → name) and the group name typed there.
typedef PickedFriends = ({Map<String, String> people, String name});

/// Picks one friend (tap) or, with [max] > 1, several (checkboxes and a [button]); [withName] adds a group
/// name field. Friends in [exclude] are not offered.
Future<PickedFriends?> showFriendPicker(
  BuildContext context, {
  required String title,
  int max = 1,
  bool withName = false,
  String? button,
  Set<String> exclude = const {},
}) => showModalBottomSheet<PickedFriends>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (context) => _FriendPicker(title: title, max: max, withName: withName, button: button, exclude: exclude),
);

class _FriendPicker extends ConsumerStatefulWidget {
  const _FriendPicker({
    required this.title,
    required this.max,
    required this.withName,
    required this.button,
    required this.exclude,
  });

  final String title;
  final int max;
  final bool withName;
  final String? button;
  final Set<String> exclude;

  @override
  ConsumerState<_FriendPicker> createState() => _FriendPickerState();
}

class _FriendPickerState extends ConsumerState<_FriendPicker> {
  final _name = TextEditingController();
  final _picked = <String, String>{};

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ids = ref.watch(friendIdsProvider).value ?? const [];
    final friends = [
      for (final id in ids)
        if (!widget.exclude.contains(id)) ?ref.watch(friendProfileProvider(id)).value,
    ]..sort((a, b) => a.nick.toLowerCase().compareTo(b.nick.toLowerCase()));
    final multi = widget.max > 1;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
            child: Text(widget.title, style: theme.textTheme.titleLarge),
          ),
          if (multi)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                l.groupPickHint(widget.max),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          if (friends.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Text(l.groupNoMoreFriends, style: theme.textTheme.bodyMedium),
            ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final f in friends)
                  multi
                      ? CheckboxListTile(
                          value: _picked.containsKey(f.uid),
                          onChanged: _picked.containsKey(f.uid) || _picked.length < widget.max
                              ? (on) => setState(() => on! ? _picked[f.uid] = f.nick : _picked.remove(f.uid))
                              : null,
                          secondary: FriendAvatar(nick: f.nick, uid: f.uid),
                          title: Text(f.nick, maxLines: 1, overflow: TextOverflow.ellipsis),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                        )
                      : ListTile(
                          leading: FriendAvatar(nick: f.nick, uid: f.uid),
                          title: Text(f.nick, maxLines: 1, overflow: TextOverflow.ellipsis),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                          onTap: () => Navigator.pop(context, (people: {f.uid: f.nick}, name: '')),
                        ),
              ],
            ),
          ),
          if (widget.withName)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: TextField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [LengthLimitingTextInputFormatter(maxGroupTitleLength)],
                decoration: InputDecoration(labelText: l.groupNameLabel),
              ),
            ),
          if (multi && friends.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: FilledButton(
                onPressed: _picked.isEmpty
                    ? null
                    : () => Navigator.pop(context, (people: Map.of(_picked), name: _name.text.trim())),
                child: Text(widget.button ?? l.done),
              ),
            ),
          if (!multi) const SizedBox(height: 16),
        ],
      ),
    );
  }
}
