import 'package:flutter/material.dart';

import '../../app/widgets/sos_fab.dart';

import '../../l10n/app_localizations.dart';

/// Room below the last card so it can scroll clear of the SOS button.
const healthTabPadding = EdgeInsets.fromLTRB(16, 16, 16, sosClearance);

class HealthDisclaimer extends StatelessWidget {
  const HealthDisclaimer({super.key, this.text});

  /// Defaults to the general medical disclaimer.
  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Icon(Icons.info_outline, size: 18, color: theme.colorScheme.onSurfaceVariant),
        Expanded(
          child: Text(
            text ?? AppLocalizations.of(context).healthDisclaimer,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
