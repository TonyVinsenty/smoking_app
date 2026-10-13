import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/cards.dart';
import '../../app/format.dart';
import '../../app/widgets/badge_icon.dart';
import '../../content/content.dart';
import '../../data/providers.dart';
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

  @override
  void initState() {
    super.initState();
    // Felt in the hand together with the medal popping in.
    Future.delayed(const Duration(milliseconds: 250), HapticFeedback.mediumImpact);
  }

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
  late final _shine = CurvedAnimation(
    parent: _pop,
    curve: const Interval(0.45, 0.85, curve: Curves.easeInOut),
  );
  late final _xp = CurvedAnimation(
    parent: _pop,
    curve: const Interval(0.6, 1, curve: Curves.easeOutBack),
  );

  /// How bright the shine is: rarer badges sparkle more.
  static double _shineStrength(String tier) => switch (tier) {
    'common' => 0.35,
    'uncommon' => 0.45,
    'rare' => 0.6,
    'epic' => 0.75,
    _ => 0.9,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // «Remove animations» on the phone: show the final picture at once.
    if (MediaQuery.disableAnimationsOf(context)) {
      _pop.value = 1;
      _spin.stop();
    }
  }

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
                        child: Stack(
                          children: [
                            BadgeIcon(achievement: a, unlocked: true, size: 112, pulse: true),
                            // A glint sweeps across the medal once it has landed.
                            Positioned.fill(
                              child: ClipOval(
                                child: AnimatedBuilder(
                                  animation: _shine,
                                  builder: (context, _) => DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment(-1.6 + 3.2 * _shine.value, -1),
                                        end: Alignment(-0.6 + 3.2 * _shine.value, 1),
                                        colors: [
                                          Colors.white.withValues(alpha: 0),
                                          Colors.white.withValues(alpha: _shineStrength(a.tier)),
                                          Colors.white.withValues(alpha: 0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                      Text(
                        achievementDescription(
                          l,
                          a,
                          ProviderScope.containerOf(context, listen: false).read(mainProductProvider),
                        ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      // «+XP» rises into place.
                      FadeTransition(
                        opacity: _xp,
                        child: SlideTransition(
                          position: Tween(begin: const Offset(0, 0.8), end: Offset.zero).animate(_xp),
                          child: RewardPill('+${a.xp} XP'),
                        ),
                      ),
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
