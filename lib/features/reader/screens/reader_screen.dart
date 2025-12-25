import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:offline_article_reader/app_imports.dart';

/// Screen for reading an article's content.
class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({required this.url, super.key});
  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleContentProvider(url));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: articleAsync.when(
        data: (article) {
          return CustomScrollView(
            slivers: [
              // Collapsible AppBar with hero image
              SliverAppBar(
                expandedHeight: article.imageUrl != null ? 250 : 0,
                pinned: true,
                stretch: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                foregroundColor: theme.colorScheme.onSurface,
                flexibleSpace: article.imageUrl != null
                    ? FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              article.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  ColoredBox(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 48,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                            ),
                            // Gradient overlay for readability
                            DecoratedBox(
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
                          ],
                        ),
                      )
                    : null,
                actions: [
                  // Only show save button if not already cached
                  if (!article.isCached)
                    IconButton(
                      icon: const Icon(Icons.bookmark_add_outlined),
                      tooltip: 'Save Article',
                      onPressed: () => _saveArticle(context, ref, article),
                    )
                  else
                    // Show saved indicator
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        avatar: Icon(
                          Icons.offline_pin,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        label: const Text('Saved'),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),

              // Article content
              SliverSafeArea(
                top: false,
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.p20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          article.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: AppSizes.p16),

                        // Divider
                        Divider(color: theme.colorScheme.outline),

                        const SizedBox(height: AppSizes.p16),

                        // Article body
                        HtmlWidget(
                          article.content,
                          textStyle: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.8,
                            fontSize: 17,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          customStylesBuilder: (element) {
                            final textColor = isDark ? '#F9FAFB' : '#111827';
                            final linkColor = isDark ? '#818CF8' : '#6366F1';

                            // Force consistent colors on all container elements
                            if (element.localName == 'div' ||
                                element.localName == 'section' ||
                                element.localName == 'article' ||
                                element.localName == 'span' ||
                                element.localName == 'figure' ||
                                element.localName == 'figcaption') {
                              return {
                                'background-color': 'transparent',
                                'color': textColor,
                              };
                            }

                            // Style paragraphs
                            if (element.localName == 'p') {
                              return {
                                'margin-bottom': '16px',
                                'color': textColor,
                                'background-color': 'transparent',
                              };
                            }

                            // Style links
                            if (element.localName == 'a') {
                              return {
                                'color': linkColor,
                                'text-decoration': 'none',
                              };
                            }

                            // Style images
                            if (element.localName == 'img') {
                              return {
                                'border-radius': '12px',
                                'margin': '16px 0',
                              };
                            }

                            // Style headings
                            if (element.localName == 'h1' ||
                                element.localName == 'h2' ||
                                element.localName == 'h3' ||
                                element.localName == 'h4' ||
                                element.localName == 'h5' ||
                                element.localName == 'h6') {
                              return {
                                'font-weight': 'bold',
                                'margin-top': '24px',
                                'margin-bottom': '12px',
                                'color': textColor,
                              };
                            }

                            // Style blockquotes
                            if (element.localName == 'blockquote') {
                              return {
                                'border-left': '4px solid $linkColor',
                                'padding-left': '16px',
                                'margin': '16px 0',
                                'font-style': 'italic',
                                'color': textColor,
                              };
                            }

                            // Style lists
                            if (element.localName == 'ul' ||
                                element.localName == 'ol' ||
                                element.localName == 'li') {
                              return {
                                'color': textColor,
                              };
                            }

                            // Style strong/bold
                            if (element.localName == 'strong' ||
                                element.localName == 'b') {
                              return {
                                'font-weight': 'bold',
                                'color': textColor,
                              };
                            }

                            // Style italic
                            if (element.localName == 'em' ||
                                element.localName == 'i') {
                              return {
                                'font-style': 'italic',
                                'color': textColor,
                              };
                            }

                            return null;
                          },
                          onTapUrl: (tappedUrl) async {
                            return true;
                          },
                        ),

                        // Bottom padding for comfortable scrolling
                        const SizedBox(height: AppSizes.p48),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSizes.p16),
              Text(
                'Loading article...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: AppSizes.p16),
                Text(
                  'Failed to load article',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.p24),
                FilledButton.icon(
                  onPressed: () {
                    // Refresh the provider
                    ref.invalidate(articleContentProvider(url));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveArticle(
    BuildContext context,
    WidgetRef ref,
    ArticleContent article,
  ) async {
    final theme = Theme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(readerViewModelProvider.notifier)
          .saveArticle(
            url: url,
            title: article.title,
            content: article.content,
            imageUrl: article.imageUrl,
          );

      // We should probably check for errors in the state,
      // but if saveArticle throws, we catch it here.
      // Or we can watch the state for error/loading.
      // For now, simpler await approach as requested.

      if (scaffoldMessenger.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: AppSizes.p12),
                Text('Article saved to library'),
              ],
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (scaffoldMessenger.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }
}
