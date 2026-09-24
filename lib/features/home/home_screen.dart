import 'package:flutter/material.dart';

import '../../app/widgets/coming_soon.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => ComingSoon(title: AppLocalizations.of(context).tabHome);
}
