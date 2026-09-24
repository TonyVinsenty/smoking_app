import 'package:flutter/material.dart';

import '../../app/widgets/coming_soon.dart';
import '../../l10n/app_localizations.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) => ComingSoon(title: AppLocalizations.of(context).tabLeaderboard);
}
