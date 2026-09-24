import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// One article. It counts as read once the user scrolls to the end.
class ArticleScreen extends ConsumerStatefulWidget {
  const ArticleScreen({super.key, required this.article});

  final Article article;

  static Future<void> open(BuildContext context, Article article) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ArticleScreen(article: article)));

  @override
  ConsumerState<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends ConsumerState<ArticleScreen> {
  bool _marked = false;

  void _markRead() {
    if (_marked) return;
    _marked = true;
    final alreadyRead = (ref.read(articlesReadProvider).value ?? const []).any((r) => r.articleId == widget.article.id);
    if (alreadyRead) return;
    ref.read(databaseProvider).markArticleRead(widget.article.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).articleReadSnack), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final body = ref.watch(articleBodyProvider(widget.article)).value;
    final articles = ref.watch(contentProvider).value?.articles ?? const [];
    final i = articles.indexOf(widget.article);
    final next = i >= 0 && i + 1 < articles.length ? articles[i + 1] : null;

    return Scaffold(
      appBar: AppBar(title: Text(l.articleCategory(widget.article.category))),
      body: body == null
          ? const Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.extentAfter < 80) _markRead();
                return false;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  MarkdownBody(
                    data: body,
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      h1: theme.textTheme.headlineSmall,
                      h2: theme.textTheme.titleLarge,
                      h2Padding: const EdgeInsets.only(top: 12),
                      p: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      listBullet: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      blockSpacing: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l.articleDisclaimer,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                  if (next != null) ...[
                    const SizedBox(height: 24),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacement(MaterialPageRoute(builder: (_) => ArticleScreen(article: next))),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(l.articleNext),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
