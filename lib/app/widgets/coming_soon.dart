import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Placeholder body for screens that are not built yet.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(AppLocalizations.of(context).comingSoon)),
    );
  }
}
