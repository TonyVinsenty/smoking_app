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
        // Stretched to the full width; a column must not stretch, or it grows endlessly tall in a list.
        final button = SegmentedButton<T>(
          direction: row ? Axis.horizontal : Axis.vertical,
          showSelectedIcon: false,
          expandedInsets: row ? EdgeInsets.zero : null,
          style: row
              ? null
              : SegmentedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
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
        return row ? button : SizedBox(width: double.infinity, child: button);
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

/// Text for narrow places (cards beside the trail, tiles): with a very large system font it shrinks just
/// enough for its longest word to fit, so a word never breaks in the middle.
class WordFitText extends StatelessWidget {
  const WordFitText(this.text, {super.key, this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final painter = TextPainter(textDirection: TextDirection.ltr, textScaler: scaler);
        var widest = 0.0;
        for (final word in text.split(RegExp(r'\s+'))) {
          painter.text = TextSpan(text: word, style: style ?? DefaultTextStyle.of(context).style);
          painter.layout();
          if (painter.width > widest) widest = painter.width;
        }
        painter.dispose();
        final fit = widest <= box.maxWidth || widest == 0 ? 1.0 : box.maxWidth / widest * 0.98;
        return Text(text, style: style, textAlign: textAlign, textScaler: fit == 1 ? scaler : _Shrunk(scaler, fit));
      },
    );
  }
}

/// The system text scaling (which may be non-linear) shrunk by [factor].
class _Shrunk extends TextScaler {
  const _Shrunk(this.base, this.factor);

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  double get textScaleFactor => base.scale(14) / 14 * factor;

  @override
  bool operator ==(Object other) => other is _Shrunk && other.base == base && other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
