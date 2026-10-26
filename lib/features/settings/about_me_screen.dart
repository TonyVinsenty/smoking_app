import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/widgets/cards.dart';
import '../../app/widgets/toast.dart';
import '../../data/social.dart';
import '../../l10n/app_localizations.dart';
import '../friends/social_widgets.dart';

/// Settings → «Обо мне»: the user's own page — photo, name, what friends see (with a live preview),
/// account deletion.
class AboutMeScreen extends ConsumerStatefulWidget {
  const AboutMeScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutMeScreen()));

  @override
  ConsumerState<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends ConsumerState<AboutMeScreen> {
  bool _photoBusy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final me = ref.watch(myProfileProvider).value;
    final share = ref.watch(shareSettingsProvider);
    final fields = [
      (ShareField.xp, l.shareXp, l.shareXpHint),
      (ShareField.badges, l.shareBadges, l.shareBadgesHint),
      (ShareField.days, l.shareDays, l.shareDaysHint),
      (ShareField.money, l.shareMoney, l.shareMoneyHint),
    ];
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final label = theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Scaffold(
      appBar: AppBar(title: Text(l.aboutMeTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (me != null) ...[
            Center(child: _photo(me)),
            const SizedBox(height: 12),
            Text(me.nick, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
            Center(
              child: TextButton.icon(
                onPressed: () => _changeNick(me.nick),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(l.privacyChangeNick),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(l.privacyPreview, style: label),
          const SizedBox(height: 8),
          MyPreviewCard(nick: me?.nick ?? '—'),
          const SizedBox(height: 20),
          Text(l.aboutMeShareTitle, style: label),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (final (f, title, hint) in fields)
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: share.contains(f),
                    onChanged: (_) => ref.read(shareSettingsProvider.notifier).toggle(f),
                    title: Text(title),
                    subtitle: Text(hint),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(me == null ? l.privacyNotJoined : l.privacyServerNote, style: muted),
          ),
          if (me != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(l.privacyDeleteTitle, style: theme.textTheme.titleMedium),
                  Text(l.privacyDeleteText, style: muted),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                    onPressed: _delete,
                    child: Text(l.privacyDeleteButton),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// The big round photo with a camera badge; tap to choose or remove it.
  Widget _photo(SocialProfile me) {
    final scheme = Theme.of(context).colorScheme;
    final hasPhoto = ref.watch(avatarProvider(me.uid)).value != null;
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).aboutMePhoto,
      child: GestureDetector(
        onTap: _photoBusy ? null : () => _photoMenu(hasPhoto),
        child: Stack(
          alignment: Alignment.center,
          children: [
            FriendAvatar(nick: me.nick, uid: me.uid, size: 112),
            if (_photoBusy) const SizedBox.square(dimension: 40, child: CircularProgressIndicator()),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.surface, width: 3),
                ),
                child: Icon(Icons.photo_camera_outlined, size: 18, color: scheme.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _photoMenu(bool hasPhoto) async {
    final l = AppLocalizations.of(context);
    final remove = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.aboutMePhotoPick),
              onTap: () => Navigator.pop(context, false),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l.aboutMePhotoRemove),
                onTap: () => Navigator.pop(context, true),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (remove == null) return;
    await (remove ? _savePhoto(() => ref.read(socialServiceProvider).removeAvatar()) : _pickPhoto());
  }

  /// Gallery → round crop → a 256×256 JPEG (≈15–30 KB) → server.
  Future<void> _pickPhoto() async {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
    if (picked == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      maxWidth: 256,
      maxHeight: 256,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: l.aboutMePhotoCrop,
          toolbarColor: scheme.surface,
          statusBarLight: !dark,
          navBarLight: !dark,
          toolbarWidgetColor: scheme.onSurface,
          activeControlsWidgetColor: scheme.primary,
          backgroundColor: Colors.black,
          cropStyle: CropStyle.circle,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: l.aboutMePhotoCrop,
          doneButtonTitle: l.aboutMePhotoDone,
          cancelButtonTitle: l.cancel,
          cropStyle: CropStyle.circle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );
    if (cropped == null) return;
    final bytes = await cropped.readAsBytes();
    if (bytes.length > maxAvatarBytes) {
      if (mounted) showToast(context, l.aboutMePhotoFailed, icon: Icons.error_outline);
      return;
    }
    await _savePhoto(() => ref.read(socialServiceProvider).setAvatar(bytes));
  }

  Future<void> _savePhoto(Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    setState(() => _photoBusy = true);
    try {
      await action().timeout(const Duration(seconds: 30));
    } catch (_) {
      if (mounted) showToast(context, l.socialOffline, icon: Icons.cloud_off);
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  Future<void> _changeNick(String current) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        final l = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(l.socialNickChangeTitle)),
          body: NameEditor(
            initial: current,
            buttonText: (_) => l.save,
            onSubmit: (nick) async {
              await ref.read(socialServiceProvider).changeNick(nick);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        );
      },
    ),
  );

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.privacyDeleteConfirm),
        content: Text(l.privacyDeleteText),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.privacyDeleteButton),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(socialServiceProvider).deleteAccount().timeout(const Duration(seconds: 30));
      if (mounted) showToast(context, l.privacyDeleted);
    } catch (_) {
      if (mounted) showToast(context, l.socialOffline, icon: Icons.cloud_off);
    }
  }
}
