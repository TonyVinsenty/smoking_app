import 'package:flutter/material.dart';

import '../theme.dart';

/// Card roles: the colour tells what a block is, the same way on every screen.
enum CardTone {
  /// Ordinary card: white with a faint shadow (light theme), a step lighter than the page (dark theme).
  plain,

  /// The one main block of a screen: mint. At most one per screen (plus «Вы здесь» on the trail).
  hero,

  /// Tips and hints: always the same calm colour.
  tip,

  /// Rewards and celebrations: warm apricot.
  reward,
}

/// The app's card. Use [CardTone] instead of picking colours by hand.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.tone = CardTone.plain,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.margin = EdgeInsets.zero,
    this.borderColor,
    this.radius = 20,
  });

  final Widget child;
  final CardTone tone;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  /// Outline, e.g. the current attempt in the history.
  final Color? borderColor;
  final double radius;

  /// Text/icon colour that reads well on a card of [tone].
  static Color onColor(BuildContext context, CardTone tone) {
    final scheme = Theme.of(context).colorScheme;
    return switch (tone) {
      CardTone.plain => scheme.onSurface,
      CardTone.hero => scheme.onPrimaryContainer,
      CardTone.tip => scheme.onSecondaryContainer,
      CardTone.reward => AppColors.of(context).onRewardContainer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final light = theme.brightness == Brightness.light;
    final shape = BorderRadius.circular(radius);
    final decoration = switch (tone) {
      CardTone.plain => BoxDecoration(
        color: light ? scheme.surfaceContainerLowest : scheme.surfaceContainer,
        borderRadius: shape,
        boxShadow: light ? softShadow : null,
      ),
      // A slight diagonal shade keeps the big mint block from looking flat.
      CardTone.hero => BoxDecoration(
        borderRadius: shape,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, Color.lerp(scheme.primaryContainer, scheme.primary, light ? 0.16 : 0.12)!],
        ),
      ),
      CardTone.tip => BoxDecoration(color: scheme.secondaryContainer, borderRadius: shape),
      CardTone.reward => BoxDecoration(color: AppColors.of(context).rewardContainer, borderRadius: shape),
    };
    final border = borderColor == null
        ? null
        : Border.all(color: borderColor!, width: 2, strokeAlign: BorderSide.strokeAlignInside);
    Widget body = Padding(padding: padding, child: child);
    if (onTap != null) {
      body = Material(
        type: MaterialType.transparency,
        child: InkWell(borderRadius: shape, onTap: onTap, child: body),
      );
    }
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: decoration,
        position: DecorationPosition.background,
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: shape, border: border),
          position: DecorationPosition.foreground,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: onColor(context, tone)),
            child: body,
          ),
        ),
      ),
    );
  }
}

/// A tip or hint: lightbulb, optional title, text. Same look on every screen.
class TipCard extends StatelessWidget {
  const TipCard({
    super.key,
    this.title,
    required this.child,
    this.icon = Icons.lightbulb_outline,
    this.padding = const EdgeInsets.all(20),
  });

  final String? title;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppCard.onColor(context, CardTone.tip);
    return AppCard(
      tone: CardTone.tip,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Icon(icon, color: color),
                Expanded(
                  child: Text(title!, style: theme.textTheme.titleMedium?.copyWith(color: color)),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          DefaultTextStyle.merge(
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Small warm label for rewards: «+15 XP».
class RewardPill extends StatelessWidget {
  const RewardPill(this.text, {super.key, this.icon = Icons.auto_awesome});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = Theme.of(context).textTheme.titleSmall?.copyWith(color: colors.onRewardContainer);
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.rewardContainer, borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            if (icon != null) Icon(icon, size: 18, color: colors.reward),
            Text(text, style: style),
          ],
        ),
      ),
    );
  }
}

/// Icon on a soft rounded square, as at the top of the home cards.
class IconBubble extends StatelessWidget {
  const IconBubble(this.icon, {super.key, this.size = 40});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(size * 0.3)),
      child: Icon(icon, size: size * 0.55, color: scheme.onSecondaryContainer),
    );
  }
}
