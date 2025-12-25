import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:offline_article_reader/app_imports.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(savedArticlesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              final _ = ref.refresh(savedArticlesProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settingsPath),
          ),
        ],
      ),
      body: articlesAsync.when(
        data: (articles) {
          if (articles.isEmpty) {
            return _EmptyLibraryView(
              onAddArticle: () => context.push(AppRoutes.addArticlePath),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: articles.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSizes.p12),
            itemBuilder: (context, index) {
              final article = articles[index];
              return _ArticleCard(article: article);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppSizes.p16),
              Text(
                'Failed to load articles',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.p8),
              Text(
                err.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(AppRoutes.addArticlePath);
          final _ = ref.refresh(savedArticlesProvider);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Article'),
      ),
    );
  }
}

class _EmptyLibraryView extends StatelessWidget {
  const _EmptyLibraryView({required this.onAddArticle});
  final VoidCallback onAddArticle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSizes.p24),
            Text(
              'Your library is empty',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              'Save articles from the web to read them\noffline anytime, anywhere.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p24),
            FilledButton.icon(
              onPressed: onAddArticle,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add your first article'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends ConsumerWidget {
  const _ArticleCard({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateStr = DateFormat.yMMMd().format(article.savedAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await context.pushNamed(
            AppRoutes.readerName,
            queryParameters: {'url': article.url},
          );
          // Refresh library when returning from reader
          final _ = ref.refresh(savedArticlesProvider);
        },
        onLongPress: () => _showDeleteDialog(context, ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image with gradient overlay
            if (article.imageUrl != null)
              Stack(
                children: [
                  Image.network(
                    article.imageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  // Gradient for text readability
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 80,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Title on image
                  Positioned(
                    left: AppSizes.p16,
                    right: AppSizes.p16,
                    bottom: AppSizes.p12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              // No image - show text content
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.delete_outline_rounded,
          color: theme.colorScheme.error,
          size: 32,
        ),
        title: const Text(AppStrings.deleteArticle),
        content: Text(
          'Are you sure you want to delete "${article.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(storageServiceProvider).deleteArticle(article.id!);
              final _ = ref.refresh(savedArticlesProvider);
              if (context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
