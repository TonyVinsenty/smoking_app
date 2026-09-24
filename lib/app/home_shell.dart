import 'package:flutter/material.dart';

import '../features/health/health_screen.dart';
import '../features/home/home_screen.dart';
import '../features/knowledge/knowledge_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/sos/sos_screen.dart';
import '../l10n/app_localizations.dart';

/// Main screen with the bottom navigation bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [HomeScreen(), HealthScreen(), KnowledgeScreen(), LeaderboardScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
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
