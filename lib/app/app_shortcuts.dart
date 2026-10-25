import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_actions/quick_actions.dart';

import '../features/sos/sos_screen.dart';
import '../l10n/app_localizations.dart';
import 'home_widget.dart';

/// The long-press menu of the app icon: «Хочу закурить» opens SOS straight away.
const sosShortcut = 'sos';

/// The system side of the menu; a stand-in in tests.
final quickActionsProvider = Provider<QuickActions>((_) => const QuickActions());

/// The menu items. The icon is looked up by name: drawable on Android, image set on iOS.
List<ShortcutItem> shortcutItems(AppLocalizations l) => [
  ShortcutItem(type: sosShortcut, localizedTitle: l.shortcutSos, icon: 'shortcut_sos'),
];

/// Keeps the menu up to date and opens SOS when it is picked (the screens over Home close first).
/// Lives over HomeShell only: during onboarding there is nothing to open yet.
class AppShortcuts extends ConsumerStatefulWidget {
  const AppShortcuts({super.key, required this.navigatorKey, required this.child});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ConsumerState<AppShortcuts> createState() => _AppShortcutsState();
}

class _AppShortcutsState extends ConsumerState<AppShortcuts> {
  /// The titles last given to the system.
  String? _shown;

  @override
  void initState() {
    super.initState();
    unawaited(_quiet(ref.read(quickActionsProvider).initialize(_picked)));
    // The iPhone widgets' SOS (zero://sos): a tap that started the app waits on the native side until asked for.
    // On Android the widgets go through the quick_actions launch path instead.
    homeWidgetChannel.setMethodCallHandler((call) async {
      if (call.method == 'open') _picked(call.arguments as String);
    });
    unawaited(
      _quiet(
        homeWidgetChannel.invokeMethod<String>('launchAction').then((action) {
          if (action != null) _picked(action);
        }),
      ),
    );
  }

  @override
  void dispose() {
    homeWidgetChannel.setMethodCallHandler(null);
    super.dispose();
  }

  /// No menu is no reason to stop the app (tests have no system side).
  static Future<void> _quiet(Future<void> call) => call.catchError((Object _) {});

  void _picked(String type) {
    final navigator = widget.navigatorKey.currentState;
    if (navigator == null || type != sosShortcut) return;
    navigator.popUntil((route) => route.isFirst);
    unawaited(navigator.push(SosScreen.route()));
  }

  @override
  Widget build(BuildContext context) {
    final items = shortcutItems(AppLocalizations.of(context));
    final shown = [for (final i in items) '${i.type}\n${i.localizedTitle}'].join('\n');
    if (shown != _shown) {
      _shown = shown;
      unawaited(_quiet(ref.read(quickActionsProvider).setShortcutItems(items)));
    }
    return widget.child;
  }
}
