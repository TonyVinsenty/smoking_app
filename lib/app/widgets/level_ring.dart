import 'package:flutter/material.dart';

import 'motion.dart';

/// The level number inside a ring that fills up towards the next level.
class LevelRing extends StatelessWidget {
  const LevelRing({super.key, required this.level, required this.progress, this.size = 60});

  final int level;

  /// 0…1 of the way to the next level.
  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: motion(context, const Duration(milliseconds: 1100)),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => CircularProgressIndicator(
              value: v,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              color: scheme.primary,
              backgroundColor: scheme.primary.withValues(alpha: 0.14),
            ),
          ),
          Center(
            child: Text(
              '$level',
              textScaler: TextScaler.noScaling,
              style: theme.textTheme.titleLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
