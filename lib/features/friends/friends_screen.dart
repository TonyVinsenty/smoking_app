import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/tab_page.dart';
import '../../data/chat.dart';
import '../../data/social.dart';
import '../../l10n/app_localizations.dart';
import 'chats_tab.dart';
import 'friends_tab.dart';
import 'social_widgets.dart';

/// «Друзья»: a small circle of friends added by code, plus one-to-one and group chats.
class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authUserProvider);
    final profile = ref.watch(myProfileProvider);
    if (auth.isLoading || (auth.value != null && profile.isLoading)) {
      return const TabPage(body: Center(child: CircularProgressIndicator()));
    }
    final me = profile.value;
    if (me == null) {
      return TabPage(
        body: NameEditor(
          header: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(l.friendsIntro, style: Theme.of(context).textTheme.bodyMedium),
          ),
          buttonText: l.socialJoinButton,
          onSubmit: (nick) => ref.read(socialServiceProvider).join(nick),
        ),
      );
    }
    return TabPage(
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: l.friendsTabMine),
                Tab(child: _ChatsTabLabel(text: l.friendsTabChats)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  const FriendsTab(),
                  const ChatsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// «Чаты» with the number of unread messages next to it.
class _ChatsTabLabel extends ConsumerWidget {
  const _ChatsTabLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(totalUnreadProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
        if (unread > 0) Badge.count(count: unread, backgroundColor: Theme.of(context).colorScheme.primary),
      ],
    );
  }
}
