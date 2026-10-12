import 'package:flutter/material.dart';

/// Short message at the bottom, styled by the theme's snackBarTheme; closes on tap.
void showToast(BuildContext context, String text, {IconData icon = Icons.check_circle_outline}) =>
    showToastWith(ScaffoldMessenger.of(context), Theme.of(context), text, icon: icon);

/// Same as [showToast], for callers that captured the messenger before an async gap.
void showToastWith(
  ScaffoldMessengerState messenger,
  ThemeData theme,
  String text, {
  IconData icon = Icons.check_circle_outline,
}) {
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: messenger.hideCurrentSnackBar,
        child: Row(
          spacing: 12,
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.primary),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    ),
  );
}
