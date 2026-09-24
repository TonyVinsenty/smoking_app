import 'package:flutter/material.dart';

import '../../content/content.dart';
import '../format.dart';

/// Round achievement badge: a solid metallic medal when earned, a faded lock otherwise.
/// With [pulse] an earned badge softly breathes with its glow (used in the details sheet).
class BadgeIcon extends StatefulWidget {
  const BadgeIcon({
    super.key,
    required this.achievement,
    required this.unlocked,
    required this.size,
    this.pulse = false,
  });

  final Achievement achievement;
  final bool unlocked;
  final double size;
  final bool pulse;

  @override
  State<BadgeIcon> createState() => _BadgeIconState();
}

class _BadgeIconState extends State<BadgeIcon> with SingleTickerProviderStateMixin {
  AnimationController? _glow;

  @override
  void initState() {
    super.initState();
    if (widget.pulse && widget.unlocked) {
      _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glow?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final scheme = Theme.of(context).colorScheme;
    if (!widget.unlocked) {
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
    final color = tierColor(widget.achievement.tier);
    final light = Color.lerp(color, Colors.white, 0.45)!;
    final dark = Color.lerp(color, Colors.black, 0.25)!;
    Widget medal(double glow) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [light, color, dark]),
        border: Border.all(color: light, width: size * 0.05),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45 + 0.25 * glow),
            blurRadius: size * (0.18 + 0.3 * glow),
            spreadRadius: size * 0.08 * glow,
            offset: Offset(0, size * 0.05 * (1 - glow)),
          ),
        ],
      ),
      child: Icon(contentIcon(widget.achievement.icon), size: size * 0.5, color: Colors.white),
    );
    final glow = _glow;
    if (glow == null) return medal(0);
    return AnimatedBuilder(
      animation: glow,
      builder: (context, _) => medal(Curves.easeInOut.transform(glow.value)),
    );
  }
}
