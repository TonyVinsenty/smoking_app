import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/providers.dart';
import '../domain/stats.dart';
import '../l10n/app_localizations.dart';
import 'format.dart';
import 'theme.dart';

/// The home-screen widgets draw themselves natively (they tick every minute without the app), so they get
/// rates and ready-made texts rather than numbers: days, money and units grow linearly from [start].
/// It also brings back SOS taps on iPhone widgets (see AppShortcuts).
const homeWidgetChannel = MethodChannel('zero/home_widget');

/// Word forms for each plural category, so the native side can pick one for any count.
Map<String, String> _forms(String Function(int n) form) => {
  'one': form(1),
  'few': form(2),
  'many': form(5),
  'other': form(2),
};

Map<String, int> _colors(Brightness brightness, AppPalette palette) {
  final theme = buildTheme(brightness, palette);
  final s = theme.colorScheme;
  final c = theme.extension<AppColors>()!;
  return {
    'card': (brightness == Brightness.light ? s.surfaceContainerLowest : s.surfaceContainer).toARGB32(),
    'text': s.onSurface.toARGB32(),
    'muted': s.onSurfaceVariant.toARGB32(),
    'primary': s.primary.toARGB32(),
    'onPrimary': s.onPrimary.toARGB32(),
    'primaryContainer': s.primaryContainer.toARGB32(),
    'onPrimaryContainer': s.onPrimaryContainer.toARGB32(),
    'reward': c.reward.toARGB32(),
    'rewardContainer': c.rewardContainer.toARGB32(),
  };
}

/// Everything the widgets show; `start` is null between attempts.
Map<String, Object?> homeWidgetPayload({
  required AppLocalizations l,
  required Attempt? attempt,
  required List<SmokingProduct> products,
  required AppPalette palette,
}) {
  final main = mainProduct(products);
  return {
    'locale': l.localeName,
    'start': attempt?.startedAt.millisecondsSinceEpoch,
    'moneyPerDay': dailyCost(products),
    'unitsPerDay': main == null ? 0.0 : unitsAvoided(products, const Duration(days: 1))[main],
    'days': _forms(l.homeDays),
    'units': _forms((n) => main == null ? '' : avoidedText(l, main, n).replaceFirst(RegExp(r'\d+'), '{n}')),
    'clock': l.widgetClock('{h}', '{m}'),
    'money': l.money('{n}'),
    'smokeFree': l.widgetSmokeFree,
    'saved': l.homeMoneySaved,
    'notSmoked': l.homeNotSmoked,
    'sos': l.sosButton,
    'sosShort': l.shortcutSos,
    'sosLong': l.widgetSos,
    'noAttempt': l.homeNoAttemptTitle,
    'light': _colors(Brightness.light, palette),
    'dark': _colors(Brightness.dark, palette),
  };
}

/// Hands the widgets fresh data whenever the attempt, habits, colours or language change.
/// Lives over HomeShell only: before onboarding ends the widgets just open the app.
class HomeWidgetSync extends ConsumerStatefulWidget {
  const HomeWidgetSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<HomeWidgetSync> createState() => _HomeWidgetSyncState();
}

class _HomeWidgetSyncState extends ConsumerState<HomeWidgetSync> {
  /// The payload last given to the widgets.
  String? _sent;

  @override
  Widget build(BuildContext context) {
    final attempt = ref.watch(currentAttemptProvider).value;
    final products = ref.watch(productsProvider).value;
    if (products != null) {
      final payload = jsonEncode(
        homeWidgetPayload(
          l: AppLocalizations.of(context),
          attempt: attempt,
          products: attempt == null ? const [] : productsOf(products, attempt.id),
          palette: ref.watch(appPaletteProvider),
        ),
      );
      if (payload != _sent) {
        _sent = payload;
        // No widgets is no reason to stop the app (tests have no native side).
        unawaited(homeWidgetChannel.invokeMethod<void>('update', payload).catchError((Object _) {}));
      }
    }
    return widget.child;
  }
}
