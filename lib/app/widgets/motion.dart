import 'package:flutter/material.dart';

/// [duration], or zero when the phone asks to remove animations.
Duration motion(BuildContext context, Duration duration) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;

/// A number that runs up from zero when it first appears and glides to every new value after that.
class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 900),
  });

  final double value;
  final Widget Function(BuildContext context, double value) builder;
  final Duration duration;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value),
    duration: motion(context, duration),
    curve: Curves.easeOutCubic,
    builder: (context, v, _) => builder(context, v),
  );
}

/// A progress bar that fills from empty when it appears and moves smoothly when the value changes.
class GrowBar extends StatelessWidget {
  const GrowBar({
    super.key,
    required this.value,
    this.minHeight = 8,
    this.color,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 900),
  });

  final double value;
  final double minHeight;
  final Color? color;
  final Color? backgroundColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
    duration: motion(context, duration),
    curve: Curves.easeOutCubic,
    builder: (context, v, _) => LinearProgressIndicator(
      value: v,
      minHeight: minHeight,
      borderRadius: BorderRadius.circular(minHeight / 2),
      color: color,
      backgroundColor: backgroundColor,
    ),
  );
}
