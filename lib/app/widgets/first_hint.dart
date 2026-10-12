import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import 'cards.dart';

/// A short tip shown the first time a less obvious screen opens, until the user closes it.
class FirstHint extends ConsumerWidget {
  const FirstHint({super.key, required this.id, required this.title, required this.text});

  final String id;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(seenHintsProvider).contains(id)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TipCard(
        title: title,
        icon: Icons.info_outline,
        padding: const EdgeInsets.fromLTRB(20, 18, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => ref.read(seenHintsProvider.notifier).dismiss(id),
                child: Text(AppLocalizations.of(context).hintGotIt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
