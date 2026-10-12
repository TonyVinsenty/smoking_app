import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/motion.dart';
import '../../app/widgets/sos_fab.dart';
import '../../app/widgets/cards.dart';
import '../../content/content.dart';
import '../../data/providers.dart';
import '../../data/settings.dart';
import '../../app/widgets/tab_page.dart';
import '../../l10n/app_localizations.dart';
import 'article_screen.dart';

/// Article list: reading progress, category filter, read marks.
class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  ConsumerState<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> {
  String? _category; // null = all

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final articles = ref.watch(contentProvider).value?.articles;
    final expanded = ref.watch(expandedSectionsProvider('knowledge'));
    final read = {for (final r in ref.watch(articlesReadProvider).value ?? const []) r.articleId};
    if (articles == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final categories = {for (final a in articles) a.category}.toList();
    final shown = [
      for (final a in articles)
        if (_category == null || a.category == _category) a,
    ];
    final readCount = articles.where((a) => read.contains(a.id)).length;

    return TabPage(
      body: ListView(
        // Room below the last card so it can scroll clear of the SOS button.
        padding: const EdgeInsets.fromLTRB(16, 16, 16, sosClearance),
        children: [
          AppCard(
            tone: CardTone.hero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book_outlined, color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(width: 12),
                    CountUp(
                      value: readCount.toDouble(),
                      builder: (context, v) =>
                          Text(l.knowledgeProgress(v.round(), articles.length), style: theme.textTheme.titleMedium),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GrowBar(value: articles.isEmpty ? 0 : readCount / articles.length, minHeight: 8),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: Text(l.knowledgeAll),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final c in categories)
                ChoiceChip(
                  label: Text(l.articleCategory(c)),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = _category == c ? null : c),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_category == null)
            // «Все»: one section per topic, in the order topics first appear.
            for (final c in categories) ...[
              _GroupHeader(
                category: c,
                read: articles.where((a) => a.category == c && read.contains(a.id)).length,
                total: articles.where((a) => a.category == c).length,
                open: expanded.contains(c),
                onTap: () => ref.read(expandedSectionsProvider('knowledge').notifier).toggle(c),
              ),
              for (final a in articles)
                if (a.category == c && expanded.contains(c)) _ArticleCard(article: a, isRead: read.contains(a.id)),
            ]
          else
            for (final a in shown) _ArticleCard(article: a, isRead: read.contains(a.id)),
        ],
      ),
    );
  }
}

IconData _categoryIcon(String category) => switch (category) {
  'addiction' => Icons.psychology_outlined,
  'health' => Icons.favorite_outline,
  'practice' => Icons.directions_walk,
  'myths' => Icons.help_outline,
  'vape' => Icons.cloud_outlined,
  'money' => Icons.savings_outlined,
  'therapy' => Icons.medical_services_outlined,
  _ => Icons.article_outlined,
};

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.category,
    required this.read,
    required this.total,
    required this.open,
    required this.onTap,
  });

  final String category;
  final int read;
  final int total;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: Row(
            children: [
              Icon(_categoryIcon(category), color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(l.articleCategory(category), style: theme.textTheme.titleMedium)),
              Text(
                l.knowledgeGroupRead(read, total),
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.expand_more, color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article, required this.isRead});

  final Article article;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.labelMedium?.copyWith(color: scheme.outline);
    return AppCard(
      margin: const EdgeInsets.symmetric(vertical: 6),
      onTap: () => ArticleScreen.open(context, article),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isRead ? scheme.primary : scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isRead ? Icons.check : _categoryIcon(article.category),
              color: isRead ? scheme.onPrimary : scheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(article.summary, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 16, color: scheme.outline),
                        const SizedBox(width: 4),
                        Text(l.articleMinutes(article.readMinutes), style: muted),
                      ],
                    ),
                    if (isRead)
                      Text(l.articleRead, style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
