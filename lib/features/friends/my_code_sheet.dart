import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/widgets/toast.dart';
import '../../data/social.dart';
import '../../l10n/app_localizations.dart';

/// "Мой код друга": the code in large letters and a button to copy it (opened from Settings → Друзья).
Future<void> showMyCodeSheet(BuildContext context, String code) => showModalBottomSheet(
  context: context,
  useSafeArea: true,
  showDragHandle: true,
  builder: (context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pretty = formatCode(code);
    void copy() {
      Clipboard.setData(ClipboardData(text: pretty));
      Navigator.pop(context);
      showToast(context, l.socialCodeCopied, icon: Icons.copy);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(l.socialMyCode, style: theme.textTheme.headlineSmall),
          Text(l.socialMyCodeHint, style: theme.textTheme.bodyMedium),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: copy,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                pretty,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          FilledButton.icon(onPressed: copy, icon: const Icon(Icons.copy, size: 18), label: Text(l.socialCopy)),
        ],
      ),
    );
  },
);
