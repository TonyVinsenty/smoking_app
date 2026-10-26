import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/cards.dart';
import '../../data/chat.dart';
import '../../data/social.dart';
import '../../l10n/app_localizations.dart';
import 'chats_tab.dart';
import 'friend_page.dart';

/// A group's page: its name (any member may change it), the members, adding friends, leaving.
class GroupInfoScreen extends ConsumerWidget {
  const GroupInfoScreen({super.key, required this.chatId});

  final String chatId;

  static Future<void> open(BuildContext context, String chatId) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => GroupInfoScreen(chatId: chatId)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final me = ref.watch(authUserProvider).value?.uid ?? '';
    final chat = ref.watch(chatProvider(chatId)).value;
    if (chat == null) return Scaffold(appBar: AppBar());
    // The user first, then the others by name.
    final others = [
      for (final u in chat.members)
        if (u != me) u,
    ]..sort((a, b) => memberName(ref, l, chat, a).toLowerCase().compareTo(memberName(ref, l, chat, b).toLowerCase()));
    final full = chat.members.length >= maxChatMembers;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Center(child: ChatAvatar(chat: chat, size: 96)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  chatTitle(ref, l, chat, me),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: l.groupRename,
                onPressed: () => _rename(context, ref, chat),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(l.groupMembers(chat.members.length), style: theme.textTheme.titleMedium),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (final u in [me, ...others])
                  ListTile(
                    leading: MemberAvatar(chat: chat, uid: u),
                    title: Text(
                      u == me ? '${memberName(ref, l, chat, u)} (${l.chatYouName})' : memberName(ref, l, chat, u),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: u == me || isFriend(ref, u) ? null : Text(l.groupNotFriendHint),
                    onTap: u != me && isFriend(ref, u) ? () => FriendPage.open(context, u) : null,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: full ? null : () => _add(context, ref, chat),
            icon: const Icon(Icons.person_add_alt),
            label: Text(l.groupAddMembers),
          ),
          if (full)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l.groupFull, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            ),
          const SizedBox(height: 10),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            onPressed: () => _leave(context, ref, chat),
            icon: const Icon(Icons.logout),
            label: Text(l.groupLeave),
          ),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Chat chat) async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController(text: chat.title ?? '');
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.groupRename),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [LengthLimitingTextInputFormatter(maxGroupTitleLength)],
          decoration: InputDecoration(labelText: l.groupNameLabel),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(l.save)),
        ],
      ),
    );
    if (title == null || title == (chat.title ?? '') || !context.mounted) return;
    await _run(context, ref.read(chatServiceProvider).rename(chat, title));
  }

  Future<void> _add(BuildContext context, WidgetRef ref, Chat chat) async {
    final l = AppLocalizations.of(context);
    final picked = await showFriendPicker(
      context,
      title: l.groupAddMembers,
      max: maxChatMembers - chat.members.length,
      button: l.groupAddButton,
      exclude: chat.members.toSet(),
    );
    if (picked == null || !context.mounted) return;
    await _run(context, ref.read(chatServiceProvider).addMembers(chat, picked.people));
  }

  Future<void> _leave(BuildContext context, WidgetRef ref, Chat chat) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.groupLeaveTitle),
        content: Text(l.groupLeaveText),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.groupLeaveConfirm)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    if (await _run(context, ref.read(chatServiceProvider).leave(chat)) && context.mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  /// Waits for the server; false (with a message) when it does not answer.
  Future<bool> _run(BuildContext context, Future<void> action) async {
    try {
      await action.timeout(const Duration(seconds: 20));
      return true;
    } catch (_) {
      if (context.mounted) showOfflineToast(context);
      return false;
    }
  }
}
