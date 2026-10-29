import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

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
  final _inputFocusNode = FocusNode();
  final _scroll = ScrollController();
  int _limit = _page;
  String? _pendingImage;
  final List<ChatMessage> _failedMessages = [];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_loadMore);
    ref.listenManual(chatProvider(widget.chatId), (_, next) {
      final last = next.value?.last;
      final at = last?.at;
      final seen = ref.read(chatReadProvider)[widget.chatId];
      if (at != null) {
        if (seen == null || at.isAfter(seen)) ref.read(chatReadProvider.notifier).markRead(widget.chatId, at);
        unawaited(ref.read(chatServiceProvider).markRead(widget.chatId).catchError((_) {}));
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocusNode.unfocus();
    _inputFocusNode.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Older messages are fetched when the user scrolls close to the oldest loaded one.
  void _loadMore() {
    if (_scroll.position.extentAfter > 400) return;
    final loaded = ref.read(messagesProvider((chatId: widget.chatId, limit: _limit))).value?.length ?? 0;
    if (loaded >= _limit) setState(() => _limit += _page);
  }

  void _send(Chat? chat, String me, {String? image}) {
    final text = _input.text.trim();
    if (text.isEmpty && image == null) return;
    final other = directOther(widget.chatId, me);
    final friend = other == null ? null : ref.read(friendProfileProvider(other)).value;
    _input.clear();
    setState(() => _pendingImage = null);
    // Offline, the message waits in the phone and goes out with the connection; only a refusal is reported.
    unawaited(
      ref
          .read(chatServiceProvider)
          .send(
            widget.chatId,
            text,
            chat: chat,
            friend: friend == null ? null : (friend.uid, friend.nick),
            image: image,
          )
          .catchError((_) {
            if (mounted) {
              setState(() {
                _failedMessages.insert(
                  0,
                  ChatMessage(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    from: me,
                    text: text,
                    image: image,
                    at: DateTime.now(),
                    failed: true,
                  ),
                );
              });
            }
            if (mounted) showOfflineToast(context);
            return '';
          }),
    );
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _attachImage() async {
    final l = AppLocalizations.of(context);
    await _hideKeyboard();
    if (!mounted) return;
    final attach = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.image_outlined),
          title: Text(l.chatAttachImage),
          onTap: () => Navigator.pop(context, true),
        ),
      ),
    );
    if (attach != true || !mounted) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 100,
    );
    if (picked == null) return;
    try {
      final source = await picked.readAsBytes();
      final compressed = await _compressChatImage(source);
      if (mounted) setState(() => _pendingImage = base64Encode(compressed));
    } catch (_) {
      if (mounted) showToast(context, l.chatImageCompressFailed, icon: Icons.image_not_supported_outlined);
    }
  }

  Future<void> _hideKeyboard() async {
    _inputFocusNode.unfocus();
    try {
      await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    } catch (_) {
      // The focus node has already been cleared; hiding the platform keyboard is best-effort.
    }
  }

  Future<Uint8List> _compressChatImage(Uint8List source) async {
    Uint8List? smallest;
    for (final edge in [1920, 1600, 1280, 1024, 800, 640, 512]) {
      for (final quality in [85, 70, 55]) {
        final compressed = await FlutterImageCompress.compressWithList(
          source,
          minWidth: edge,
          minHeight: edge,
          quality: quality,
          format: CompressFormat.jpeg,
          keepExif: false,
        );
        smallest = Uint8List.fromList(compressed);
        if (smallest.lengthInBytes <= maxChatImageBytes) return smallest;
      }
    }
    if (smallest != null && smallest.lengthInBytes <= maxChatImageBytes) return smallest;
    throw StateError('Could not compress image below the Firestore message limit');
  }

  void _retry(ChatMessage message) {
    setState(() => _failedMessages.removeWhere((m) => m.id == message.id));
    _input.text = message.text;
    _send(
      ref.read(chatProvider(widget.chatId)).value,
      ref.read(authUserProvider).value?.uid ?? '',
      image: message.image,
    );
  }

  Future<void> _delete(Chat chat) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.chatDeleteTitle),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.chatDelete)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(chatServiceProvider).leave(chat).timeout(const Duration(seconds: 20));
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) showOfflineToast(context);
    }
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
              [] when _failedMessages.isEmpty => _Note(canWrite ? l.chatFirstMessage(title) : ''),
              final list => ListView.builder(
                controller: _scroll,
                reverse: true,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                itemCount: list.length + _failedMessages.length,
                itemBuilder: (context, i) {
                  if (i < _failedMessages.length) {
                    final message = _failedMessages[i];
                    return _MessageItem(chat: shown, me: me, message: message, onRetry: () => _retry(message));
                  }
                  final j = i - _failedMessages.length;
                  return _MessageItem(
                    chat: shown,
                    me: me,
                    message: list[j],
                    older: j + 1 < list.length ? list[j + 1] : null,
                    newer: j > 0 ? list[j - 1] : null,
                  );
                },
              ),
            },
          ),
          if (canWrite)
            _InputBar(
              controller: _input,
              focusNode: _inputFocusNode,
              image: _pendingImage == null ? null : base64Decode(_pendingImage!),
              onAttach: _attachImage,
              onClearImage: () => setState(() => _pendingImage = null),
              onSend: () => _send(chat, me, image: _pendingImage),
            )
          else if (chat != null || other != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  spacing: 8,
                  children: [
                    Text(
                      l.chatNotFriends(title),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    // The friend deleted their account: only the user is left, the chat can go.
                    if (chat != null && chat.members.length == 1)
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                        onPressed: () => _delete(chat),
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l.chatDelete),
                      ),
                  ],
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
  const _MessageItem({
    required this.chat,
    required this.me,
    required this.message,
    this.older,
    this.newer,
    this.onRetry,
  });

  final Chat chat;
  final String me;
  final ChatMessage message;
  final ChatMessage? older;
  final ChatMessage? newer;
  final VoidCallback? onRetry;

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
      final readMap = mine ? ref.watch(chatReadsProvider(chat.id)).value ?? const {} : const <String, DateTime>{};
      final otherMembers = chat.members.where((uid) => uid != me);
      final read =
          message.at != null &&
          otherMembers.any((uid) {
            final at = readMap[uid];
            return at != null && !at.isBefore(message.at!);
          });
      final bubble = _Bubble(
        message: message,
        mine: mine,
        sender: showSender && runStart ? name : null,
        read: read,
        onRetry: onRetry,
      );
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
  const _Bubble({required this.message, required this.mine, required this.read, this.sender, this.onRetry});

  final ChatMessage message;
  final bool mine;
  final String? sender;
  final bool read;
  final VoidCallback? onRetry;

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
                if (message.imageBytes case final bytes?)
                  Padding(
                    padding: EdgeInsets.only(bottom: message.text.isEmpty ? 0 : 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(bytes, width: 240, height: 240, fit: BoxFit.contain),
                    ),
                  ),
                if (message.text.isNotEmpty) Text(message.text, style: theme.textTheme.bodyLarge?.copyWith(color: fg)),
                Align(
                  alignment: Alignment.centerRight,
                  widthFactor: 1,
                  // Not yet on the server: a clock instead of the time.
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (at == null && message.pending)
                        Icon(Icons.schedule, size: 12, color: fg.withValues(alpha: 0.6))
                      else
                        Text(
                          DateFormat('HH:mm', 'ru').format(at ?? DateTime.now()),
                          style: theme.textTheme.labelSmall?.copyWith(color: fg.withValues(alpha: 0.6)),
                        ),
                      if (mine) ...[
                        const SizedBox(width: 4),
                        if (message.failed)
                          InkWell(
                            onTap: onRetry,
                            child: Icon(Icons.priority_high, size: 15, color: scheme.error),
                          )
                        else if (!message.pending && at != null)
                          Icon(
                            read ? Icons.done_all : Icons.done,
                            size: 15,
                            color: read ? scheme.primary : fg.withValues(alpha: 0.6),
                          ),
                      ],
                    ],
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
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.image,
    required this.onAttach,
    required this.onClearImage,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Uint8List? image;
  final VoidCallback onAttach;
  final VoidCallback onClearImage;
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
              IconButton(onPressed: onAttach, tooltip: l.chatAttach, icon: const Icon(Icons.attach_file)),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (image != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(image!, width: 54, height: 54, fit: BoxFit.cover),
                            ),
                            IconButton(onPressed: onClearImage, icon: const Icon(Icons.close)),
                          ],
                        ),
                      ),
                    TextField(
                      controller: controller,
                      focusNode: focusNode,
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, value, _) => IconButton.filled(
                  tooltip: l.chatSend,
                  onPressed: value.text.trim().isEmpty && image == null ? null : onSend,
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
