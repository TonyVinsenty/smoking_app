import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../app/widgets/cards.dart';
import '../../app/widgets/toast.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import 'health_common.dart';

/// Questions of the diary.
const _questions = ['sleep', 'breathing', 'mood', 'tasteSmell'];

int _answer(WellbeingEntry e, String q) => switch (q) {
  'sleep' => e.sleep,
  'breathing' => e.breathing,
  'mood' => e.mood,
  _ => e.tasteSmell,
};

/// «Дневник самочувствия»: a short 1–5 questionnaire and a chart of how things get better.
class DiaryTab extends ConsumerStatefulWidget {
  const DiaryTab({super.key});

  @override
  ConsumerState<DiaryTab> createState() => _DiaryTabState();
}

class _DiaryTabState extends ConsumerState<DiaryTab> {
  final _answers = <String, int>{};
  var _again = false;

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final saved = AppLocalizations.of(context).diarySaved;
    await ref
        .read(databaseProvider)
        .addWellbeing(
          sleep: _answers['sleep']!,
          breathing: _answers['breathing']!,
          mood: _answers['mood']!,
          tasteSmell: _answers['tasteSmell']!,
        );
    setState(() {
      _answers.clear();
      _again = false;
    });
    showToastWith(messenger, theme, saved);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final entries = ref.watch(wellbeingProvider).value;
    final reminder = ref.watch(diaryReminderProvider);
    if (entries == null) return const Center(child: CircularProgressIndicator());

    final now = DateTime.now();
    final last = entries.lastOrNull?.at;
    final doneToday = last != null && DateUtils.isSameDay(last, now);
    final due = reminder.dueAt(last);

    return ListView(
      padding: healthTabPadding,
      children: [
        Text(l.diaryIntro, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        if (doneToday && !_again)
          AppCard(
            tone: CardTone.tip,
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    Icon(Icons.check_circle, color: theme.colorScheme.primary),
                    Expanded(child: Text(l.diaryDoneToday, style: theme.textTheme.titleMedium)),
                  ],
                ),
                if (due != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 36, top: 4),
                    child: Text(l.diaryNext(DateFormat('d MMMM, HH:mm', 'ru').format(due))),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: () => setState(() => _again = true), child: Text(l.diaryAgain)),
                ),
              ],
            ),
          )
        else
          _Form(answers: _answers, onChanged: (q, v) => setState(() => _answers[q] = v), onSave: _save),
        const SizedBox(height: 16),
        _Chart(entries: entries),
        const SizedBox(height: 16),
        if (!reminder.enabled) ...[HealthDisclaimer(text: l.diaryRemindHint), const SizedBox(height: 8)],
        HealthDisclaimer(text: l.diaryLocalNote),
      ],
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.answers, required this.onChanged, required this.onSave});

  final Map<String, int> answers;
  final void Function(String question, int value) onChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.diaryHowNow, style: theme.textTheme.titleMedium),
          for (final q in _questions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text(l.diaryQuestion(q), style: theme.textTheme.titleMedium)),
                if (answers[q] != null)
                  Text('${answers[q]}', style: theme.textTheme.titleMedium?.copyWith(color: scheme.primary)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              spacing: 8,
              children: [
                for (var v = 1; v <= 5; v++)
                  Expanded(
                    child: _ScaleButton(value: v, selected: answers[q] == v, onTap: () => onChanged(q, v)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              answers[q] == null ? '${l.diaryScale('1')} … ${l.diaryScale('5')}' : l.diaryScale('${answers[q]}'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(onPressed: answers.length == _questions.length ? onSave : null, child: Text(l.diarySave)),
        ],
      ),
    );
  }
}

class _ScaleButton extends StatelessWidget {
  const _ScaleButton({required this.value, required this.selected, required this.onTap});

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      height: 48,
      child: Material(
        shape: CircleBorder(side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: 2)),
        color: selected ? scheme.primary : scheme.surface,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Text(
              '$value',
              style: theme.textTheme.titleMedium?.copyWith(color: selected ? scheme.onPrimary : scheme.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}

/// One small chart per question (scale 1–5) with "было → стало"; a hint until there are two entries.
class _Chart extends StatelessWidget {
  const _Chart({required this.entries});

  final List<WellbeingEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant);
    // Entries on the same day would sit on top of each other: spread them evenly instead.
    final byTime = entries.length > 1 && entries.last.at.difference(entries.first.at).inHours >= 24;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.diaryChart, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (entries.length < 2)
            Text(l.diaryChartEmpty, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))
          else ...[
            for (final (i, q) in _questions.indexed) ...[
              if (i > 0) const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text(l.diaryQuestion(q), style: theme.textTheme.labelLarge)),
                  Text(
                    l.diaryChange(_answer(entries.first, q), _answer(entries.last, q)),
                    style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, fontFeatures: tabular),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  // Scale: 5 at the top, 1 at the bottom.
                  SizedBox(
                    height: 64,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('5', style: muted),
                        Text('1', style: muted),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, t, _) => CustomPaint(
                          painter: _ChartPainter(
                            entries: entries,
                            question: q,
                            byTime: byTime,
                            progress: t,
                            line: scheme.primary,
                            grid: scheme.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (byTime) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final d in [entries.first.at, entries.last.at])
                      Text(DateFormat('d MMM', 'ru').format(d), style: muted),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// One question over time: faint lines at 1…5, the answers as a line with a soft fill under it.
/// Draws in from the left.
class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.entries,
    required this.question,
    required this.byTime,
    required this.progress,
    required this.line,
    required this.grid,
  });

  final List<WellbeingEntry> entries;
  final String question;
  final bool byTime;
  final double progress;
  final Color line;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 5.0;
    final h = size.height - 2 * pad;
    double y(int v) => pad + h * (5 - v) / 4;
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var v = 1; v <= 5; v++) {
      canvas.drawLine(Offset(0, y(v)), Offset(size.width, y(v)), gridPaint);
    }
    final start = entries.first.at.millisecondsSinceEpoch;
    final span = (entries.last.at.millisecondsSinceEpoch - start).clamp(1, 1 << 62);
    double x(int i) => byTime
        ? pad + (size.width - 2 * pad) * (entries[i].at.millisecondsSinceEpoch - start) / span
        : pad + (size.width - 2 * pad) * i / (entries.length - 1);
    final points = [for (var i = 0; i < entries.length; i++) Offset(x(i), y(_answer(entries[i], question)))];

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    final fill = Path.from(path)
      ..lineTo(points.last.dx, size.height - pad)
      ..lineTo(points.first.dx, size.height - pad)
      ..close();
    canvas.drawPath(fill, Paint()..color = line.withValues(alpha: 0.12));
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (final p in points) {
      canvas.drawCircle(p, 3, Paint()..color = line);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.entries != entries || old.progress != progress || old.line != line || old.grid != grid;
}
