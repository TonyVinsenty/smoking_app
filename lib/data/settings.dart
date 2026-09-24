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

class LargeTextNotifier extends Notifier<bool> {
  static const _key = 'largeText';

  @override
  bool build() => ref.watch(prefsProvider).getBool(_key) ?? false;

  void set(bool on) {
    ref.read(prefsProvider).setBool(_key, on);
    state = on;
  }
}

/// Accessibility option: scales all text up.
final largeTextProvider = NotifierProvider<LargeTextNotifier, bool>(LargeTextNotifier.new);

const largeTextScale = 1.25;

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
