import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/content.dart';
import 'notifications.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/sos_fab.dart';
import 'widgets/toast.dart';
import '../data/social.dart';
import '../data/providers.dart';
import '../domain/achievements.dart';
import '../features/health/achievement_celebration.dart';
import '../features/health/health_screen.dart';
import '../features/home/home_screen.dart';
import '../features/knowledge/knowledge_screen.dart';
import '../features/friends/friends_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/sos/sos_screen.dart';
import '../l10n/app_localizations.dart';

/// Main screen with the bottom navigation bar. Also unlocks achievements as conditions are met.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> with SingleTickerProviderStateMixin {
  int _index = 0;

  /// A short fade when switching tabs, instead of an abrupt jump.
  late final _tabFade = AnimationController(vsync: this, duration: const Duration(milliseconds: 220), value: 1);

  @override
  void dispose() {
    _tabFade.dispose();
    super.dispose();
  }

  /// SOS shows its label; it shrinks to a round button while the user scrolls down.
  bool _sosExtended = true;
  bool _unlocking = false;

  /// "achievementId@attemptId" already written, so a badge is not reported twice before the DB stream catches up.
  final _reported = <String>{};

  static const _screens = [HomeScreen(), HealthScreen(), KnowledgeScreen(), FriendsScreen(), SettingsScreen()];

  Future<void> _checkAchievements() async {
    if (_unlocking) return;
    final content = ref.read(contentProvider).value;
    final attempts = ref.read(attemptsProvider).value;
    final products = ref.read(productsProvider).value;
    final cravings = ref.read(cravingsProvider).value;
    final articles = ref.read(articlesReadProvider).value;
    final unlocked = ref.read(unlockedAchievementsProvider).value;
    if (content == null ||
        attempts == null ||
        products == null ||
        cravings == null ||
        articles == null ||
        unlocked == null) {
      return;
    }
    final current = attempts.where((a) => a.endedAt == null).firstOrNull;
    if (current == null) return;
    List<Achievement> dueAt(DateTime at) => dueAchievements(
      achievements: content.achievements,
      attempts: attempts,
      products: products,
      cravings: cravings,
      articlesReadAt: [for (final a in articles) a.readAt],
      unlocked: unlocked,
      now: at,
    );
    final now = DateTime.now();
    final due = dueAt(now).where((a) => !_reported.contains('${a.id}@${current.id}')).toList();
    if (due.isEmpty) return;

    _unlocking = true;
    try {
      await ref.read(databaseProvider).unlockAchievements(due.map((a) => a.id), current.id);
      _reported.addAll(due.map((a) => '${a.id}@${current.id}'));
    } finally {
      _unlocking = false;
    }
    if (!mounted) return;
    // Celebrate only badges earned just now; ones earned retroactively (quit date in the past,
    // app was closed) get a short note instead.
    final earlier = dueAt(now.subtract(const Duration(minutes: 5))).map((a) => a.id).toSet();
    var fresh = due.where((a) => !earlier.contains(a.id)).toList();
    if (fresh.length > 3) fresh = [];
    final retro = due.length - fresh.length;
    if (retro > 0) {
      showToast(context, AppLocalizations.of(context).achNewMany(retro), icon: Icons.emoji_events_outlined);
    }
    _unlocking = true; // no new checks while celebrating
    try {
      for (final a in fresh) {
        if (!mounted) return;
        await showAchievementCelebration(context, a);
      }
    } finally {
      _unlocking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listening also keeps every input loaded (the articles list is not shown anywhere yet).
    ref.listen(nowProvider, (_, _) => _checkAchievements());
    ref.listen(attemptsProvider, (_, _) => _checkAchievements());
    ref.listen(productsProvider, (_, _) => _checkAchievements());
    ref.listen(cravingsProvider, (_, _) => _checkAchievements());
    ref.listen(articlesReadProvider, (_, _) => _checkAchievements());
    ref.listen(unlockedAchievementsProvider, (_, _) => _checkAchievements());
    ref.listen(contentProvider, (_, _) => _checkAchievements());
    ref.watch(notificationSchedulerProvider);
    ref.watch(socialSyncProvider);
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SosScrollWatcher(
        onExtended: (on) {
          if (on != _sosExtended) setState(() => _sosExtended = on);
        },
        child: FadeTransition(
          opacity: Tween(begin: 0.35, end: 1.0).animate(CurvedAnimation(parent: _tabFade, curve: Curves.easeOut)),
          // Hidden tabs keep their state but pause their animations (and start them when shown).
          child: IndexedStack(
            index: _index,
            children: [for (final (i, s) in _screens.indexed) TickerMode(enabled: i == _index, child: s)],
          ),
        ),
      ),
      floatingActionButton: SosFab(
        extended: _sosExtended,
        label: l.sosButton,
        onPressed: () => SosScreen.open(context),
      ),
      // Tab labels keep their size with a large system font, otherwise «Настройки» does not fit.
      bottomNavigationBar: MediaQuery.withNoTextScaling(
        child: EvenBottomBar(
          selectedIndex: _index,
          onSelected: (i) => setState(() {
            if (i != _index && !MediaQuery.disableAnimationsOf(context)) _tabFade.forward(from: 0);
            _index = i;
            _sosExtended = true;
          }),
          items: [
            BarItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: l.tabHome),
            BarItem(
              icon: Icons.favorite_outline,
              selectedIcon: Icons.favorite,
              label: l.tabHealth,
              dot: ref.watch(diaryDueProvider),
            ),
            BarItem(icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book, label: l.tabKnowledge),
            BarItem(icon: Icons.people_outline, selectedIcon: Icons.people, label: l.tabFriends),
            BarItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: l.tabSettings),
          ],
        ),
      ),
    );
  }
}
