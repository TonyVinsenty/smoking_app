import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';

/// «Хочу курить»: trigger → breathing exercise + tips → "справился".
class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const SosScreen()));

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

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
      body: SafeArea(child: _askTrigger ? _triggerStep(l) : _BreathingStep(onResisted: _resisted)),
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

class _BreathingStep extends ConsumerStatefulWidget {
  const _BreathingStep({required this.onResisted});

  final VoidCallback onResisted;

  @override
  ConsumerState<_BreathingStep> createState() => _BreathingStepState();
}

class _BreathingStepState extends ConsumerState<_BreathingStep> with SingleTickerProviderStateMixin {
  // Breathing cycle: 4 s in, 4 s hold, 6 s out.
  static const _inSec = 4, _holdSec = 4, _outSec = 6;
  static const _cycle = _inSec + _holdSec + _outSec;

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: _cycle),
  )..repeat();
  final _random = Random();
  int _tipIndex = -1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tips = ref.watch(contentProvider).value?.sosTips ?? const [];
    if (_tipIndex < 0 && tips.isNotEmpty) _tipIndex = _random.nextInt(tips.length);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(l.sosWaveHint, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value * _cycle;
                  final (label, scale) = t < _inSec
                      ? (l.sosBreatheIn, 0.55 + 0.45 * Curves.easeInOut.transform(t / _inSec))
                      : t < _inSec + _holdSec
                      ? (l.sosHold, 1.0)
                      : (l.sosBreatheOut, 1.0 - 0.45 * Curves.easeInOut.transform((t - _inSec - _holdSec) / _outSec));
                  return Container(
                    width: 240 * scale,
                    height: 240 * scale,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primaryContainer),
                    child: Text(
                      label,
                      style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                    ),
                  );
                },
              ),
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
