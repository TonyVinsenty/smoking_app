import 'package:flutter/material.dart';

/// Calm, "healthy" teal-green palette.
const _seed = Color(0xFF2E9E8F);

/// Numbers and headings; ordinary text stays in the platform font (Roboto).
const displayFont = 'Manrope';

/// Digits of equal width for numbers that change (timer, money, counters), so they do not jiggle.
const tabular = [FontFeature.tabularFigures()];

/// Type scale: seven roles used across the app. Sizes already include the owner's "a bit larger than
/// Material" wish.
///
/// | role                     | slot            | size/weight      |
/// |--------------------------|-----------------|------------------|
/// | hero number of a screen  | displayLarge    | 56 / 700 Manrope |
/// | metric (unit smaller)    | headlineMedium  | 30 / 600 Manrope |
/// | section title            | titleLarge      | 20 / 600 Manrope |
/// | card title               | titleMedium     | 17 / 600 Manrope |
/// | body text                | bodyMedium      | 16 / 400         |
/// | label above a value      | labelMedium     | 13 / 500         |
/// | caption, source          | bodySmall       | 12.5 / 400       |
///
/// bodyLarge (17) is for longer reading (articles, intros); other slots fill in between.
TextTheme _textTheme(TextTheme base) {
  TextStyle display(TextStyle? s, double size, FontWeight weight, {double height = 1.2, double spacing = 0}) =>
      s!.copyWith(fontFamily: displayFont, fontSize: size, fontWeight: weight, height: height, letterSpacing: spacing);
  TextStyle body(TextStyle? s, double size, FontWeight weight, {double height = 1.4, double spacing = 0.1}) =>
      s!.copyWith(fontSize: size, fontWeight: weight, height: height, letterSpacing: spacing);
  return base.copyWith(
    displayLarge: display(base.displayLarge, 56, FontWeight.w700, height: 1.05, spacing: -1.5),
    displayMedium: display(base.displayMedium, 44, FontWeight.w700, height: 1.1, spacing: -1),
    displaySmall: display(base.displaySmall, 36, FontWeight.w700, height: 1.1, spacing: -0.5),
    headlineLarge: display(base.headlineLarge, 32, FontWeight.w700, height: 1.15, spacing: -0.5),
    headlineMedium: display(base.headlineMedium, 30, FontWeight.w600, height: 1.15, spacing: -0.5),
    headlineSmall: display(base.headlineSmall, 24, FontWeight.w600, height: 1.2, spacing: -0.2),
    titleLarge: display(base.titleLarge, 20, FontWeight.w600, height: 1.25),
    titleMedium: display(base.titleMedium, 17, FontWeight.w600, height: 1.3),
    titleSmall: display(base.titleSmall, 15, FontWeight.w700, height: 1.3),
    bodyLarge: body(base.bodyLarge, 17, FontWeight.w400, height: 1.45),
    bodyMedium: body(base.bodyMedium, 16, FontWeight.w400),
    bodySmall: body(base.bodySmall, 12.5, FontWeight.w400, height: 1.35),
    labelLarge: body(base.labelLarge, 15, FontWeight.w500, height: 1.3),
    labelMedium: body(base.labelMedium, 13, FontWeight.w500, height: 1.3, spacing: 0.2),
    labelSmall: body(base.labelSmall, 12, FontWeight.w500, height: 1.3, spacing: 0.2),
  );
}

/// Faint two-layer shadow of ordinary cards in the light theme.
const softShadow = [
  BoxShadow(color: Color(0x0F002822), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x12002822), blurRadius: 14, offset: Offset(0, 4)),
];

/// Colours outside the Material scheme. Warm apricot is only for rewards and celebrations.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.reward, required this.rewardContainer, required this.onRewardContainer});

  /// Strong warm colour: «+10 XP», reward icons.
  final Color reward;
  final Color rewardContainer;
  final Color onRewardContainer;

  static const light = AppColors(
    reward: Color(0xFFB0611F),
    rewardContainer: Color(0xFFFBEBDC),
    onRewardContainer: Color(0xFF4A2508),
  );
  static const dark = AppColors(
    reward: Color(0xFFEDB07A),
    rewardContainer: Color(0xFF3A2A1B),
    onRewardContainer: Color(0xFFFBDDC2),
  );

  static AppColors of(BuildContext context) => Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({Color? reward, Color? rewardContainer, Color? onRewardContainer}) => AppColors(
    reward: reward ?? this.reward,
    rewardContainer: rewardContainer ?? this.rewardContainer,
    onRewardContainer: onRewardContainer ?? this.onRewardContainer,
  );

  @override
  AppColors lerp(AppColors? other, double t) => other == null
      ? this
      : AppColors(
          reward: Color.lerp(reward, other.reward, t)!,
          rewardContainer: Color.lerp(rewardContainer, other.rewardContainer, t)!,
          onRewardContainer: Color.lerp(onRewardContainer, other.onRewardContainer, t)!,
        );
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  // Geometry from M3, colors and font from the base theme, then our own scale.
  final text = _textTheme(Typography.englishLike2021.merge(base.textTheme));
  return base.copyWith(
    textTheme: text,
    extensions: [brightness == Brightness.light ? AppColors.light : AppColors.dark],
    // Same look as AppCard(tone: plain) for any plain Card left.
    cardTheme: CardThemeData(
      color: brightness == Brightness.light ? scheme.surfaceContainerLowest : scheme.surfaceContainer,
      elevation: brightness == Brightness.light ? 1 : 0,
      shadowColor: const Color(0x66002822),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
    ),
    // The title bar keeps its color when content scrolls under it.
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
    ),
    // Filters (topics) and quick picks (SOS triggers): pill-shaped chips.
    chipTheme: ChipThemeData(
      shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant)),
      labelStyle: text.labelLarge,
      selectedColor: scheme.secondaryContainer,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        side: WidgetStatePropertyAll(BorderSide(color: scheme.outlineVariant)),
      ),
    ),
    // Icons sit level with the first line of a row; hints under it are a step smaller.
    listTileTheme: ListTileThemeData(
      titleAlignment: ListTileTitleAlignment.titleHeight,
      subtitleTextStyle: text.bodyMedium?.copyWith(fontSize: 14.5, color: scheme.onSurfaceVariant),
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
