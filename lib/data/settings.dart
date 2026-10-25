import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loaded in main() before the app starts.
final prefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'themeMode';

  @override
  ThemeMode build() {
    final saved = ref.watch(prefsProvider).getString(_key);
    return ThemeMode.values.where((m) => m.name == saved).firstOrNull ?? ThemeMode.system;
  }

  void set(ThemeMode mode) {
    ref.read(prefsProvider).setString(_key, mode.name);
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Calming exercise shown in SOS. No breath-holding anywhere: it makes anxious users panic.
enum SosExercise { breathing, countdown, grounding }

class SosExerciseNotifier extends Notifier<SosExercise> {
  static const _key = 'sosExercise';

  @override
  SosExercise build() {
    final saved = ref.watch(prefsProvider).getString(_key);
    return SosExercise.values.where((e) => e.name == saved).firstOrNull ?? SosExercise.breathing;
  }

  void set(SosExercise exercise) {
    ref.read(prefsProvider).setString(_key, exercise.name);
    state = exercise;
  }
}

final sosExerciseProvider = NotifierProvider<SosExerciseNotifier, SosExercise>(SosExerciseNotifier.new);

class NotificationsEnabledNotifier extends Notifier<bool> {
  static const _key = 'notifications';

  @override
  bool build() => ref.watch(prefsProvider).getBool(_key) ?? true;

  void set(bool on) {
    ref.read(prefsProvider).setBool(_key, on);
    state = on;
  }
}

/// Health-milestone notifications (on by default; rare and never at night).
final notificationsEnabledProvider = NotifierProvider<NotificationsEnabledNotifier, bool>(
  NotificationsEnabledNotifier.new,
);

/// Which collapsible sections of a screen are open; everything starts collapsed. Keyed by screen.
class ExpandedSectionsNotifier extends Notifier<Set<String>> {
  ExpandedSectionsNotifier(this.screen);

  final String screen;

  String get _key => 'expanded.$screen';

  @override
  Set<String> build() => (ref.watch(prefsProvider).getStringList(_key) ?? const []).toSet();

  void toggle(String section) => _save(state.contains(section) ? ({...state}..remove(section)) : {...state, section});

  void setAll(Iterable<String> sections) => _save(sections.toSet());

  void _save(Set<String> open) {
    ref.read(prefsProvider).setStringList(_key, open.toList());
    state = open;
  }
}

final expandedSectionsProvider = NotifierProvider.family<ExpandedSectionsNotifier, Set<String>, String>(
  ExpandedSectionsNotifier.new,
);

/// Reminders to fill in «Дневник самочувствия»: off by default; every [periodDays] days at [time].
class DiaryReminder {
  const DiaryReminder({this.enabled = false, this.periodDays = 1, this.time = const TimeOfDay(hour: 20, minute: 0)});

  static const periods = [1, 3, 7];

  final bool enabled;
  final int periodDays;
  final TimeOfDay time;

  /// When the next entry is due: [periodDays] after the last entry's day, at [time]; right away if there is none.
  DateTime? dueAt(DateTime? lastEntry) {
    if (!enabled) return null;
    if (lastEntry == null) return DateTime(2000, 1, 1, time.hour, time.minute);
    return DateTime(lastEntry.year, lastEntry.month, lastEntry.day + periodDays, time.hour, time.minute);
  }

  DiaryReminder copyWith({bool? enabled, int? periodDays, TimeOfDay? time}) => DiaryReminder(
    enabled: enabled ?? this.enabled,
    periodDays: periodDays ?? this.periodDays,
    time: time ?? this.time,
  );
}

class DiaryReminderNotifier extends Notifier<DiaryReminder> {
  static const _key = 'diaryReminder';

  @override
  DiaryReminder build() {
    final saved = ref.watch(prefsProvider).getStringList(_key);
    if (saved == null || saved.length != 3) return const DiaryReminder();
    final minutes = int.tryParse(saved[2]) ?? 20 * 60;
    return DiaryReminder(
      enabled: saved[0] == 'true',
      periodDays: int.tryParse(saved[1]) ?? 1,
      time: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
  }

  void set(DiaryReminder r) {
    ref.read(prefsProvider).setStringList(_key, [
      '${r.enabled}',
      '${r.periodDays}',
      '${r.time.hour * 60 + r.time.minute}',
    ]);
    state = r;
  }
}

final diaryReminderProvider = NotifierProvider<DiaryReminderNotifier, DiaryReminder>(DiaryReminderNotifier.new);

/// One-time hints already closed by the user (e.g. how to read the craving map).
class SeenHintsNotifier extends Notifier<Set<String>> {
  static const _key = 'seenHints';

  @override
  Set<String> build() => (ref.watch(prefsProvider).getStringList(_key) ?? const []).toSet();

  void dismiss(String hint) {
    state = {...state, hint};
    ref.read(prefsProvider).setStringList(_key, state.toList());
  }
}

final seenHintsProvider = NotifierProvider<SeenHintsNotifier, Set<String>>(SeenHintsNotifier.new);

/// Badges the user has opened at least once. Badges earned before this was added (2026-10-25) count as seen.
class SeenAchievementsNotifier extends Notifier<({DateTime since, Set<String> ids})> {
  static const _sinceKey = 'achievementsSeenSince';
  static const _idsKey = 'seenAchievements';

  @override
  ({DateTime since, Set<String> ids}) build() {
    final prefs = ref.watch(prefsProvider);
    var since = prefs.getInt(_sinceKey);
    if (since == null) {
      since = DateTime.now().millisecondsSinceEpoch;
      prefs.setInt(_sinceKey, since);
    }
    return (since: DateTime.fromMillisecondsSinceEpoch(since), ids: (prefs.getStringList(_idsKey) ?? const []).toSet());
  }

  void markSeen(String id) {
    if (state.ids.contains(id)) return;
    state = (since: state.since, ids: {...state.ids, id});
    ref.read(prefsProvider).setStringList(_idsKey, state.ids.toList());
  }
}

final seenAchievementsProvider = NotifierProvider<SeenAchievementsNotifier, ({DateTime since, Set<String> ids})>(
  SeenAchievementsNotifier.new,
);
