import 'package:flutter/material.dart';

import '../../app/widgets/tab_page.dart';
import '../../l10n/app_localizations.dart';

/// «Рейтинг»: not built yet (needs the server in phase 3). An honest empty state instead of a blank tab.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return TabPage(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 96),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Podium(),
              const SizedBox(height: 28),
              Text(l.leaderboardTitle, textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(
                l.leaderboardText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Text(
                l.leaderboardSoon,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small podium with a sprout on the top step.
class _Podium extends StatelessWidget {
  const _Podium();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget step(double height, Color color) => Container(
      width: 56,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
    );
    return Column(
      children: [
        Icon(Icons.spa, size: 44, color: scheme.primary),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            step(56, scheme.secondaryContainer),
            step(84, scheme.primaryContainer),
            step(42, scheme.secondaryContainer),
          ],
        ),
      ],
    );
  }
}
