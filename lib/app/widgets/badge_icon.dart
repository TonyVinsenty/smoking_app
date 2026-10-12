import 'package:flutter/material.dart';

import '../../content/content.dart';
import '../format.dart';

/// Round achievement badge.
///
/// Earned: a medal — a soft gradient disc with a white icon, a thin gap and a rim in the rarity colour.
/// Not earned yet: a quiet disc with an outlined icon and a thin ring in the rarity colour that fills
/// with [progress], so the player sees how far the next reward is.
/// With [pulse] an earned medal softly breathes with its glow (used in the details sheet).
class BadgeIcon extends StatefulWidget {
  const BadgeIcon({
    super.key,
    required this.achievement,
    required this.unlocked,
    required this.size,
    this.progress,
    this.pulse = false,
  });

  final Achievement achievement;
  final bool unlocked;
  final double size;

  /// 0…1 of the way to a badge not earned yet; null hides the ring.
  final double? progress;
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
      _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final color = tierColor(widget.achievement.tier);

    if (!widget.unlocked) {
      final ring = size * 0.05;
      return SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.all(ring * 1.6),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dark ? scheme.surfaceContainerHighest : scheme.surfaceContainerHigh,
                ),
                child: Icon(
                  contentIcon(widget.achievement.icon, filled: false),
                  size: size * 0.42,
                  color: Color.lerp(color, scheme.onSurfaceVariant, 0.45),
                ),
              ),
            ),
            CircularProgressIndicator(
              value: (widget.progress ?? 0).clamp(0.0, 1.0),
              strokeWidth: ring,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: color.withValues(alpha: 0.18),
            ),
          ],
        ),
      );
    }

    final top = Color.lerp(color, Colors.white, 0.42)!;
    Widget medal(double glow) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Rim in the rarity colour around a thin gap.
        border: Border.all(color: color.withValues(alpha: 0.6), width: size * 0.035),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: (dark ? 0.22 : 0.32) + 0.18 * glow),
            blurRadius: size * (0.16 + 0.14 * glow),
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.055),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(center: const Alignment(-0.3, -0.4), radius: 0.95, colors: [top, color]),
        ),
        child: Icon(contentIcon(widget.achievement.icon), size: size * 0.44, color: Colors.white),
      ),
    );
    final glow = _glow;
    if (glow == null || MediaQuery.disableAnimationsOf(context)) return medal(0);
    return AnimatedBuilder(animation: glow, builder: (context, _) => medal(Curves.easeInOut.transform(glow.value)));
  }
}
