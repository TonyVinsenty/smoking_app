import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/widgets/cards.dart';
import '../../app/widgets/toast.dart';
import '../../data/social.dart';
import '../../l10n/app_localizations.dart';
import 'social_widgets.dart';

Future<void> showAddFriendSheet(BuildContext context) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (context) => const _AddFriendSheet(),
);

class _AddFriendSheet extends ConsumerStatefulWidget {
  const _AddFriendSheet();

  @override
  ConsumerState<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends ConsumerState<_AddFriendSheet> {
  final _controller = TextEditingController();
  FriendLookup? _found;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Looks the code up as soon as all 8 characters are there, to show whose it is before adding.
  Future<void> _onChanged(String text) async {
    final l = AppLocalizations.of(context);
    final code = normalizeCode(text);
    setState(() {
      _found = null;
      _error = null;
    });
    if (code.length != 8) return;
    final me = ref.read(myProfileProvider).value;
    if (code == me?.code) {
      setState(() => _error = l.socialCodeSelf);
      return;
    }
    try {
      final found = await ref.read(socialServiceProvider).lookup(code).timeout(const Duration(seconds: 15));
      if (!mounted || normalizeCode(_controller.text) != code) return;
      setState(() => found == null ? _error = l.socialCodeNotFound : _found = found);
    } catch (_) {
      if (mounted) setState(() => _error = l.socialOffline);
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null) return;
    // A whole shared message may be pasted: take the code out of it.
    final match = RegExp(r'[A-Za-z0-9]{4}-?[A-Za-z0-9]{4}').allMatches(text).lastOrNull;
    _controller.text = formatCode(normalizeCode(match?.group(0) ?? text));
    unawaited(_onChanged(_controller.text));
  }

  Future<void> _add() async {
    final found = _found;
    if (found == null) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    AddFriendError? error;
    try {
      error = await ref.read(socialServiceProvider).addFriend(found.code).timeout(const Duration(seconds: 20));
    } catch (_) {
      error = AddFriendError.network;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (error == null) {
      Navigator.pop(context);
      showToast(context, l.socialFriendAdded(found.nick), icon: Icons.person_add_alt);
    } else {
      setState(
        () => _error = switch (error!) {
          AddFriendError.notFound => l.socialCodeNotFound,
          AddFriendError.self => l.socialCodeSelf,
          AddFriendError.network => l.socialOffline,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final found = _found;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Text(l.socialAddFriendTitle, style: theme.textTheme.headlineSmall),
            Text(l.socialAddFriendText, style: theme.textTheme.bodyMedium),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              enableSuggestions: false,
              inputFormatters: [_CodeFormatter()],
              onChanged: _onChanged,
              style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 2, fontFeatures: tabular),
              decoration: InputDecoration(
                labelText: l.socialCodeLabel,
                hintText: 'K7M4-Q2XP',
                errorText: _error,
                counterText: '',
                border: const OutlineInputBorder(),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: TextButton(onPressed: _paste, child: Text(l.socialPaste)),
                ),
              ),
            ),
            if (found != null)
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  spacing: 12,
                  children: [
                    FriendAvatar(nick: found.nick, size: 44),
                    Expanded(child: Text(found.nick, style: theme.textTheme.titleMedium)),
                    Icon(Icons.check_circle, color: theme.colorScheme.primary),
                  ],
                ),
              ),
            Text(l.socialAddMutual, style: theme.textTheme.bodySmall),
            FilledButton(
              onPressed: found == null || _busy ? null : _add,
              child: _busy
                  ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                  : Text(l.socialAddButton),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps the field as "K7M4-Q2XP" while typing: capitals and digits only, the dash appears with the 5th character.
class _CodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final code = normalizeCode(newValue.text);
    final text = formatCode(code.length > 8 ? code.substring(0, 8) : code, partial: true);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
