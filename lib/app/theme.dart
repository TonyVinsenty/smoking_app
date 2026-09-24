import 'package:flutter/material.dart';

/// Calm, "healthy" teal-green palette.
const _seed = Color(0xFF2E9E8F);

/// All text is a bit larger than Material defaults (owner feedback: easier to read).
const _textScale = 1.12;

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  // Sizes come from the M3 geometry, colors and font from the base theme.
  final text = Typography.englishLike2021.merge(base.textTheme).apply(fontSizeFactor: _textScale);
  return base.copyWith(
    textTheme: text,
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
    ),
    navigationBarTheme: NavigationBarThemeData(indicatorColor: scheme.primaryContainer),
  );
}
