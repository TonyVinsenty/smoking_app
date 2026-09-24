import 'package:flutter/material.dart';

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

/// Icon names used in content JSON (achievements.json).
IconData contentIcon(String name) => switch (name) {
  'bolt' => Icons.bolt,
  'air' => Icons.air,
  'local_fire_department' => Icons.local_fire_department,
  'favorite' => Icons.favorite,
  'emoji_events' => Icons.emoji_events,
  'self_improvement' => Icons.self_improvement,
  'spa' => Icons.spa,
  'military_tech' => Icons.military_tech,
  'savings' => Icons.savings,
  'menu_book' => Icons.menu_book,
  _ => Icons.star,
};

Color tierColor(String tier) => switch (tier) {
  'bronze' => const Color(0xFFC77B3A),
  'silver' => const Color(0xFF8E9AA6),
  'gold' => const Color(0xFFE0A800),
  _ => const Color(0xFF5E8FD6), // platinum
};

/// Health milestone category (health_milestones.json).
IconData categoryIcon(String category) => switch (category) {
  'heart' => Icons.favorite,
  'circulation' => Icons.water_drop,
  'lungs' => Icons.air,
  'energy' => Icons.bolt,
  'mind' => Icons.psychology,
  _ => Icons.shield,
};
