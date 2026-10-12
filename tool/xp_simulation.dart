// Simulates XP / levels / achievements over 3 years, hour by hour.
import 'dart:convert';
import 'dart:io';

final root = 'assets/content/ru/'; // run from project root: dart run tool/xp_simulation.dart

class Profile {
  final String name;
  final double unitsPerDay, rubPerDay;
  final double cravingFactor; // 1 = active SOS user
  final int? relapseDay; // relapse at this day, restart 1 day later
  Profile(this.name, this.unitsPerDay, this.rubPerDay, {this.cravingFactor = 1, this.relapseDay});
}

double cravingsPerDay(double day) =>
    day < 3 ? 4 : day < 14 ? 2 : day < 30 ? 1 : day < 90 ? 0.3 : 0.05;

int articlesByDay(double day) =>
    day < 1 ? 1 : day < 3 ? 2 : day < 7 ? 3 : day < 14 ? 5 : day < 30 ? 8 : day < 60 ? 10 : day < 90 ? 13 : 15;

String fmt(double h) {
  if (h < 24) return '${h.round()} ч';
  final d = h / 24;
  if (d < 14) return '${d.toStringAsFixed(d < 3 ? 1 : 0)} дн';
  if (d < 60) return '${(d / 7).toStringAsFixed(1)} нед';
  return '${(d / 30.4).toStringAsFixed(1)} мес';
}

void main() {
  final levels = (jsonDecode(File('${root}levels.json').readAsStringSync()) as List)
      .map((e) => e['xpRequired'] as int).toList();
  final achs = (jsonDecode(File('${root}achievements.json').readAsStringSync()) as List).cast<Map>();
  final profiles = [
    Profile('Сигареты 15/день, 280 ₽/пачка', 15, 15 / 20 * 280),
    Profile('Стики IQOS 15/день, 260 ₽/пачка', 15, 15 / 20 * 260),
    Profile('Одноразки 1 на 4 дня, 700 ₽', 0.25, 700 / 4),
    Profile('Жидкость 1 флакон/10 дн, 500 ₽', 0.1, 50),
    Profile('Сигареты, «тихий» (SOS почти не жмёт)', 15, 210, cravingFactor: 0.25),
    Profile('Сигареты, срыв на 4-й день', 15, 210, relapseDay: 4),
  ];
  const checkpoints = [1, 6, 24, 72, 168, 336, 720, 1440, 2160, 4380, 8760, 17520, 26280];
  const periods = [[0, 24, 'день 1'], [24, 168, 'дни 2–7'], [168, 720, 'нед 2–4'], [720, 2160, 'мес 2–3'],
    [2160, 4380, 'мес 4–6'], [4380, 8760, 'мес 7–12'], [8760, 17520, 'год 2'], [17520, 26280, 'год 3']];

  for (final p in profiles) {
    final unlocked = <String>{};
    var achXp = 0, cravings = 0.0, level = 1;
    final rewards = <double>[]; // hours when any reward happened
    final unitEvents = <String>[];
    final cp = <String>[];
    var attemptStart = 0.0, attempts = 1;
    for (var h = 0; h <= 26280; h++) {
      final day = h / 24;
      if (p.relapseDay != null && h == p.relapseDay! * 24) { attemptStart = double.infinity; }
      if (p.relapseDay != null && h == (p.relapseDay! + 1) * 24) { attemptStart = h.toDouble(); attempts = 2; }
      final inAttempt = attemptStart <= h;
      final smokeFreeH = p.relapseDay == null ? h.toDouble()
          : (h < p.relapseDay! * 24 ? h.toDouble() : p.relapseDay! * 24.0 + (inAttempt ? h - attemptStart : 0));
      final curMin = inAttempt ? (h - attemptStart) * 60 : 0;
      if (inAttempt || p.relapseDay == null) cravings += cravingsPerDay(day) * p.cravingFactor / 24;
      final resisted = cravings.floor();
      final vals = {
        'smokeFreeMinutes': curMin, 'unitsAvoided': smokeFreeH / 24 * p.unitsPerDay,
        'moneySavedRub': smokeFreeH / 24 * p.rubPerDay, 'cravingsResisted': resisted,
        'articlesRead': articlesByDay(day), 'attemptsStarted': attempts, 'comebackAfterRelapse': attempts - 1,
      };
      var got = false;
      for (final a in achs) {
        final c = a['condition'] as Map;
        if (!unlocked.contains(a['id']) && vals[c['type']]! >= (c['value'] as num)) {
          unlocked.add(a['id']); achXp += a['xp'] as int; got = true;
          if (c['type'] == 'unitsAvoided') unitEvents.add('${c['value']} → ${fmt(h.toDouble())}');
        }
      }
      final xp = smokeFreeH.floor() + resisted * 10 + achXp;
      var newLevel = level;
      while (newLevel < levels.length && xp >= levels[newLevel]) newLevel++;
      if (newLevel > level || got) rewards.add(h.toDouble());
      level = newLevel;
      if (checkpoints.contains(h)) cp.add('${fmt(h.toDouble())}: ур.$level (${unlocked.length} наград)');
    }
    print('\n=== ${p.name}  (${p.rubPerDay.round()} ₽/день)');
    print(cp.join(' | '));
    for (final per in periods) {
      final s = per[0] as int, e = per[1] as int;
      final r = rewards.where((t) => t > s && t <= e).toList();
      var gap = 0.0, prev = rewards.lastWhere((t) => t <= s, orElse: () => 0);
      for (final t in [...r, e.toDouble()]) { if (t - prev > gap) gap = t - prev; prev = t; }
      print('  ${per[2]}: ${r.length} моментов награды, макс. пауза ${fmt(gap)}');
    }
    print('  за количество: ${unitEvents.isEmpty ? 'ни одной' : unitEvents.join(', ')}');
    print('  итого за 3 года: ${unlocked.length} из ${achs.length} наград');
  }
}
