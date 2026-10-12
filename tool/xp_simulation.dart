// ignore_for_file: avoid_print
// Simulates XP / levels / achievements over 3 years, hour by hour.
// Run from project root: dart run tool/xp_simulation.dart [content dir] [--fit]
//   content dir — default assets/content/ru/ (pass an old copy to compare "before/after")
//   --fit       — rewrite xpRequired of levels 15–50 in levels.json: levels fill the longest pauses
//                 between badges of the reference profiles, level 50 at day 1200 (~3.3 years)
import 'dart:convert';
import 'dart:io';

class Profile {
  final String name, product; // product: cigarettes | sticks | disposable | liquid
  final double unitsPerDay, rubPerDay;
  final double cravingFactor; // 1 = active SOS user
  final int? relapseDay; // relapse at this day, restart 1 day later
  Profile(this.name, this.product, this.unitsPerDay, this.rubPerDay, {this.cravingFactor = 1, this.relapseDay});
}

class Run {
  final xp = <int>[]; // XP at each hour
  final badges = <double>[]; // hours when a badge was earned
  final rewards = <double>[]; // hours when a badge or a level-up happened
  final checkpoints = <int>[]; // level at [checkpointHours]
  var unlocked = 0;
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

/// Threshold of a condition: a number, or per main product for unitsAvoided.
num threshold(Map c, String product) => c['value'] is Map ? (c['value'] as Map)[product] as num : c['value'] as num;

const checkpointHours = [24, 168, 720, 2160, 4380, 8760, 17520, 26280];

Run simulate(Profile p, List<Map> achs, List<int> levels, int hours) {
  final run = Run();
  final unlocked = <String>{};
  var achXp = 0, cravings = 0.0, level = 1, attempts = 1;
  var attemptStart = 0.0;
  for (var h = 0; h <= hours; h++) {
    final day = h / 24;
    if (p.relapseDay != null && h == p.relapseDay! * 24) attemptStart = double.infinity;
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
      if (!unlocked.contains(a['id']) && vals[c['type']]! >= threshold(c, p.product)) {
        unlocked.add(a['id']); achXp += a['xp'] as int; got = true;
      }
    }
    final xp = smokeFreeH.floor() + resisted * 10 + achXp;
    run.xp.add(xp);
    var newLevel = level;
    while (newLevel < levels.length && xp >= levels[newLevel]) { newLevel++; }
    if (got) run.badges.add(h.toDouble());
    if (newLevel > level || got) run.rewards.add(h.toDouble());
    level = newLevel;
    if (checkpointHours.contains(h)) run.checkpoints.add(level);
  }
  run.unlocked = unlocked.length;
  return run;
}

/// Day each level 15..50 is reached by a typical user: placed in the pauses between badges,
/// about one level a month in year 2, level 50 at ~3.4 years.
const levelDays = [36, 45, 55, 65, 78, 92, 107, 123, 140, 158, 177, 197, 218, 240, 263, 287, 312, 338, 365, // 15–33
  398, 431, 464, 497, 530, 563, 596, 629, 662, 695, // 34–43
  780, 825, 940, 1062, 1130, 1190, 1260]; // 44–50

/// XP of level i (15..50) reached on [days] by a typical user: average of [refs] over a window
/// around the day (±8 %), so steps from badges are smoothed and one badge rarely skips two levels.
List<int> thresholds(List<Run> refs, List<int> days) => [
  for (final d in days)
    () {
      final w = (d * 0.08).round();
      var sum = 0;
      for (final r in refs) { for (var x = d - w; x <= d + w; x++) { sum += r.xp[x * 24]; } }
      return (sum / refs.length / (2 * w + 1) / 50).round() * 50;
    }(),
];

/// Penalty for pauses without a reward that are longer than the goal of their period.
double pausePenalty(Run r, List<int> fixedLevels, List<int> thr) {
  final events = <double>{...r.badges};
  for (final t in [...fixedLevels.skip(1), ...thr]) {
    final h = r.xp.indexWhere((x) => x >= t);
    if (h >= 0) events.add(h.toDouble());
  }
  final sorted = events.toList()..sort();
  var worst = 0.0;
  for (final [s, e, goal] in [[168, 2160, 14 * 24], [2160, 26280, 30 * 24]]) {
    var prev = sorted.lastWhere((t) => t <= s, orElse: () => 0);
    for (final t in [...sorted.where((t) => t > s && t <= e), e.toDouble()]) {
      final over = (t - prev) / goal - 0.8;
      if (over > 0) worst += over * over;
      prev = t;
    }
  }
  return worst;
}

