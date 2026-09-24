import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/content.dart';
import '../data/providers.dart';
import '../domain/achievements.dart';
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
    final due = dueAchievements(
      achievements: content.achievements,
      attempts: attempts,
      products: products,
      cravings: cravings,
      articlesRead: articles.length,
      unlocked: unlocked,
      now: DateTime.now(),
    ).where((a) => !_reported.contains('${a.id}@${current.id}')).toList();
    if (due.isEmpty) return;

    _unlocking = true;
    try {
      await ref.read(databaseProvider).unlockAchievements(due.map((a) => a.id), current.id);
      _reported.addAll(due.map((a) => '${a.id}@${current.id}'));
    } finally {
      _unlocking = false;
    }
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(due.length == 1 ? l.achNew(due.first.title, due.first.xp) : l.achNewMany(due.length))),
    );
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
      floatingActionButton: FloatingActionButton.extended(
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
