import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings.dart';

/// Launcher icon variants (owner's decision 2026-10-13: all four selectable, 9a by default).
/// Android switches activity-aliases `.Icon<id>`; iOS uses alternate icons `AppIcon-<id>`.
enum AppIconVariant {
  v9a('9a'),
  v9b('9b'),
  v7a('7a'),
  v7b('7b');

  const AppIconVariant(this.id);

  final String id;

  String get preview => 'assets/icons/$id.png';
}

const _channel = MethodChannel('zero/app_icon');

class AppIconNotifier extends Notifier<AppIconVariant> {
  static const _key = 'appIcon';

  @override
  AppIconVariant build() {
    final saved = ref.watch(prefsProvider).getString(_key);
    return AppIconVariant.values.where((v) => v.id == saved).firstOrNull ?? AppIconVariant.v9a;
  }

  /// Returns false if the system refused (the old icon stays).
  Future<bool> set(AppIconVariant variant) async {
    final previous = state;
    if (variant == previous) return true;
    final prefs = ref.read(prefsProvider);
    // Saved first: on Android the switch may close the app before the call returns.
    await prefs.setString(_key, variant.id);
    state = variant;
    try {
      await _channel.invokeMethod<void>('set', variant.id);
      return true;
    } on Exception catch (e) {
      debugPrint('App icon switch failed: $e');
      await prefs.setString(_key, previous.id);
      state = previous;
      return false;
    }
  }
}

final appIconProvider = NotifierProvider<AppIconNotifier, AppIconVariant>(AppIconNotifier.new);
