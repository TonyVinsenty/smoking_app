import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../content/content.dart';
import '../data/database.dart';
import '../l10n/app_localizations.dart';

/// "20 минут", "3 дня", "2 недели", "6 месяцев", "1 год": the largest unit that divides [minutes] exactly.
String formatPeriod(AppLocalizations l, int minutes) {
  const hour = 60, day = 1440, week = 10080, month = 43200, year = 525600;
  if (minutes >= year && minutes % year == 0) return l.durYears(minutes ~/ year);
  if (minutes >= month && minutes % month == 0) return l.durMonths(minutes ~/ month);
  if (minutes >= week && minutes % week == 0) return l.durWeeks(minutes ~/ week);
  if (minutes >= day && minutes % day == 0) return l.durDays(minutes ~/ day);
  if (minutes >= hour && minutes % hour == 0) return l.durHours(minutes ~/ hour);
  return l.durMinutes(minutes);
}

/// Rough remaining time, rounded up to the largest sensible unit: "5 часов", "2 месяца".
String formatRemaining(AppLocalizations l, Duration d) {
  int up(int unitMinutes) => (d.inMinutes + unitMinutes - 1) ~/ unitMinutes;
  if (d.inDays >= 365) return l.durYears(up(525600));
  if (d.inDays >= 30) return l.durMonths(up(43200));
  if (d.inDays >= 7) return l.durWeeks(up(10080));
  if (d.inHours >= 24) return l.durDays(up(1440));
  if (d.inMinutes >= 60) return l.durHours(up(60));
  return l.durMinutes(d.inMinutes < 1 ? 1 : up(1));
}

/// Time elapsed, rounded down to one unit: "301 день", "5 часов", "12 минут".
String formatElapsed(AppLocalizations l, Duration d) {
  if (d.inDays >= 1) return l.durDays(d.inDays);
  if (d.inHours >= 1) return l.durHours(d.inHours);
  return l.durMinutes(d.inMinutes);
}

/// Icon names used in content JSON (achievements.json). Filled for an earned badge, outlined otherwise.
IconData contentIcon(String name, {bool filled = true}) {
  final (on, off) = switch (name) {
    'air' => (Icons.air, Icons.air),
    'bolt' => (Icons.bolt, Icons.bolt_outlined),
    'diamond' => (Icons.diamond, Icons.diamond_outlined),
    'emoji_events' => (Icons.emoji_events, Icons.emoji_events_outlined),
    'favorite' => (Icons.favorite, Icons.favorite_border),
    'local_fire_department' => (Icons.local_fire_department, Icons.local_fire_department_outlined),
    'menu_book' => (Icons.menu_book, Icons.menu_book_outlined),
    'military_tech' => (Icons.military_tech, Icons.military_tech_outlined),
    'park' => (Icons.park, Icons.park_outlined),
    'rocket_launch' => (Icons.rocket_launch, Icons.rocket_launch_outlined),
    'savings' => (Icons.savings, Icons.savings_outlined),
    'self_improvement' => (Icons.self_improvement, Icons.self_improvement),
    'smoke_free' => (Icons.smoke_free, Icons.smoke_free),
    'spa' => (Icons.spa, Icons.spa_outlined),
    'timer' => (Icons.timer, Icons.timer_outlined),
    'workspace_premium' => (Icons.workspace_premium, Icons.workspace_premium_outlined),
    _ => (Icons.star, Icons.star_border),
  };
  return filled ? on : off;
}

/// Rarity colours (achievements.json "tier"), WoW order but softened towards the app's teal, without neon;
/// only legendary is warm gold.
Color tierColor(String tier) => switch (tier) {
  'common' => const Color(0xFF6E8C86), // grey-green
  'uncommon' => const Color(0xFF2E9A68), // green
  'rare' => const Color(0xFF2F7DB8), // blue
  'epic' => const Color(0xFF8155C2), // violet
  _ => const Color(0xFFD08A1E), // legendary: gold
};

/// "180 сиг.", "2 одноразки": units of a product not smoked, with a thousands separator.
String avoidedText(AppLocalizations l, ProductType type, num count) {
  final n = count.floor();
  final s = NumberFormat('#,##0', 'ru').format(n);
  return type == ProductType.disposable ? l.unitsDisposableShort(n, s) : l.unitsAvoided(type.name, s);
}

/// "10 сигарет", "1 одноразка", "2 флакона жидкости".
String unitsText(AppLocalizations l, ProductType type, int count) => switch (type) {
  ProductType.cigarettes => l.unitsCigarettes(count),
  ProductType.sticks => l.unitsSticks(count),
  ProductType.disposable => l.unitsDisposable(count),
  ProductType.liquid => l.unitsLiquid(count),
};

/// Achievement description with `{units}` filled in for the user's [main] product.
String achievementDescription(AppLocalizations l, Achievement a, ProductType? main) {
  final type = main ?? ProductType.cigarettes;
  return a.description.replaceAll('{units}', unitsText(l, type, a.conditionValue(type.name).toInt()));
}

/// Health milestone category (health_milestones.json). Outlined by default, filled once passed.
IconData categoryIcon(String category, {bool filled = false}) {
  final (on, off) = switch (category) {
    'heart' => (Icons.favorite, Icons.favorite_border),
    'circulation' => (Icons.water_drop, Icons.water_drop_outlined),
    'lungs' => (Icons.air, Icons.air),
    'energy' => (Icons.bolt, Icons.bolt_outlined),
    'mind' => (Icons.psychology, Icons.psychology_outlined),
    'taste_smell' => (Icons.restaurant, Icons.restaurant_outlined),
    _ => (Icons.shield, Icons.shield_outlined),
  };
  return filled ? on : off;
}
