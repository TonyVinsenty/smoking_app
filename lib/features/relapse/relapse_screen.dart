import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/format.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';

/// «Я закурил»: one confirmation, then a kind "no-guilt diary" that ends the current attempt.
class RelapseScreen extends ConsumerStatefulWidget {
  const RelapseScreen({super.key, required this.attempt});

  final Attempt attempt;

  /// Asks once (against accidental taps), then opens the diary.
  static Future<void> start(BuildContext context, Attempt attempt) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.relapseConfirmTitle),
        content: Text(l.relapseConfirmText),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.relapseConfirm)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await Navigator.of(context)
        .push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => RelapseScreen(attempt: attempt)));
  }

  @override
  ConsumerState<RelapseScreen> createState() => _RelapseScreenState();
}

class _RelapseScreenState extends ConsumerState<RelapseScreen> {
  /// When it happened; null = just now.
  DateTime? _at;
  Trigger? _trigger;
  final _answers = [TextEditingController(), TextEditingController(), TextEditingController()];

  /// Set after saving: how long this attempt lasted and the personal record.
  (Duration, Duration)? _result;

  @override
  void dispose() {
    for (final c in _answers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final start = widget.attempt.startedAt;
    final date = await showDatePicker(
      context: context,
      initialDate: _at ?? now,
      firstDate: start.isAfter(now) ? now : start,
      lastDate: now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at ?? now));
    if (time == null) return;
    var at = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (at.isAfter(now)) at = now;
    if (at.isBefore(start)) at = start;
    setState(() => _at = at);
  }

  Future<void> _save() async {
    final at = _at ?? DateTime.now();
    String? answer(int i) => _answers[i].text.trim().isEmpty ? null : _answers[i].text.trim();
    await ref
        .read(databaseProvider)
        .endAttempt(
          attemptId: widget.attempt.id,
          at: at,
          trigger: _trigger,
          whatHappened: answer(0),
          whatWouldHelp: answer(1),
          nextTime: answer(2),
        );
    final lasted = at.difference(widget.attempt.startedAt);
    final others = (ref.read(attemptsProvider).value ?? const <Attempt>[]).where((a) => a.id != widget.attempt.id);
    final best = bestAttempt(others.toList(), at);
    setState(() => _result = (lasted.isNegative ? Duration.zero : lasted, lasted > best ? lasted : best));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.relapseTitle)),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _result == null ? _diary(l) : _done(l, _result!),
        ),
      ),
    );
  }

  Widget _diary(AppLocalizations l) {
    final theme = Theme.of(context);
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );
    return ListView(
      key: const ValueKey('diary'),
      padding: const EdgeInsets.all(24),
      children: [
        Text(l.relapseIntro, style: theme.textTheme.bodyLarge),
        label(l.relapseWhen),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l.relapseJustNow),
              selected: _at == null,
              onSelected: (_) => setState(() => _at = null),
            ),
            ChoiceChip(
              avatar: const Icon(Icons.schedule, size: 18),
              label: Text(_at == null ? l.relapsePickTime : DateFormat('d MMMM, HH:mm', 'ru').format(_at!)),
              selected: _at != null,
              onSelected: (_) => _pickTime(),
            ),
          ],
        ),
        label(l.relapseTrigger),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in Trigger.values)
              ChoiceChip(
                label: Text(l.triggerName(t.name)),
                selected: _trigger == t,
                onSelected: (on) => setState(() => _trigger = on ? t : null),
              ),
          ],
        ),
        for (final (i, q) in [l.relapseQ1, l.relapseQ2, l.relapseQ3].indexed) ...[
          label(q),
          TextField(
            controller: _answers[i],
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
        const SizedBox(height: 16),
        Text(l.relapseOptional, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 16),
        FilledButton(onPressed: _save, child: Text(l.relapseSave)),
      ],
    );
  }

  Widget _done(AppLocalizations l, (Duration, Duration) result) {
    final theme = Theme.of(context);
    final (lasted, best) = result;
    return Padding(
      key: const ValueKey('done'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Icon(Icons.spa_outlined, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(l.relapseDoneTitle, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(
            l.relapseDoneText(formatElapsed(l, lasted), formatElapsed(l, best)),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const Spacer(),
          FilledButton(
            onPressed: () async {
              await ref.read(databaseProvider).startAttempt(DateTime.now());
              if (mounted) Navigator.of(context).pop();
            },
            child: Text(l.relapseStartNow),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.relapseLater)),
        ],
      ),
    );
  }
}
