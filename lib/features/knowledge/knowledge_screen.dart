import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content.dart';
import '../../data/providers.dart';
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
    final read = {for (final r in ref.watch(articlesReadProvider).value ?? const []) r.articleId};
    if (articles == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final categories = {for (final a in articles) a.category}.toList();
    final shown = [for (final a in articles) if (_category == null || a.category == _category) a];
    final readCount = articles.where((a) => read.contains(a.id)).length;

    return Scaffold(
      appBar: AppBar(title: Text(l.tabKnowledge)),
      body: ListView(
        // Room below the last card so it can scroll clear of the SOS button.
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book, color: theme.colorScheme.onPrimaryContainer),
                      const SizedBox(width: 12),
                      Text(l.knowledgeProgress(readCount, articles.length), style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: articles.isEmpty ? 0 : readCount / articles.length,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
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
          for (final a in shown) _ArticleCard(article: a, isRead: read.contains(a.id)),
        ],
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
    final muted = theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ArticleScreen.open(context, article),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(article.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(article.summary, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('${l.articleCategory(article.category)} · ${l.articleMinutes(article.readMinutes)}', style: muted),
                  const Spacer(),
                  if (isRead) ...[
                    Icon(Icons.check_circle, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(l.articleRead, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
