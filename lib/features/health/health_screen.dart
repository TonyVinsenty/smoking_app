import 'package:flutter/material.dart';

import '../../app/widgets/coming_soon.dart';
import '../../l10n/app_localizations.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) => ComingSoon(title: AppLocalizations.of(context).tabHealth);
}
