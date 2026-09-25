import '../data/database.dart';

/// Parts of the day for the craving map: night 0–6, morning 6–12, afternoon 12–18, evening 18–24.
enum DayPart { morning, afternoon, evening, night }

DayPart dayPartOf(DateTime t) => switch (t.hour) {
  < 6 => DayPart.night,
  < 12 => DayPart.morning,
  < 18 => DayPart.afternoon,
  _ => DayPart.evening,
};

/// Counts for one bar: all cravings and how many of them were resisted.
class CravingCount {
  int total = 0;
  int resisted = 0;

  void add(Craving c) {
    total++;
    if (c.resisted) resisted++;
  }
}

/// Personal craving patterns («Карта тяги») for cravings logged since [from] (null = all time).
class CravingStats {
  CravingStats(List<Craving> all, {DateTime? from}) {
    for (final c in all) {
      if (from != null && c.at.isBefore(from)) continue;
      summary.add(c);
      byPart[dayPartOf(c.at)]!.add(c);
      byHour[c.at.hour].add(c);
      byWeekday[c.at.weekday - 1].add(c);
      byTrigger.putIfAbsent(c.trigger, CravingCount.new).add(c);
    }
  }

  final summary = CravingCount();
  final byPart = {for (final p in DayPart.values) p: CravingCount()};
  final byHour = List.generate(24, (_) => CravingCount());

  /// Monday first.
  final byWeekday = List.generate(7, (_) => CravingCount());

  /// Key null = trigger not given (skipped in SOS).
  final Map<Trigger?, CravingCount> byTrigger = {};

  bool get isEmpty => summary.total == 0;

  /// Most frequent part of the day, or null when there is no data.
  DayPart? get topPart => isEmpty ? null : _maxKey(byPart);

  /// Hour (0–23) with the most cravings.
  int? get peakHour => isEmpty ? null : _maxKey(byHour.asMap());

  /// Most frequent known trigger (ignores skipped ones).
  Trigger? get topTrigger => _maxKey({
    for (final e in byTrigger.entries)
      if (e.key != null) e.key!: e.value,
  });

  /// Triggers sorted by frequency, most frequent first; «not given» last.
  List<MapEntry<Trigger?, CravingCount>> get triggersSorted => byTrigger.entries.toList()
    ..sort((a, b) {
      if ((a.key == null) != (b.key == null)) return a.key == null ? 1 : -1;
      return b.value.total.compareTo(a.value.total);
    });

  static K? _maxKey<K>(Map<K, CravingCount> m) {
    K? best;
    var max = 0;
    for (final e in m.entries) {
      if (e.value.total > max) {
        max = e.value.total;
        best = e.key;
      }
    }
    return best;
  }
}
