import 'package:flutter/material.dart';

import '../theme.dart';

/// A metric: the number in the metric style, its unit smaller next to it ("7 397 ₽", "180 сиг.").
/// [text] is a ready localized string; the leading number is split off automatically.
class MetricText extends StatelessWidget {
  const MetricText(this.text, {super.key, this.style, this.unitStyle, this.color, this.textAlign});

  final String text;

  /// Defaults to headlineMedium (30/600) for the number and titleMedium for the unit.
  final TextStyle? style;
  final TextStyle? unitStyle;
  final Color? color;
  final TextAlign? textAlign;

  static final _number = RegExp(r'^([+\-−]?[\d\s  .,]*\d)(.*)$', dotAll: true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final big = (style ?? theme.textTheme.headlineMedium)!.copyWith(color: color, fontFeatures: tabular);
    final small = (unitStyle ?? theme.textTheme.titleMedium)!.copyWith(color: color ?? big.color);
    final m = _number.firstMatch(text);
    return Text.rich(
      m == null
          ? TextSpan(text: text, style: big)
          : TextSpan(
              children: [
                TextSpan(text: m.group(1), style: big),
                TextSpan(text: m.group(2), style: small),
              ],
            ),
      textAlign: textAlign,
    );
  }
}
