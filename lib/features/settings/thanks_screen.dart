import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';

/// Boosty tiers, highest first: 700 ₽ «Соавтор», 300 ₽ «Тестировщик», 100 ₽ «Спасибо».
enum SupporterTier { coauthors, testers, supporters }

/// Names of Boosty supporters, shipped with each build (added only with consent, under the name they chose).
final supportersProvider = FutureProvider<Map<SupporterTier, List<String>>>((ref) async {
  final json = jsonDecode(await rootBundle.loadString('assets/content/supporters.json')) as Map<String, dynamic>;
  return {
    for (final t in SupporterTier.values) t: [...(json[t.name] as List? ?? const []).cast<String>()],
  };
});

/// «Спасибо»: credits for the people who support Zero (owner chose the «film credits» look, 2026-10-14).
class ThanksScreen extends ConsumerWidget {
  const ThanksScreen({super.key, required this.boostyPage});

  final Uri boostyPage;

  static Future<void> open(BuildContext context, Uri boostyPage) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ThanksScreen(boostyPage: boostyPage)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final names = ref.watch(supportersProvider).value ?? const {};
    final muted = theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
    final caption = theme.textTheme.labelMedium?.copyWith(
      color: scheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    );
    final nameStyles = {
      SupporterTier.coauthors: TextStyle(
        fontFamily: displayFont,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.4,
        color: AppColors.of(context).reward,
      ),
      SupporterTier.testers: TextStyle(fontFamily: displayFont, fontSize: 18, fontWeight: FontWeight.w700, height: 1.6),
      SupporterTier.supporters: TextStyle(
        fontFamily: displayFont,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.9,
      ),
    };

    Widget tier(SupporterTier t) {
      final list = names[t] ?? const [];
      return Column(
        children: [
          Text(l.thanksTier(t.name).toUpperCase(), style: caption, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          if (list.isEmpty)
            Text(l.thanksEmpty, style: muted, textAlign: TextAlign.center)
          else
            for (final name in list) Text(name, style: nameStyles[t], textAlign: TextAlign.center),
        ],
      );
    }

    final dots = Text('•   •   •', style: TextStyle(color: scheme.outlineVariant));
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          Center(
            child: CircleAvatar(
              radius: 32,
              backgroundColor: scheme.primaryContainer,
              child: Icon(Icons.favorite, size: 30, color: scheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(l.thanksTitle, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(l.thanksSubtitle, style: muted, textAlign: TextAlign.center),
          for (final (i, t) in SupporterTier.values.indexed) ...[
            SizedBox(height: i == 0 ? 32 : 20),
            if (i > 0) ...[Center(child: dots), const SizedBox(height: 20)],
            tier(t),
          ],
          const SizedBox(height: 36),
          Text(l.thanksJoin, style: muted, textAlign: TextAlign.center),
          Center(
            child: TextButton.icon(
              onPressed: () => launchUrl(boostyPage, mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(l.thanksBoosty),
            ),
          ),
        ],
      ),
    );
  }
}
