import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/motion.dart';
import '../../app/widgets/sos_fab.dart';
import '../../app/widgets/choice.dart';
import '../../app/widgets/cards.dart';
import '../../app/format.dart';
import '../../app/widgets/metric_text.dart';
import '../../content/content.dart';
import '../../data/providers.dart';
import '../../data/settings.dart';
import '../../domain/stats.dart';
import 'health_common.dart';
import '../../l10n/app_localizations.dart';

enum _Filter { passed, nearest, all }

/// «Этапы»: recovery milestones as a winding trail with a «Вы здесь» marker.
class MilestonesTab extends ConsumerStatefulWidget {
  const MilestonesTab({super.key});

  @override
  ConsumerState<MilestonesTab> createState() => _MilestonesTabState();
}

class _MilestonesTabState extends ConsumerState<MilestonesTab> with SingleTickerProviderStateMixin {
  var _filter = _Filter.nearest;
  final _hereKey = GlobalKey();

  /// The walked part of the trail draws itself up to «Вы здесь», once a day when the tab opens.
  late final _draw = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  bool _drawChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tabs are built ahead of time and hidden: wait until this one is actually on screen.
    if (_drawChecked || !TickerMode.valuesOf(context).enabled) return;
    _drawChecked = true;
    final prefs = ref.read(prefsProvider);
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    if (prefs.getString('trailDrawnOn') == today || MediaQuery.disableAnimationsOf(context)) {
      _draw.value = 1;
    } else {
      prefs.setString('trailDrawnOn', today);
      _draw.forward();
    }
  }

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  /// How much of row [k] is drawn (0…1): rows up to the marker fill one after another.
  double _rowDraw(int k, List<int?> entries) {
    final here = entries.indexOf(null);
    if (here < 0 || k > here) return 1;
    return (_draw.value * (here + 1) - k).clamp(0.0, 1.0);
  }

  void _setFilter(_Filter f) {
    setState(() => _filter = f);
    // In the long «Все» list jump to the marker instead of the very first milestone.
    if (f == _Filter.all) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _hereKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(ctx, alignment: 0.3, duration: const Duration(milliseconds: 400));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final content = ref.watch(contentProvider).value;
    final current = ref.watch(currentAttemptProvider).value;
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    if (content == null) return const Center(child: CircularProgressIndicator());

    final elapsed = current == null ? Duration.zero : attemptDuration(current, now);
    final minutes = elapsed.inSeconds / 60;
    final milestones = content.milestones;
    final reached = milestones.where((m) => minutes >= m.afterMinutes).length;
    final next = reached < milestones.length ? milestones[reached] : null;

    // Trail entries: milestone indexes, with null for the «Вы здесь» marker.
    final entries = <int?>[
      for (var i = 0; i < milestones.length; i++) ...[
        if (i == reached && _filter != _Filter.passed) null,
        if (switch (_filter) {
          _Filter.passed => i < reached,
          _Filter.nearest => i >= reached - 1 && i < reached + 3,
          _Filter.all => true,
        })
          i,
      ],
      if (reached == milestones.length || _filter == _Filter.passed) null,
    ];

    // Rebuilt while the trail draws itself (only at the first opening of the day).
    return AnimatedBuilder(
      animation: _draw,
      builder: (context, _) => SingleChildScrollView(
        // Room below the last card so it can scroll clear of the SOS button.
        padding: const EdgeInsets.fromLTRB(16, 16, 16, sosClearance),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Summary(
              reached: reached,
              total: milestones.length,
              next: next,
              minutes: minutes,
              hasAttempt: current != null,
            ),
            const SizedBox(height: 16),
            AppSegments<_Filter>(
              options: [
                (_Filter.passed, l.healthFilterPassed),
                (_Filter.nearest, l.healthFilterNearest),
                (_Filter.all, l.healthFilterAll),
              ],
              selected: _filter,
              onChanged: _setFilter,
            ),
            const SizedBox(height: 12),
            if (_filter == _Filter.passed && reached == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l.healthNonePassed, style: theme.textTheme.bodyLarge),
              ),
            for (final (k, e) in entries.indexed)
              e == null
                  ? _HereRow(
                      key: _hereKey,
                      draw: _rowDraw(k, entries),
                      label: l.healthSmokeFreeFor(formatElapsed(l, elapsed)),
                      hasAbove: k > 0,
                      hasBelow: k < entries.length - 1,
                    )
                  : _MilestoneRow(
                      milestone: milestones[e],
                      // Milestones sharing the same time all count from the previous distinct one.
                      segmentStart:
                          milestones
                              .take(e)
                              .map((m) => m.afterMinutes)
                              .where((t) => t < milestones[e].afterMinutes)
                              .lastOrNull ??
                          0,
                      minutes: minutes,
                      isNext: e == reached,
                      leftNode: e.isEven,
                      hasAbove: k > 0,
                      hasBelow: k < entries.length - 1,
                      draw: _rowDraw(k, entries),
                    ),
            const SizedBox(height: 24),
            const HealthDisclaimer(),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.reached,
    required this.total,
    required this.next,
    required this.minutes,
    required this.hasAttempt,
  });

  final int reached;
  final int total;
  final HealthMilestone? next;
  final double minutes;
  final bool hasAttempt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimaryContainer;
    final text = theme.textTheme.bodyMedium?.copyWith(color: color);
    return AppCard(
      tone: CardTone.hero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.healthPassedLabel, style: theme.textTheme.labelMedium?.copyWith(color: color)),
          CountUp(
            value: reached.toDouble(),
            builder: (context, v) => MetricText(l.bodyProgress(v.round(), total), color: color),
          ),
          const SizedBox(height: 12),
          GrowBar(value: reached / total, minHeight: 8),
          const SizedBox(height: 12),
          if (!hasAttempt)
            Text(l.healthNoAttempt, style: text)
          else ...[
            Text(
              next == null
                  ? l.healthAllPassed
                  : l.healthNext(formatRemaining(l, Duration(seconds: ((next!.afterMinutes - minutes) * 60).ceil()))),
              style: text,
            ),
            const SizedBox(height: 4),
            Text(minutes < 8 * 1440 ? l.healthFirstDays : l.healthFirstDaysDone, style: text),
          ],
        ],
      ),
    );
  }
}

