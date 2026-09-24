import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/format.dart';
import '../../app/widgets/badge_icon.dart';
import '../../content/content.dart';
import '../../l10n/app_localizations.dart';

/// Full-screen "new badge" moment: the medal pops in, rays spin behind it, sparkles fly out.
Future<void> showAchievementCelebration(BuildContext context, Achievement achievement) => showGeneralDialog<void>(
  context: context,
  barrierDismissible: true,
  barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  barrierColor: Colors.black54,
  transitionDuration: const Duration(milliseconds: 300),
  transitionBuilder: (context, animation, _, child) => FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
      child: child,
    ),
  ),
  pageBuilder: (context, _, _) => _Celebration(achievement: achievement),
);

class _Celebration extends StatefulWidget {
  const _Celebration({required this.achievement});

  final Achievement achievement;

  @override
  State<_Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<_Celebration> with TickerProviderStateMixin {
  late final _pop = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  late final _spin = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();

  late final _badgeScale = CurvedAnimation(
    parent: _pop,
    curve: const Interval(0.1, 0.75, curve: Curves.elasticOut),
  );
  late final _sparkles = CurvedAnimation(
    parent: _pop,
    curve: const Interval(0.2, 1, curve: Curves.easeOut),
  );
  late final _text = CurvedAnimation(
    parent: _pop,
    curve: const Interval(0.45, 0.9, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _pop.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final a = widget.achievement;
    final color = tierColor(a.tier);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Material(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.achCelebrateTitle,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                ),
                SizedBox(
                  width: 240,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Soft glow.
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [color.withValues(alpha: 0.45), color.withValues(alpha: 0)]),
                        ),
                      ),
                      // Slowly spinning rays.
                      RotationTransition(
                        turns: _spin,
                        child: Container(
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                for (var i = 0; i < 12; i++) ...[
                                  color.withValues(alpha: 0.28),
                                  color.withValues(alpha: 0),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _sparkles,
                        builder: (context, _) => Stack(
                          alignment: Alignment.center,
                          children: [
                            for (var i = 0; i < 10; i++)
                              Transform.translate(
                                offset: Offset.fromDirection(i * pi / 5 + 0.3, 30 + 80 * _sparkles.value),
                                child: Opacity(
                                  opacity: (1 - _sparkles.value).clamp(0.0, 1.0),
                                  child: Icon(Icons.star, size: i.isEven ? 16 : 11, color: color),
                                ),
                              ),
                          ],
                        ),
                      ),
                      ScaleTransition(
                        scale: _badgeScale,
                        child: BadgeIcon(achievement: a, unlocked: true, size: 112),
                      ),
                    ],
                  ),
                ),
                FadeTransition(
                  opacity: _text,
                  child: Column(
                    children: [
                      Text(a.title, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(a.description, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      Chip(label: Text('+${a.xp} XP')),
                      const SizedBox(height: 8),
                      FilledButton(onPressed: () => Navigator.pop(context), child: Text(l.achCelebrateOk)),
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