/// Moves the days of levels 15..50 (each within ±25 % of [levelDays], in order) to shorten the long
/// pauses of all profiles, then writes the XP thresholds into levels.json.
void fit(String root, List<Run> runs, List<int> levels) {
  final fixed = levels.take(15).toList();
  // Neighbouring levels at least 800 XP apart, so two level-ups never come on the same day.
  double score(List<int> days) {
    final thr = thresholds(runs.take(4).toList(), days);
    var tooClose = 0.0;
    for (var i = 0; i < thr.length; i++) {
      final gap = thr[i] - (i == 0 ? fixed.last : thr[i - 1]);
      if (gap < 800) tooClose += (800 - gap) / 100;
    }
    return tooClose + runs.map((r) => pausePenalty(r, fixed, thr)).reduce((a, b) => a + b);
  }
  var days = [...levelDays], best = score(days);
  for (var improved = true; improved;) {
    improved = false;
    for (var i = 0; i < days.length - 1; i++) {
      for (final step in [-12, -6, -3, 3, 6, 12]) {
        final d = days[i] + step;
        if ((d - levelDays[i]).abs() > levelDays[i] * 0.3 || (i > 0 && d <= days[i - 1] + 3) || d >= days[i + 1] - 3) continue;
        final cand = [...days]..[i] = d;
        final s = score(cand);
        if (s < best - 1e-9) { best = s; days = cand; improved = true; }
      }
    }
  }
  final xps = thresholds(runs.take(4).toList(), days);
  final file = File('$root/levels.json');
  var text = file.readAsStringSync();
  for (var i = 0; i < xps.length; i++) {
    text = text.replaceFirst(RegExp('"level": ${i + 15}, "xpRequired": ' r'\d+'), '"level": ${i + 15}, "xpRequired": ${xps[i]}');
  }
  file.writeAsStringSync(text);
  print('Дни уровней 15–50: ${days.join(', ')}');
}

void main(List<String> args) {
  final paths = args.where((a) => !a.startsWith('--')).toList();
  final root = paths.isEmpty ? 'assets/content/ru' : paths.first;
  final achs = (jsonDecode(File('$root/achievements.json').readAsStringSync()) as List).cast<Map>();
  List<int> levels() => (jsonDecode(File('$root/levels.json').readAsStringSync()) as List)
      .map((e) => e['xpRequired'] as int).toList();
  final profiles = [
    Profile('Сигареты 15/д', 'cigarettes', 15, 15 / 20 * 280),
    Profile('Стики 15/д', 'sticks', 15, 15 / 20 * 260),
    Profile('Одноразки 1/4д', 'disposable', 0.25, 700 / 4),
    Profile('Жидкость 1/10д', 'liquid', 0.1, 50),
    Profile('Сигареты, без SOS', 'cigarettes', 15, 210, cravingFactor: 0.25),
    Profile('Сигареты, срыв на 4-й день', 'cigarettes', 15, 210, relapseDay: 4),
  ];
  if (args.contains('--fit')) {
    fit(root, [for (final p in profiles) simulate(p, achs, levels(), 1400 * 24)], levels());
  }
  const periods = [[0, 168], [168, 2160], [2160, 8760], [8760, 26280]];
  print('Профиль | ур. 1д / 1нед / 1мес / 3мес / 6мес / 1год / 2года / 3года | макс. пауза: нед 1 · нед 2–мес 3 · мес 4–12 · годы 2–3 | наград');
  for (final p in profiles) {
    final run = simulate(p, achs, levels(), 26280);
    final gaps = [
      for (final [s, e] in periods)
        () {
          var gap = 0.0, at = 0.0, prev = run.rewards.lastWhere((t) => t <= s, orElse: () => 0);
          for (final t in [...run.rewards.where((t) => t > s && t <= e), e.toDouble()]) {
            if (t - prev > gap) { gap = t - prev; at = prev; }
            prev = t;
          }
          return args.contains("--where") ? "${fmt(gap)} (с ${fmt(at)})" : fmt(gap);
        }(),
    ];
    print('${p.name} | ${run.checkpoints.join(' / ')} | ${gaps.join(' · ')} | ${run.unlocked}/${achs.length}');
  }
}
