import 'package:flutter/material.dart';

/// [duration], or zero when the phone asks to remove animations.
Duration motion(BuildContext context, Duration duration) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;

/// Holds [value] at zero until the widget is actually on screen (tabs are built ahead of time and hidden),
/// so the run-up is seen rather than played invisibly.
mixin _OnScreen<T extends StatefulWidget> on State<T> {
  bool shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!shown && TickerMode.valuesOf(context).enabled) setState(() => shown = true);
  }
}

/// A number that runs up from zero when it first appears and glides to every new value after that.
class CountUp extends StatefulWidget {
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
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> with _OnScreen {
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: shown ? widget.value : 0),
    duration: motion(context, widget.duration),
    curve: Curves.easeOutCubic,
    builder: (context, v, _) => widget.builder(context, v),
  );
}

/// A progress bar that fills from empty when it appears and moves smoothly when the value changes.
class GrowBar extends StatefulWidget {
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
  State<GrowBar> createState() => _GrowBarState();
}

class _GrowBarState extends State<GrowBar> with _OnScreen {
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: shown ? widget.value.clamp(0.0, 1.0) : 0),
    duration: motion(context, widget.duration),
    curve: Curves.easeOutCubic,
    builder: (context, v, _) => LinearProgressIndicator(
      value: v,
      minHeight: widget.minHeight,
      borderRadius: BorderRadius.circular(widget.minHeight / 2),
      color: widget.color,
      backgroundColor: widget.backgroundColor,
    ),
  );
}

/// Screens that already showed their entrance wave in this run of the app.
final _wavedScreens = <String>{};

/// Fades and lifts [child] into place, a little later for each next [index]: a soft wave from top to bottom.
/// Plays only the first time [screen] is shown after the app starts.
class StaggerIn extends StatefulWidget {
  const StaggerIn({super.key, required this.screen, required this.index, required this.child});

  final String screen;
  final int index;
  final Widget child;

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final first = !_wavedScreens.contains(widget.screen);
    if (!first || MediaQuery.disableAnimationsOf(context) || widget.index > 7) {
      _c.value = 1;
      return;
    }
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _c.forward();
    });
    // The whole screen counts as shown once its first card starts.
    if (widget.index == 0) Future.delayed(const Duration(seconds: 1), () => _wavedScreens.add(widget.screen));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: SlideTransition(
      position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(_a),
      child: widget.child,
    ),
  );
}
