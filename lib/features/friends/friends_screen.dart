import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/tab_page.dart';
import '../../data/social.dart';
import '../../l10n/app_localizations.dart';
import 'friends_tab.dart';
import 'rating_tab.dart';
import 'social_widgets.dart';

/// «Друзья»: a small circle of friends added by code. Before joining, the user picks a name;
/// after that — «Мои друзья» (people and their pages) and «Рейтинг» (the podium).
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
                Tab(text: l.friendsTabRating),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  FriendsTab(me: me),
                  RatingTab(me: me),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
