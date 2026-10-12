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
    // The title bar keeps its color when content scrolls under it.
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(indicatorColor: scheme.primaryContainer),
    // A soft tinted card instead of the default inverse (white in dark mode) block.
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.secondaryContainer,
      contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onSecondaryContainer, fontWeight: FontWeight.w500),
      actionTextColor: scheme.primary,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.35)),
      ),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      dismissDirection: DismissDirection.down,
    ),
  );
}
