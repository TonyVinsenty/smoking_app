import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Content locale folder in assets/content/.
const contentLocale = 'ru';

Future<List<Map<String, dynamic>>> _loadList(String file) async {
  final raw = await rootBundle.loadString('assets/content/$contentLocale/$file');
  return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
}

class Level {
  Level.fromJson(Map<String, dynamic> j)
    : level = j['level'],
      xpRequired = j['xpRequired'],
      title = j['title'],
      description = j['description'];

  final int level;
  final int xpRequired;
  final String title;
  final String description;
}

class Achievement {
  Achievement.fromJson(Map<String, dynamic> j)
    : id = j['id'],
      title = j['title'],
      description = j['description'],
      icon = j['icon'],
      tier = j['tier'],
      xp = j['xp'],
      conditionType = j['condition']['type'],
      conditionValue = j['condition']['value'];

  final String id;
  final String title;
  final String description;
  final String icon;
  final String tier;
  final int xp;

  /// smokeFreeMinutes | moneySavedRub | cravingsResisted | articlesRead | attemptsStarted | comebackAfterRelapse
  final String conditionType;
  final num conditionValue;
}

class HealthMilestone {
  HealthMilestone.fromJson(Map<String, dynamic> j)
    : id = j['id'],
      afterMinutes = j['afterMinutes'],
      title = j['title'],
      description = j['description'],
      category = j['category'],
      source = j['source'];

  final String id;
  final int afterMinutes;
  final String title;
  final String description;
  final String category;
  final String? source;
}

class Quote {
  Quote.fromJson(Map<String, dynamic> j) : text = j['text'], author = j['author'];

  final String text;
  final String? author;
}

class Article {
  Article.fromJson(Map<String, dynamic> j)
    : id = j['id'],
      title = j['title'],
      summary = j['summary'],
      category = j['category'],
      readMinutes = j['readMinutes'],
      file = j['file'];

  final String id;
  final String title;
  final String summary;

  /// addiction | health | practice | myths | vape | money
  final String category;
  final int readMinutes;

  /// Markdown file relative to the locale folder; null while the article is not written yet (hidden).
  final String? file;
}

class AppContent {
  AppContent({
    required this.levels,
    required this.achievements,
    required this.milestones,
    required this.quotes,
    required this.sosTips,
    required this.articles,
  });

  final List<Level> levels;
  final List<Achievement> achievements;
  final List<HealthMilestone> milestones;
  final List<Quote> quotes;
  final List<String> sosTips;

  /// Published articles (those with a file), in index order.
  final List<Article> articles;

  /// Highest level reached with [xp] and the next one (null at max level).
  (Level current, Level? next) levelFor(int xp) {
    final reached = levels.lastWhere((l) => l.xpRequired <= xp, orElse: () => levels.first);
    final i = levels.indexOf(reached);
    return (reached, i + 1 < levels.length ? levels[i + 1] : null);
  }
}

final contentProvider = FutureProvider<AppContent>((ref) async {
  final results = await Future.wait([
    _loadList('levels.json'),
    _loadList('achievements.json'),
    _loadList('health_milestones.json'),
    _loadList('quotes.json'),
    _loadList('sos_tips.json'),
    _loadList('articles/index.json'),
  ]);
  return AppContent(
    levels: results[0].map(Level.fromJson).toList()..sort((a, b) => a.level.compareTo(b.level)),
    achievements: results[1].map(Achievement.fromJson).toList(),
    milestones: results[2].map(HealthMilestone.fromJson).toList()
      ..sort((a, b) => a.afterMinutes.compareTo(b.afterMinutes)),
    quotes: results[3].map(Quote.fromJson).toList(),
    sosTips: [for (final t in results[4]) t['text'] as String],
    articles: [for (final a in results[5].map(Article.fromJson)) if (a.file != null) a],
  );
});

/// Markdown text of an article.
final articleBodyProvider = FutureProvider.family<String, Article>(
  (ref, a) => rootBundle.loadString('assets/content/$contentLocale/${a.file}'),
);
