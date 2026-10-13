import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'motion.dart';

/// The level number inside a ring that fills up towards the next level.
///
/// The ring fills from empty when it appears. On a new level it first fills to the end, then the number
/// changes and the ring starts again from the new progress.
class LevelRing extends StatefulWidget {
  const LevelRing({super.key, required this.level, required this.progress, this.size = 60});

  final int level;

  /// 0…1 of the way to the next level.
  final double progress;
  final double size;

  @override
  State<LevelRing> createState() => _LevelRingState();
}

class _LevelRingState extends State<LevelRing> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this);
  late Animation<double> _ring;
  late int _shown = widget.level;

  @override
  void initState() {
    super.initState();
    _ring = Tween(begin: 0.0, end: widget.progress).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.value == 0 && !_c.isAnimating) {
      _c.duration = motion(context, const Duration(milliseconds: 1100));
      _c.forward();
    }
  }

  @override
  void didUpdateWidget(LevelRing old) {
    super.didUpdateWidget(old);
    final from = _ring.value;
    if (widget.level > old.level) {
      // Level up: fill to the end, switch the number, then grow to the new progress.
      _ring = TweenSequence([
        TweenSequenceItem(
          tween: Tween(begin: from, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: widget.progress).chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 1,
        ),
      ]).animate(_c);
      _c.duration = motion(context, const Duration(milliseconds: 1600));
      void swap() {
        if (_c.value < 0.5) return;
        _c.removeListener(swap);
        if (mounted) setState(() => _shown = widget.level);
        HapticFeedback.mediumImpact();
      }

      _c.addListener(swap);
      _c.forward(from: 0);
    } else if (widget.progress != old.progress) {
      _ring = Tween(begin: from, end: widget.progress).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
      _c.duration = motion(context, const Duration(milliseconds: 400));
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _ring,
            builder: (context, _) => CircularProgressIndicator(
              value: _ring.value,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              color: scheme.primary,
              backgroundColor: scheme.primary.withValues(alpha: 0.14),
            ),
          ),
          Center(
            child: AnimatedSwitcher(
              duration: motion(context, const Duration(milliseconds: 350)),
              transitionBuilder: (child, a) => ScaleTransition(
                scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
                child: FadeTransition(opacity: a, child: child),
              ),
              child: Text(
                '$_shown',
                key: ValueKey(_shown),
                textScaler: TextScaler.noScaling,
                style: theme.textTheme.titleLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
