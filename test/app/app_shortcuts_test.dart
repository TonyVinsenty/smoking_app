import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smoking_app/app/app_shortcuts.dart';
import 'package:smoking_app/data/database.dart';
import 'package:smoking_app/data/providers.dart';
import 'package:smoking_app/data/settings.dart';
import 'package:smoking_app/features/sos/sos_screen.dart';
import 'package:smoking_app/l10n/app_localizations.dart';

class _FakeQuickActions extends QuickActions {
  QuickActionHandler? handler;
  final sets = <List<ShortcutItem>>[];

  @override
  Future<void> initialize(QuickActionHandler handler) async => this.handler = handler;

  @override
  Future<void> setShortcutItems(List<ShortcutItem> items) async => sets.add(items);
}

void main() {
  // SOS keeps the screen on (wakelock_plus); there is no platform side in tests.
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger.setMockMessageHandler(
      'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
      (_) async => const StandardMessageCodec().encodeMessage(<Object?>[null]),
    );
  });

  testWidgets('the icon menu offers SOS once and opens it over the other screens', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final actions = _FakeQuickActions();
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          prefsProvider.overrideWithValue(prefs),
          quickActionsProvider.overrideWithValue(actions),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          locale: const Locale('ru'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: AppShortcuts(navigatorKey: navigatorKey, child: const Scaffold()),
        ),
      ),
    );

    expect(actions.sets, hasLength(1));
    expect(
      [for (final i in actions.sets.single) (i.type, i.localizedTitle, i.icon)],
      [(sosShortcut, 'Хочу закурить', 'shortcut_sos')],
    );

    // Some other screen is open: it closes, SOS opens on top of Home.
    navigatorKey.currentState!.push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('other'))));
    await tester.pumpAndSettle();
    actions.handler!(sosShortcut);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('other'), findsNothing);
    expect(find.byType(SosScreen), findsOneWidget);

    // Rebuilds do not send the same menu again.
    await tester.pump(const Duration(seconds: 1));
    expect(actions.sets, hasLength(1));

    await tester.pumpWidget(const SizedBox());
  });
}
