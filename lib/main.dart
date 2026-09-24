import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/home_shell.dart';
import 'app/theme.dart';
import 'data/providers.dart';
import 'data/settings.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: const SmokingApp(),
  ));
}

class SmokingApp extends ConsumerWidget {
  const SmokingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final largeText = ref.watch(largeTextProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      locale: const Locale('ru'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        if (!largeText) return child!;
        final mq = MediaQuery.of(context);
        final scale = mq.textScaler.scale(100) / 100 * largeTextScale;
        return MediaQuery(data: mq.copyWith(textScaler: TextScaler.linear(scale)), child: child!);
      },
      home: const _Root(),
    );
  }
}

/// Shows onboarding until the first attempt exists.
class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(attemptsProvider).when(
          data: (attempts) => attempts.isEmpty ? const OnboardingScreen() : const HomeShell(),
          loading: () => const Scaffold(),
          error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
        );
  }
}
