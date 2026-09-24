import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/content.dart';
import '../data/providers.dart';
import '../domain/achievements.dart';
import '../features/health/achievement_celebration.dart';
import '../features/health/health_screen.dart';
import '../features/home/home_screen.dart';
import '../features/knowledge/knowledge_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/sos/sos_screen.dart';
import '../l10n/app_localizations.dart';

/// Main screen with the bottom navigation bar. Also unlocks achievements as conditions are met.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;
  bool _unlocking = false;

  /// "achievementId@attemptId" already written, so a badge is not reported twice before the DB stream catches up.
  final _reported = <String>{};

  static const _screens = [HomeScreen(), HealthScreen(), KnowledgeScreen(), LeaderboardScreen(), SettingsScreen()];

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).achNewMany(retro))));
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
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      // Slightly see-through so it does not hide the content it floats over.
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8),
        elevation: 2,
        highlightElevation: 4,
        onPressed: () => SosScreen.open(context),
        icon: const Icon(Icons.air),
        label: Text(l.sosButton),
      ),
      // Tab labels keep their size with «Крупный текст», otherwise «Настройки» does not fit.
      bottomNavigationBar: MediaQuery.withNoTextScaling(
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l.tabHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_outline),
              selectedIcon: const Icon(Icons.favorite),
              label: l.tabHealth,
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book),
              label: l.tabKnowledge,
            ),
            NavigationDestination(
              icon: const Icon(Icons.emoji_events_outlined),
              selectedIcon: const Icon(Icons.emoji_events),
              label: l.tabLeaderboard,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l.tabSettings,
            ),
          ],
        ),
      ),
    );
  }
}
