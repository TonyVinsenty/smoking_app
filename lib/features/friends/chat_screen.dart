import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/widgets/toast.dart';
import '../../data/chat.dart';
import '../../data/social.dart';
import '../../l10n/app_localizations.dart';
import 'chats_tab.dart';
import 'friend_page.dart';
import 'group_info_screen.dart';

/// One conversation: bubbles from the bottom up, day chips, group events as grey lines, the input below.
/// Opening it marks the chat as read (and keeps it read while it is open).
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId});

  final String chatId;

  static Future<void> open(BuildContext context, String chatId) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)));

  /// The one-to-one chat with a friend (created with the first message).
  static Future<void> openDirect(BuildContext context, WidgetRef ref, String friendUid) {
    final me = ref.read(authUserProvider).value?.uid;
    if (me == null) return Future.value();
    return open(context, directChatId(me, friendUid));
  }

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  static const _page = 50;

  final _input = TextEditingController();
  final _scroll = ScrollController();
  int _limit = _page;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_loadMore);
    ref.listenManual(chatProvider(widget.chatId), (_, next) {
      final at = next.value?.last?.at;
      if (at != null) ref.read(chatReadProvider.notifier).markRead(widget.chatId, at);
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Older messages are fetched when the user scrolls close to the oldest loaded one.
  void _loadMore() {
    if (_scroll.position.extentAfter > 400) return;
    final loaded = ref.read(messagesProvider((chatId: widget.chatId, limit: _limit))).value?.length ?? 0;
    if (loaded >= _limit) setState(() => _limit += _page);
  }

  void _send(Chat? chat, String me) {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final other = directOther(widget.chatId, me);
    final friend = other == null ? null : ref.read(friendProfileProvider(other)).value;
    _input.clear();
    // Offline, the message waits in the phone and goes out with the connection; only a refusal is reported.
    unawaited(
      ref
          .read(chatServiceProvider)
          .send(widget.chatId, text, chat: chat, friend: friend == null ? null : (friend.uid, friend.nick))
          .catchError((_) {
            if (mounted) showOfflineToast(context);
          }),
    );
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final me = ref.watch(authUserProvider).value?.uid ?? '';
    final chatValue = ref.watch(chatProvider(widget.chatId));
    final chat = chatValue.value;
    final other = chat?.otherThan(me) ?? directOther(widget.chatId, me);
    // Messages of a chat that does not exist yet cannot be read (only members can), and there are none.
    final messages = chatValue.hasValue && chat == null
        ? const <ChatMessage>[]
        : ref.watch(messagesProvider((chatId: widget.chatId, limit: _limit))).value;
    final canWrite = chat != null ? (chat.group || isFriend(ref, other ?? '')) : other != null && isFriend(ref, other);
    // A one-to-one chat that does not exist yet still needs a name: the friend's.
    final draft = Chat(id: widget.chatId, members: [me, ?other], group: false, names: const {});
    final shown = chat ?? draft;
    final title = chatTitle(ref, l, shown, me);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: switch (shown) {
            Chat(group: true) => () => GroupInfoScreen.open(context, widget.chatId),
            _ when other != null && isFriend(ref, other) => () => FriendPage.open(context, other),
            _ => null,
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              spacing: 12,
              children: [
                ChatAvatar(chat: shown, size: 38),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
                      if (shown.group)
                        Text(
                          l.groupMembers(shown.members.length),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: switch (messages) {
              null when chatValue.hasError => _Note(l.socialOffline),
              null => const Center(child: CircularProgressIndicator()),
              [] => _Note(canWrite ? l.chatFirstMessage(title) : ''),
              final list => ListView.builder(
                controller: _scroll,
                reverse: true,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                itemCount: list.length,
                itemBuilder: (context, i) => _MessageItem(
                  chat: shown,
                  me: me,
                  message: list[i],
                  older: i + 1 < list.length ? list[i + 1] : null,
                  newer: i > 0 ? list[i - 1] : null,
                ),
              ),
            },
          ),
          if (canWrite)
            _InputBar(controller: _input, onSend: () => _send(chat, me))
          else if (chat != null || other != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Text(
                  l.chatNotFriends(title),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The friend of a one-to-one chat, read from its id ("uidA_uidB").
String? directOther(String chatId, String me) {
  final parts = chatId.split('_');
  if (parts.length != 2 || !parts.contains(me)) return null;
  return parts.firstWhere((u) => u != me, orElse: () => me);
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// A message with what goes above it: the day chip when the day changes, the sender's name in a group
/// at the start of their run.
class _MessageItem extends ConsumerWidget {
  const _MessageItem({required this.chat, required this.me, required this.message, this.older, this.newer});

  final Chat chat;
  final String me;
  final ChatMessage message;
  final ChatMessage? older;
  final ChatMessage? newer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final at = message.at ?? DateTime.now();
    final newDay = older == null || !_sameDay(older!.at ?? DateTime.now(), at);
    final mine = message.from == me;
    final runStart = newDay || older!.from != message.from || older!.event != null;
    final runEnd = newer == null || newer!.from != message.from || newer!.event != null;
    final showSender = chat.group && !mine && message.event == null;
    final name = memberName(ref, l, chat, message.from);

    final Widget body;
    if (message.event != null) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        child: Text(
          eventText(l, message, name, mine: mine),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      );
    } else {
      final bubble = _Bubble(message: message, mine: mine, sender: showSender && runStart ? name : null);
      body = Padding(
        padding: EdgeInsets.only(top: runStart ? 8 : 2),
        child: Row(
          mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 8,
          children: [
            // In a group, others' runs end with their avatar, as in messengers.
            if (showSender) runEnd ? MemberAvatar(chat: chat, uid: message.from, size: 30) : const SizedBox(width: 30),
            Flexible(child: bubble),
          ],
        ),
      );
    }
    return Column(
      children: [
        if (newDay)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
              child: Text(dayLabel(l, at), style: theme.textTheme.labelMedium),
            ),
          ),
        body,
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine, this.sender});

  final ChatMessage message;
  final bool mine;
  final String? sender;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = mine ? scheme.onPrimaryContainer : scheme.onSurface;
    final at = message.at;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
      child: Material(
        color: mine ? scheme.primaryContainer : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(mine ? 18 : 6),
          bottomRight: Radius.circular(mine ? 6 : 18),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: message.text));
            showToast(context, l.chatCopied, icon: Icons.copy);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 12, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sender != null) Text(sender!, style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary)),
                Text(message.text, style: theme.textTheme.bodyLarge?.copyWith(color: fg)),
                Align(
                  alignment: Alignment.centerRight,
                  widthFactor: 1,
                  // Not yet on the server: a clock instead of the time.
                  child: at == null
                      ? Icon(Icons.schedule, size: 12, color: fg.withValues(alpha: 0.6))
                      : Text(
                          DateFormat('HH:mm', 'ru').format(at),
                          style: theme.textTheme.labelSmall?.copyWith(color: fg.withValues(alpha: 0.6)),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 8,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [LengthLimitingTextInputFormatter(maxMessageLength)],
                  decoration: InputDecoration(
                    hintText: l.chatInputHint,
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, value, _) => IconButton.filled(
                  tooltip: l.chatSend,
                  onPressed: value.text.trim().isEmpty ? null : onSend,
                  icon: const Icon(Icons.send),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