/// Width of the trail column left of the cards; nodes sway between [_nodeLeft] and [_nodeRight].
const _trailWidth = 72.0;
const _nodeLeft = 24.0;
const _nodeRight = 48.0;
const _nodeY = 36.0;

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.milestone,
    required this.segmentStart,
    required this.minutes,
    required this.isNext,
    required this.leftNode,
    required this.hasAbove,
    required this.hasBelow,
    this.draw = 1,
  });

  final HealthMilestone milestone;

  /// How much of the walked trail in this row is drawn (0…1), for the drawing animation.
  final double draw;

  /// Previous milestone time: progress towards this one is counted from there.
  final int segmentStart;
  final double minutes;
  final bool isNext;
  final bool leftNode;
  final bool hasAbove;
  final bool hasBelow;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final m = milestone;
    final reached = minutes >= m.afterMinutes;
    final span = m.afterMinutes - segmentStart;
    final progress = span <= 0 ? 0.0 : ((minutes - segmentStart) / span).clamp(0.0, 1.0);
    final x = leftNode ? _nodeLeft : _nodeRight;

    Widget node = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: reached ? scheme.primary : scheme.surface,
        border: reached ? null : Border.all(color: isNext ? scheme.primary : scheme.outlineVariant, width: 2),
      ),
      child: Icon(
        reached ? Icons.check : categoryIcon(m.category),
        size: 22,
        color: reached ? scheme.onPrimary : (isNext ? scheme.primary : scheme.onSurfaceVariant),
      ),
    );
    if (reached) {
      node = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.6, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (_, s, child) => Transform.scale(scale: s, child: child),
        child: node,
      );
    }
    if (isNext) node = _Pulse(child: node);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _trailWidth,
            child: CustomPaint(
              painter: _TrailPainter(
                nodeX: x,
                solidAbove: reached,
                solidBelow: reached,
                hasAbove: hasAbove,
                hasBelow: hasBelow,
                solid: scheme.primary,
                dashed: scheme.outlineVariant,
                draw: draw,
              ),
              child: Stack(
                children: [Positioned(left: x - 22, top: _nodeY - 22, child: node)],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Opacity(
                opacity: reached || isNext ? 1 : 0.75,
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatPeriod(l, m.afterMinutes),
                        style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary),
                      ),
                      const SizedBox(height: 2),
                      WordFitText(
                        m.title,
                        // Screen minus list padding, the trail and the card padding.
                        width: MediaQuery.sizeOf(context).width - 32 - _trailWidth - 32,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(m.description, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      if (reached)
                        Text(l.healthReached, style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary))
                      else ...[
                        if (isNext) ...[GrowBar(value: progress, minHeight: 6), const SizedBox(height: 4)],
                        Text(
                          l.healthRemaining(
                            formatRemaining(l, Duration(seconds: ((m.afterMinutes - minutes) * 60).ceil())),
                          ),
                          style: theme.textTheme.labelMedium,
                        ),
                      ],
                      if (m.source != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          l.healthSource(m.source!),
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// «Вы здесь»: a glowing walker on the trail between the passed and the upcoming milestones.
class _HereRow extends StatelessWidget {
  const _HereRow({super.key, required this.label, required this.hasAbove, required this.hasBelow, this.draw = 1});

  final String label;

  /// The trail reaches the marker when this gets to 1; the marker then pops in.
  final double draw;
  final bool hasAbove;
  final bool hasBelow;

  @override
  Widget build(BuildContext context) {
    final appear = ((draw - 0.45) / 0.55).clamp(0.0, 1.0);
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const x = _trailWidth / 2;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _trailWidth,
            child: CustomPaint(
              painter: _TrailPainter(
                nodeX: x,
                solidAbove: true,
                solidBelow: false,
                hasAbove: hasAbove,
                hasBelow: hasBelow,
                solid: scheme.primary,
                dashed: scheme.outlineVariant,
                draw: draw,
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: x - 20,
                    top: _nodeY - 20,
                    // Pops in once the drawn line reaches it.
                    child: Transform.scale(
                      scale: Curves.easeOutBack.transform(appear),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primary,
                          boxShadow: [
                            BoxShadow(color: scheme.primary.withValues(alpha: 0.5), blurRadius: 16, spreadRadius: 4),
                          ],
                        ),
                        child: Icon(Icons.directions_walk, color: scheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 26),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Opacity(
                  opacity: appear,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.healthYouAreHere,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onPrimary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft ring that keeps growing and fading around the next milestone.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35 * (1 - _c.value)),
              spreadRadius: 12 * _c.value,
            ),
          ],
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// One row's piece of the winding trail: from the row's top centre to its node, then down to the bottom centre.
/// The walked part is solid, the part ahead is dashed.
class _TrailPainter extends CustomPainter {
  _TrailPainter({
    required this.nodeX,
    required this.solidAbove,
    required this.solidBelow,
    required this.hasAbove,
    required this.hasBelow,
    required this.solid,
    required this.dashed,
    this.draw = 1,
  });

  final double nodeX;

  /// Share of the solid (walked) line drawn so far: the upper half of the row first, then the lower.
  final double draw;
  final bool solidAbove;
  final bool solidBelow;
  final bool hasAbove;
  final bool hasBelow;
  final Color solid;
  final Color dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.width / 2;
    if (hasAbove) {
      final p = Path()
        ..moveTo(mid, 0)
        ..cubicTo(mid, _nodeY / 2, nodeX, _nodeY / 2, nodeX, _nodeY);
      _draw(canvas, p, solidAbove, (draw * 2).clamp(0.0, 1.0));
    }
    if (hasBelow) {
      final bend = (size.height - _nodeY) / 2;
      final p = Path()
        ..moveTo(nodeX, _nodeY)
        ..cubicTo(nodeX, _nodeY + bend, mid, size.height - bend, mid, size.height);
      _draw(canvas, p, solidBelow, (draw * 2 - 1).clamp(0.0, 1.0));
    }
  }

  void _draw(Canvas canvas, Path path, bool isSolid, double share) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = isSolid ? 4 : 3
      ..color = isSolid ? solid : dashed;
    if (isSolid) {
      if (share <= 0) return; // a zero-length round cap would still show as a dot
      for (final PathMetric metric in path.computeMetrics()) {
        canvas.drawPath(metric.extractPath(0, metric.length * share), paint);
      }
      return;
    }
    for (final PathMetric metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) =>
      old.draw != draw ||
      old.nodeX != nodeX ||
      old.solidAbove != solidAbove ||
      old.solidBelow != solidBelow ||
      old.hasAbove != hasAbove ||
      old.hasBelow != hasBelow ||
      old.solid != solid ||
      old.dashed != dashed;
}
