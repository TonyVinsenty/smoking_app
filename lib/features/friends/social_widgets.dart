import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../app/widgets/cards.dart';
import '../../app/widgets/toast.dart';
import '../../content/content.dart';
import '../../data/social.dart';
import '../../l10n/app_localizations.dart';

final _fmt = NumberFormat('#,##0', 'ru');

/// "Тихий Кедр" → "ТК", "Костя" → "К" (whole characters, so an emoji is not cut in half).
String initials(String nick) => nick
    .split(' ')
    .where((w) => w.isNotEmpty)
    .take(2)
    .map((w) => String.fromCharCode(w.runes.first).toUpperCase())
    .join();

/// A round avatar: the person's photo when there is one ([uid] given), otherwise the initials on a colour
/// that comes from the name, so it is the same on every phone.
class FriendAvatar extends ConsumerWidget {
  const FriendAvatar({super.key, required this.nick, this.uid, this.size = 40, this.ring = false});

  final String nick;
  final String? uid;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final photo = uid == null ? null : ref.watch(avatarProvider(uid!)).value;
    final colors = [
      (scheme.primaryContainer, scheme.onPrimaryContainer),
      (AppColors.of(context).rewardContainer, AppColors.of(context).onRewardContainer),
      (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      (scheme.secondaryContainer, scheme.onSecondaryContainer),
    ];
    final (bg, fg) = colors[nick.codeUnits.fold(0, (a, b) => a + b) % colors.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: ring ? Border.all(color: scheme.primary, width: 3) : null,
      ),
      child: photo != null
          ? Image.memory(photo, width: size, height: size, fit: BoxFit.cover, gaplessPlayback: true)
          : Text(
              initials(nick),
              textScaler: TextScaler.noScaling,
              style: TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w700, color: fg, fontSize: size * 0.34),
            ),
    );
  }
}

/// A shared stat as a small pill: "Ур. 14 · 1 240 XP", "23 значка", "21 дн. без курения", "6 800 ₽ сэкономлено".
String shareChipText(AppLocalizations l, AppContent content, ShareField f, int v) => switch (f) {
  ShareField.xp => l.chipLevel(content.levelFor(v).$1.level, _fmt.format(v)),
  ShareField.badges => l.chipBadges(v),
  ShareField.days => l.chipDays(v),
  ShareField.money => l.chipMoney(l.money(_fmt.format(v))),
};

/// Short value for the leaderboard: "1 240 XP", "23 зн.", "21 дн.", "6 800 ₽".
String shareValueText(AppLocalizations l, ShareField f, int v) => switch (f) {
  ShareField.xp => l.valueXp(_fmt.format(v)),
  ShareField.badges => l.valueBadges(v),
  ShareField.days => l.valueDays(v),
  ShareField.money => l.money(_fmt.format(v)),
};

/// "1 240" — a number with thin groups, as everywhere in the app.
String formatNumber(int v) => _fmt.format(v);

class StatPill extends StatelessWidget {
  const StatPill(this.text, {super.key, this.reward = false});

  final String text;
  final bool reward;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: reward ? c.rewardContainer : theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: reward ? c.onRewardContainer : theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// The shared stats as pills, or "Только имя" when nothing is shared.
class StatPills extends ConsumerWidget {
  const StatPills({super.key, required this.values});

  final Map<ShareField, int> values;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final content = ref.watch(contentProvider).value;
    if (content == null || values.isEmpty) return Text(l.privacyOnlyNick, style: Theme.of(context).textTheme.bodySmall);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final f in ShareField.values)
          if (values[f] case final v?) StatPill(shareChipText(l, content, f, v), reward: f == ShareField.money),
      ],
    );
  }
}

/// "Так вас видят друзья": the user's own card with only the stats they share.
class MyPreviewCard extends ConsumerWidget {
  const MyPreviewCard({super.key, required this.nick});

  final String nick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(myStatsProvider);
    final share = ref.watch(shareSettingsProvider);
    final uid = ref.watch(myProfileProvider).value?.uid;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 14,
        children: [
          FriendAvatar(nick: nick, uid: uid, size: 48),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(nick, style: Theme.of(context).textTheme.titleMedium),
                StatPills(
                  values: {
                    if (stats != null)
                      for (final f in ShareField.values)
                        if (share.contains(f)) f: stats.value(f),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The name friends see: whatever the user types (a real name is fine — it is a circle of friends).
class NameEditor extends StatefulWidget {
  const NameEditor({super.key, required this.buttonText, required this.onSubmit, this.initial, this.header});

  final String Function(String nick) buttonText;
  final Future<void> Function(String nick) onSubmit;
  final String? initial;
  final Widget? header;

  @override
  State<NameEditor> createState() => _NameEditorState();
}

class _NameEditorState extends State<NameEditor> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initial ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final nick = cleanNick(_controller.text);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        ?widget.header,
        Text(l.socialJoinTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(l.socialJoinText, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          maxLength: maxNickLength,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(labelText: l.socialNameLabel, border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        Text(l.privacyPreview, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        MyPreviewCard(nick: nick.isEmpty ? '—' : nick),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _busy || nick.isEmpty ? null : () => _submit(nick),
          child: _busy
              ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
              : Text(nick.isEmpty ? l.socialNameEmpty : widget.buttonText(nick), textAlign: TextAlign.center),
        ),
      ],
    );
  }

  Future<void> _submit(String nick) async {
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await widget.onSubmit(nick).timeout(const Duration(seconds: 20));
    } catch (_) {
      if (mounted) showToast(context, AppLocalizations.of(context).socialOffline, icon: Icons.cloud_off);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// Ring colours of [LevelBadge], as on Steam: a new colour every 5 levels (1–4 grey, 5–9 red … 45–49 gold).
const levelRingColors = [
  Color(0xFF9AA0A6),
  Color(0xFFD64545),
  Color(0xFFE8833A),
  Color(0xFFE2B634),
  Color(0xFF4CAF50),
  Color(0xFF26A69A),
  Color(0xFF3D8BE8),
  Color(0xFF8E5BD9),
  Color(0xFFD9579A),
  Color(0xFFD4A62A),
];

/// The top level (50) gets a rainbow ring.
const _legendColors = [
  Color(0xFFD64545),
  Color(0xFFE2B634),
  Color(0xFF4CAF50),
  Color(0xFF3D8BE8),
  Color(0xFF8E5BD9),
  Color(0xFFD64545),
];

/// The level in a coloured ring, as on Steam: the colour changes every 5 levels, higher rings are
/// thicker and from level 35 softly glow.
class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level, this.size = 40});

  final int level;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = level ~/ 5;
    final legend = tier >= levelRingColors.length;
    final color = levelRingColors[tier.clamp(0, levelRingColors.length - 1)];
    final width = size * (tier < 4 ? 0.065 : 0.085);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tier == 0 ? null : color.withAlpha(0x22),
        boxShadow: tier >= 7 ? [BoxShadow(color: color.withAlpha(0x66), blurRadius: size * 0.25)] : null,
      ),
      child: CustomPaint(
        size: Size.square(size),
        painter: _RingPainter(colors: legend ? _legendColors : [color, color], width: width),
        child: Center(
          child: Text(
            '$level',
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              fontFamily: displayFont,
              fontWeight: FontWeight.w700,
              fontSize: size * 0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.colors, required this.width});

  final List<Color> colors;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = SweepGradient(colors: colors).createShader(rect);
    canvas.drawCircle(rect.center, (size.shortestSide - width) / 2, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.width != width || old.colors.length != colors.length || old.colors[0] != colors[0];
}
