import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/settings.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';

/// «Хочу курить»: trigger → calming exercise + tips → "тяга прошла".
class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const SosScreen()));

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

/// Bottom sheet to choose the SOS exercise; the choice is remembered for next time.
Future<void> showSosExercisePicker(BuildContext context, WidgetRef ref) {
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final current = ref.read(sosExerciseProvider);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(l.sosPickExercise, style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final e in SosExercise.values)
              ListTile(
                leading: Icon(_exerciseIcon(e)),
                title: Text(l.sosExerciseName(e.name)),
                subtitle: Text(l.sosExerciseDesc(e.name)),
                trailing: e == current ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () {
                  ref.read(sosExerciseProvider.notifier).set(e);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

IconData _exerciseIcon(SosExercise e) => switch (e) {
  SosExercise.breathing => Icons.air,
  SosExercise.countdown => Icons.hourglass_bottom,
  SosExercise.grounding => Icons.spa_outlined,
};

class _SosScreenState extends ConsumerState<SosScreen> {
  bool _askTrigger = true;
  Trigger? _trigger;

  Future<void> _resisted() async {
    final attempt = ref.read(currentAttemptProvider).value;
    if (attempt != null) {
      await ref.read(databaseProvider).logCraving(attemptId: attempt.id, resisted: true, trigger: _trigger);
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final text = AppLocalizations.of(context).sosResistedToast(xpPerResistedCraving);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.sosButton)),
      body: SafeArea(child: _askTrigger ? _triggerStep(l) : _ExerciseStep(onResisted: _resisted)),
    );
  }

  Widget _triggerStep(AppLocalizations l) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.sosTriggerTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(l.sosTriggerHint),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in Trigger.values)
              ActionChip(
                label: Text(l.triggerName(t.name)),
                onPressed: () => setState(() {
                  _trigger = t;
                  _askTrigger = false;
                }),
              ),
          ],
        ),
        const Spacer(),
        Center(
          child: TextButton(onPressed: () => setState(() => _askTrigger = false), child: Text(l.sosSkip)),
        ),
      ],
    ),
  );
}

class _ExerciseStep extends ConsumerStatefulWidget {
  const _ExerciseStep({required this.onResisted});

  final VoidCallback onResisted;

  @override
  ConsumerState<_ExerciseStep> createState() => _ExerciseStepState();
}

class _ExerciseStepState extends ConsumerState<_ExerciseStep> {
  final _random = Random();
  int _tipIndex = -1;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final exercise = ref.watch(sosExerciseProvider);
    final tips = ref.watch(contentProvider).value?.sosTips ?? const [];
    if (_tipIndex < 0 && tips.isNotEmpty) _tipIndex = _random.nextInt(tips.length);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          TextButton.icon(
            icon: Icon(_exerciseIcon(exercise)),
            label: Text('${l.sosExerciseName(exercise.name)} · ${l.sosChangeExercise}'),
            onPressed: () => showSosExercisePicker(context, ref),
          ),
          Text(l.sosWaveHint, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: switch (exercise) {
                SosExercise.breathing => const _CalmBreathing(key: ValueKey(SosExercise.breathing)),
                SosExercise.countdown => const _Countdown(key: ValueKey(SosExercise.countdown)),
                SosExercise.grounding => const _Grounding(key: ValueKey(SosExercise.grounding)),
              },
            ),
          ),
          if (tips.isNotEmpty)
            Card(
              color: theme.colorScheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tips[_tipIndex], style: theme.textTheme.bodyLarge),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: Text(l.sosAnotherTip),
                        onPressed: () => setState(
                          () => _tipIndex = (_tipIndex + 1 + _random.nextInt(tips.length - 1)) % tips.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.fitness_center),
              label: Text(l.sosResisted),
              onPressed: widget.onResisted,
            ),
          ),
        ],
      ),
    );
  }
}

/// In 4 s, out 6 s, no hold: a soft circle grows and shrinks.
class _CalmBreathing extends StatefulWidget {
  const _CalmBreathing({super.key});

  @override
  State<_CalmBreathing> createState() => _CalmBreathingState();
}

class _CalmBreathingState extends State<_CalmBreathing> with SingleTickerProviderStateMixin {
  static const _inSec = 4, _outSec = 6;
  static const _cycle = _inSec + _outSec;

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: _cycle),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value * _cycle;
          final inhale = t < _inSec;
          final scale = inhale
              ? 0.55 + 0.45 * Curves.easeInOut.transform(t / _inSec)
              : 1.0 - 0.45 * Curves.easeInOut.transform((t - _inSec) / _outSec);
          final color = theme.colorScheme.primaryContainer;
          return Container(
            width: 240 * scale,
            height: 240 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Soft edge instead of a hard circle.
              gradient: RadialGradient(colors: [color, color, color.withValues(alpha: 0)], stops: const [0, 0.7, 1]),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                inhale ? l.sosBreatheIn : l.sosBreatheOut,
                key: ValueKey(inhale),
                style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Big numbers from 10 down to 0, one every 2 s. No instructions.
class _Countdown extends StatefulWidget {
  const _Countdown({super.key});

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  static const _from = 10;
  int _n = _from;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _timer?.cancel();
    setState(() => _n = _from);
    _timer = Timer.periodic(const Duration(seconds: 2), (t) {
      setState(() => _n--);
      if (_n <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final done = _n <= 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: ScaleTransition(scale: Tween(begin: 0.8, end: 1.0).animate(a), child: child),
          ),
          child: Text(
            '$_n',
            key: ValueKey(_n),
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 120,
              fontWeight: FontWeight.w300,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (done) ...[
          Text(l.sosCountdownDone, style: theme.textTheme.bodyLarge),
          TextButton.icon(icon: const Icon(Icons.replay), label: Text(l.sosAgain), onPressed: _start),
        ] else
          Text(l.sosCountdownHint, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
      ],
    );
  }
}

/// Grounding 5-4-3-2-1: see, hear, touch, smell, taste — one card per step.
class _Grounding extends StatefulWidget {
  const _Grounding({super.key});

  @override
  State<_Grounding> createState() => _GroundingState();
}

class _GroundingState extends State<_Grounding> {
  static const _steps = [
    (5, 'see', Icons.visibility_outlined),
    (4, 'hear', Icons.hearing),
    (3, 'touch', Icons.back_hand_outlined),
    (2, 'smell', Icons.local_florist_outlined),
    (1, 'taste', Icons.emoji_food_beverage_outlined),
  ];
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final done = _step >= _steps.length;
    final color = theme.colorScheme.onPrimaryContainer;

    final Widget card;
    if (done) {
      card = Column(
        key: const ValueKey('done'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, size: 48, color: color),
          const SizedBox(height: 12),
          Text(
            l.sosGroundDone,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(color: color),
          ),
        ],
      );
    } else {
      final (count, id, icon) = _steps[_step];
      card = Column(
        key: ValueKey(id),
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: theme.textTheme.displayMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Icon(icon, size: 40, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l.sosGroundStep(id),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            l.sosGroundHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: card),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _steps.length; i++)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= _step ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        done
            ? TextButton.icon(
                icon: const Icon(Icons.replay),
                label: Text(l.sosAgain),
                onPressed: () => setState(() => _step = 0),
              )
            : FilledButton.tonal(onPressed: () => setState(() => _step++), child: Text(l.sosNext)),
      ],
    );
  }
}
