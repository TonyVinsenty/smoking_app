import 'package:flutter/material.dart';

import '../../content/content.dart';
import '../format.dart';

/// Round achievement badge: a solid metallic medal when earned, a faded lock otherwise.
class BadgeIcon extends StatelessWidget {
  const BadgeIcon({super.key, required this.achievement, required this.unlocked, required this.size});

  final Achievement achievement;
  final bool unlocked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!unlocked) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6), width: 2),
        ),
        child: Icon(Icons.lock_outline, size: size * 0.4, color: scheme.outline.withValues(alpha: 0.6)),
      );
    }
    final color = tierColor(achievement.tier);
    final light = Color.lerp(color, Colors.white, 0.45)!;
    final dark = Color.lerp(color, Colors.black, 0.25)!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [light, color, dark]),
        border: Border.all(color: light, width: size * 0.05),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: size * 0.18, offset: Offset(0, size * 0.05)),
        ],
      ),
      child: Icon(contentIcon(achievement.icon), size: size * 0.5, color: Colors.white),
    );
  }
}
