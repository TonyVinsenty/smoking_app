import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// iOS-style wheel time picker (like the iPhone alarm) on both platforms.
/// Returns null when [cancelText] is tapped or the sheet is dismissed.
Future<TimeOfDay?> showWheelTimePicker(
  BuildContext context, {
  required TimeOfDay initialTime,
  String? title,
  String? cancelText,
}) {
  final l = AppLocalizations.of(context);
  var selected = initialTime;
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            SizedBox(
              height: 216,
              // The wheel has fixed row heights, so very large system fonts would clip the digits.
              child: MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.3,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime(2000, 1, 1, initialTime.hour, initialTime.minute),
                  onDateTimeChanged: (d) => selected = TimeOfDay.fromDateTime(d),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(cancelText ?? l.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(selected),
                    child: Text(l.done),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
