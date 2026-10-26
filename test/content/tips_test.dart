import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smoking_app/content/content.dart';
import 'package:smoking_app/data/database.dart';

List<Map<String, dynamic>> _load(String file) =>
    (jsonDecode(File('assets/content/ru/$file').readAsStringSync()) as List).cast<Map<String, dynamic>>();

void main() {
  final names = {for (final t in ProductType.values) t.name};

  test('tips and articles name only real product types', () {
    for (final file in ['sos_tips.json', 'trigger_tips.json', 'articles/index.json']) {
      for (final j in _load(file)) {
        expect(names, containsAll((j['products'] as List?) ?? const []), reason: '$file: $j');
      }
    }
  });

  test('a general tip fits everyone, a product tip only its users', () {
    final general = Tip.fromJson({'text': 'a'});
    final vape = Tip.fromJson({
      'text': 'b',
      'products': ['disposable', 'liquid'],
    });
    expect(general.fits({}), isTrue);
    expect(vape.fits({'cigarettes'}), isFalse);
    expect(vape.fits({'cigarettes', 'liquid'}), isTrue);
  });

  test('every trigger has a general tip; a product tip wins for its users', () {
    final tips = <String, List<Tip>>{};
    for (final j in _load('trigger_tips.json')) {
      (tips[j['trigger'] as String] ??= []).add(Tip.fromJson(j));
    }
    final content = AppContent(
      levels: [],
      achievements: [],
      milestones: [],
      healthFacts: [],
      withdrawal: [],
      notInhaledFacts: [],
      quotes: [],
      sosTips: [],
      triggerTips: tips,
      articles: [],
    );
    for (final t in Trigger.values) {
      expect(content.triggerTipFor(t.name, {}), isNotNull, reason: t.name);
    }
    expect(content.triggerTipFor('ritual', {'sticks'}), contains('Стик'));
    expect(content.triggerTipFor('ritual', {'cigarettes'}), tips['ritual']!.firstWhere((t) => t.general).text);
  });
}
