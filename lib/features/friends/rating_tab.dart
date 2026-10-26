import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/widgets/cards.dart';
import '../../app/widgets/choice.dart';
import '../../app/widgets/sos_fab.dart';
import '../../data/social.dart';
import '../../l10n/app_localizations.dart';
import '../settings/about_me_screen.dart';
import 'friend_page.dart';
import 'social_widgets.dart';

class _Entry {
  const _Entry({required this.uid, required this.nick, required this.value, this.me = false});

  final String uid;
  final String nick;
  final int value;
  final bool me;
}

/// «Друзья» → «Рейтинг»: friends ranked by the chosen stat (XP by default: it never burns, so a relapse
/// never drops anyone down). Tap someone to open their page (yourself → «Обо мне»).
class RatingTab extends ConsumerStatefulWidget {
  const RatingTab({super.key, required this.me});

  final SocialProfile me;

  @override
  ConsumerState<RatingTab> createState() => _RatingTabState();
}

class _RatingTabState extends ConsumerState<RatingTab> {
  ShareField _metric = ShareField.xp;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final me = widget.me;
    final stats = ref.watch(myStatsProvider);
    final share = ref.watch(shareSettingsProvider);
    final ids = ref.watch(friendIdsProvider).value ?? const [];
    final friends = [for (final id in ids) ?ref.watch(friendProfileProvider(id)).value];

    // Everyone, the user included, takes part only with the stats they chose to show.
    final entries = <_Entry>[
      if (stats != null && share.contains(_metric))
        _Entry(uid: me.uid, nick: me.nick, value: stats.value(_metric), me: true),
      for (final f in friends)
        if (f.value(_metric) case final v?) _Entry(uid: f.uid, nick: f.nick, value: v),
    ]..sort((a, b) => b.value != a.value ? b.value.compareTo(a.value) : a.nick.compareTo(b.nick));
    final meHidden = !share.contains(_metric);
    final hidden = friends.length - entries.where((e) => !e.me).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, sosClearance),
      children: [
        AppSegments<ShareField>(
          options: [
            (ShareField.xp, l.metricXp),
            (ShareField.badges, l.metricBadges),
            (ShareField.days, l.metricDays),
            (ShareField.money, l.metricMoney),
          ],
          selected: _metric,
          onChanged: (m) => setState(() => _metric = m),
        ),
        const SizedBox(height: 20),
        if (entries.isNotEmpty) _Podium(entries: entries.take(3).toList(), metric: _metric, onTap: _open),
        if (entries.length > 3 || hidden > 0 || meHidden) ...[
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (i, e) in entries.indexed.skip(3))
                  _Row(place: i + 1, entry: e, metric: _metric, onTap: _open),
                if (hidden > 0) _HiddenNote(l.socialHidden(hidden)),
                if (meHidden) _HiddenNote(l.socialMeHidden, onTap: () => AboutMeScreen.open(context)),
              ],
            ),
          ),
        ],
        if (friends.isEmpty) ...[
          const SizedBox(height: 16),
          AppCard(
            tone: CardTone.tip,
            child: Text(l.socialNoFriends, style: theme.textTheme.bodyMedium),
          ),
        ],
      ],
    );
  }

  void _open(_Entry e) => e.me ? AboutMeScreen.open(context) : FriendPage.open(context, e.uid);
}

/// Top three on steps: second, first, third.
class _Podium extends StatelessWidget {
  const _Podium({required this.entries, required this.metric, required this.onTap});

  final List<_Entry> entries;
  final ShareField metric;
  final ValueChanged<_Entry> onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const heights = [100.0, 72.0, 52.0];
    final blocks = [scheme.primaryContainer, scheme.secondaryContainer, scheme.surfaceContainerHighest];
    final order = [1, 0, 2].where((i) => i < entries.length);
    // Fixed step width (a third of the list), so one or two people do not stretch across the screen.
    final width = (MediaQuery.sizeOf(context).width - 32 - 20) / 3;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 10,
      children: [
        for (final i in order)
          SizedBox(
            width: width,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(entries[i]),
              child: Column(
                spacing: 6,
                children: [
                  FriendAvatar(nick: entries[i].nick, uid: entries[i].uid, size: 52, ring: entries[i].me),
                  Text(
                    entries[i].me ? l.socialYou : entries[i].nick,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge,
                  ),
                  Text(
                    shareValueText(l, metric, entries[i].value),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(color: scheme.primary, fontFeatures: tabular),
                  ),
                  Container(
                    height: heights[i],
                    width: double.infinity,
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: blocks[i],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14), bottom: Radius.circular(4)),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: theme.textTheme.headlineSmall?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.place, required this.entry, required this.metric, required this.onTap});

  final int place;
  final _Entry entry;
  final ShareField metric;
  final ValueChanged<_Entry> onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Material(
      color: entry.me ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35) : Colors.transparent,
      child: InkWell(
        onTap: () => onTap(entry),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            spacing: 12,
            children: [
              SizedBox(
                width: 24,
                child: Text('$place', textAlign: TextAlign.center, style: theme.textTheme.titleSmall),
              ),
              FriendAvatar(nick: entry.nick, uid: entry.uid, size: 36),
              Expanded(child: Text(entry.me ? l.socialYou : entry.nick, style: theme.textTheme.bodyMedium)),
              Text(
                shareValueText(l, metric, entry.value),
                style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontFeatures: tabular),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A quiet line under the list: who does not show the chosen stat (never a reproach).
class _HiddenNote extends StatelessWidget {
  const _HiddenNote(this.text, {this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          spacing: 10,
          children: [
            Icon(Icons.lock_outline, size: 18, color: theme.colorScheme.onSurfaceVariant),
            Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
            if (onTap != null) Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
