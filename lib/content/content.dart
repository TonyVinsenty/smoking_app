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
      _value = j['condition']['value'];

  final String id;
  final String title;

  /// May contain `{units}` (unitsAvoided badges): replaced with e.g. "10 сигарет" for the main product.
  final String description;
  final String icon;

  /// Rarity: common | uncommon | rare | epic | legendary.
  final String tier;
  final int xp;

  /// smokeFreeMinutes | moneySavedRub | unitsAvoided | cravingsResisted | articlesRead | attemptsStarted |
  /// comebackAfterRelapse
  final String conditionType;

  /// A number, or for unitsAvoided a map product type name → number of units of that product.
  final Object _value;

  /// Threshold of the condition; for unitsAvoided, of the user's main [product] (ProductType name).
  num conditionValue([String? product]) {
    final v = _value;
    return v is Map ? v[product ?? 'cigarettes'] as num : v as num;
  }

  /// Group on the achievements screen, in display order.
  static const groups = ['streak', 'cravings', 'money', 'units', 'articles', 'path'];

  String get group => switch (conditionType) {
    'smokeFreeMinutes' => 'streak',
    'cravingsResisted' => 'cravings',
    'moneySavedRub' => 'money',
    'unitsAvoided' => 'units',
    'articlesRead' => 'articles',
    _ => 'path',
  };

  /// «С чистого листа» keeps the badges for read articles (they stay read) and for the path itself.
  bool get keptOnFreshStart => group == 'articles' || group == 'path';
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

/// A real research number for the Здоровье tab.
class HealthFact {
  HealthFact.fromJson(Map<String, dynamic> j)
    : id = j['id'],
      value = j['value'],
      text = j['text'],
      source = j['source'];

  final String id;
  final String value;
  final String text;
  final String source;
}

/// A usual nicotine withdrawal symptom and how long it typically lasts.
class WithdrawalSymptom {
  WithdrawalSymptom.fromJson(Map<String, dynamic> j)
    : id = j['id'],
      title = j['title'],
      untilHours = j['untilHours'],
      duration = j['duration'],
      text = j['text'],
      tips = (j['tips'] as List).cast<String>();

  final String id;
  final String title;

  /// End of the typical period, counted from the quit time.
  final int untilHours;
  final String duration;
  final String text;
  final List<String> tips;
}

/// What the user no longer breathes in, for the given product types («Не вдохнули»).
class NotInhaledFact {
  NotInhaledFact.fromJson(Map<String, dynamic> j)
    : id = j['id'],
      products = (j['products'] as List).cast<String>(),
      icon = j['icon'],
      value = j['value'],
      title = j['title'],
      text = j['text'],
      source = j['source'];

  final String id;
  final List<String> products;
  final String icon;
  final String value;
  final String title;
  final String text;
  final String source;
}

class Quote {
  Quote.fromJson(Map<String, dynamic> j) : text = j['text'], author = j['author'];

  final String text;
  final String? author;
}

/// Product type names a piece of content is meant for; empty = everyone.
Set<String> _products(Map<String, dynamic> j) => {...?(j['products'] as List?)?.cast<String>()};

/// A tip for everyone, or only for users of some product types (ProductType names).
class Tip {
  Tip.fromJson(Map<String, dynamic> j) : text = j['text'], products = _products(j);

  final String text;
  final Set<String> products;

  bool get general => products.isEmpty;

  /// Shown to a user of [types]: a general tip, or one about any of their products.
  bool fits(Set<String> types) => general || products.any(types.contains);
}

class Article {
  Article.fromJson(Map<String, dynamic> j)
    : id = j['id'],
      title = j['title'],
      summary = j['summary'],
      category = j['category'],
      products = _products(j),
      readMinutes = j['readMinutes'],
      file = j['file'];

  final String id;
  final String title;
  final String summary;

  /// addiction | health | practice | myths | vape | money
  final String category;

  /// Product types (ProductType names) the article is especially about: listed in «Для вас» for their users.
  final Set<String> products;
  final int readMinutes;

  /// Markdown file relative to the locale folder; null while the article is not written yet (hidden).
  final String? file;
}

class AppContent {
  AppContent({
    required this.levels,
    required this.achievements,
    required this.milestones,
    required this.healthFacts,
    required this.withdrawal,
    required this.notInhaledFacts,
    required this.quotes,
    required this.sosTips,
    required this.triggerTips,
    required this.articles,
  });

  final List<Level> levels;
  final List<Achievement> achievements;
  final List<HealthMilestone> milestones;
  final List<HealthFact> healthFacts;
  final List<WithdrawalSymptom> withdrawal;
  final List<NotInhaledFact> notInhaledFacts;
  final List<Quote> quotes;
  final List<Tip> sosTips;

  /// Advice for the most frequent craving trigger, keyed by `Trigger.name`; see [triggerTipFor].
  final Map<String, List<Tip>> triggerTips;

  /// Advice for [trigger]: the one about the user's own products ([types]) if there is one, else the general one.
  String? triggerTipFor(String trigger, Set<String> types) {
    final tips = triggerTips[trigger] ?? const <Tip>[];
    return (tips.where((t) => !t.general && t.fits(types)).firstOrNull ?? tips.where((t) => t.general).firstOrNull)
        ?.text;
  }

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
    _loadList('trigger_tips.json'),
    _loadList('health_facts.json'),
    _loadList('withdrawal_symptoms.json'),
    _loadList('not_inhaled_facts.json'),
  ]);
  return AppContent(
    levels: results[0].map(Level.fromJson).toList()..sort((a, b) => a.level.compareTo(b.level)),
    achievements: results[1].map(Achievement.fromJson).toList(),
    milestones: results[2].map(HealthMilestone.fromJson).toList()
      ..sort((a, b) => a.afterMinutes.compareTo(b.afterMinutes)),
    quotes: results[3].map(Quote.fromJson).toList(),
    sosTips: results[4].map(Tip.fromJson).toList(),
    articles: [
      for (final a in results[5].map(Article.fromJson))
        if (a.file != null) a,
    ],
    triggerTips: {
      for (final t in results[6])
        t['trigger'] as String: [
          for (final u in results[6])
            if (u['trigger'] == t['trigger']) Tip.fromJson(u),
        ],
    },
    healthFacts: results[7].map(HealthFact.fromJson).toList(),
    withdrawal: results[8].map(WithdrawalSymptom.fromJson).toList(),
    notInhaledFacts: results[9].map(NotInhaledFact.fromJson).toList(),
  );
});

/// Markdown text of an article.
final articleBodyProvider = FutureProvider.family<String, Article>(
  (ref, a) => rootBundle.loadString('assets/content/$contentLocale/${a.file}'),
);
