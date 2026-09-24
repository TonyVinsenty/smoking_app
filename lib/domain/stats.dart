import '../data/database.dart';

/// Money the user used to spend per day on all products.
double dailyCost(List<SmokingProduct> products) =>
    products.fold(0, (sum, p) => sum + p.amount / p.period.days / p.unitsPerPack * p.packPrice);

/// Money saved over a smoke-free [duration].
double moneySaved(List<SmokingProduct> products, Duration duration) =>
    dailyCost(products) * duration.inMinutes / Duration.minutesPerDay;

/// Units (cigarettes, sticks, devices, bottles) not consumed over [duration], per product type.
Map<ProductType, double> unitsAvoided(List<SmokingProduct> products, Duration duration) {
  final days = duration.inMinutes / Duration.minutesPerDay;
  return {for (final p in products) p.type: p.amount / p.period.days * days};
}

Duration attemptDuration(Attempt a, DateTime now) {
  final d = (a.endedAt ?? now).difference(a.startedAt);
  return d.isNegative ? Duration.zero : d;
}

/// Smoke-free time summed over all attempts (never lost after a relapse).
Duration totalSmokeFree(List<Attempt> attempts, DateTime now) =>
    attempts.fold(Duration.zero, (sum, a) => sum + attemptDuration(a, now));

const xpPerHour = 1;
const xpPerResistedCraving = 10;

/// XP = smoke-free hours + resisted cravings + achievements (each achievement counted once).
int totalXp({
  required List<Attempt> attempts,
  required List<Craving> cravings,
  required Iterable<int> achievementXp,
  required DateTime now,
}) =>
    totalSmokeFree(attempts, now).inHours * xpPerHour +
    cravings.where((c) => c.resisted).length * xpPerResistedCraving +
    achievementXp.fold(0, (a, b) => a + b);
