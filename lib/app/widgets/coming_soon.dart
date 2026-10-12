import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'tab_page.dart';

/// Placeholder tab for screens that are not built yet.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    return TabPage(
      body: Center(child: Text(AppLocalizations.of(context).comingSoon, style: Theme.of(context).textTheme.bodyLarge)),
    );
  }
}
