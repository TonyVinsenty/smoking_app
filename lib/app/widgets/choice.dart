import 'package:flutter/material.dart';

/// Whether every word of [labels] fits into [width] in [style] at the current text size, so labels can
/// wrap between words but never break inside one.
bool wordsFit(BuildContext context, Iterable<String> labels, TextStyle? style, double width) {
  final painter = TextPainter(textDirection: TextDirection.ltr, textScaler: MediaQuery.textScalerOf(context));
  try {
    for (final label in labels) {
      for (final word in label.split(RegExp(r'[\s­]+'))) {
        painter.text = TextSpan(text: word, style: style);
        painter.layout();
        if (painter.width > width) return false;
      }
    }
    return true;
  } finally {
    painter.dispose();
  }
}

/// Choice of one out of 2–4 options. Lays out in a row; when a word would not fit (large system font),
/// stacks the options in a column instead.
class AppSegments<T> extends StatelessWidget {
  const AppSegments({super.key, required this.options, required this.selected, required this.onChanged});

  final List<(T value, String label)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge;
    return LayoutBuilder(
      builder: (context, box) {
        // Each segment loses its horizontal padding (12 + 12) and the border.
        final inner = box.maxWidth / options.length - 26;
        final row = wordsFit(context, options.map((o) => o.$2), style?.copyWith(fontWeight: FontWeight.w600), inner);
        return SegmentedButton<T>(
          direction: row ? Axis.horizontal : Axis.vertical,
          showSelectedIcon: false,
          expandedInsets: EdgeInsets.zero,
          segments: [
            for (final (value, label) in options)
              ButtonSegment(
                value: value,
                label: Text(label, textAlign: TextAlign.center),
              ),
          ],
          selected: {selected},
          onSelectionChanged: (s) => onChanged(s.first),
        );
      },
    );
  }
}

/// Flat read-only label: information, not a button (no border, no ripple).
class InfoLabel extends StatelessWidget {
  const InfoLabel(this.text, {super.key, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            if (icon != null) Icon(icon, size: 16, color: color),
            Flexible(
              child: Text(text, style: theme.textTheme.labelMedium?.copyWith(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
