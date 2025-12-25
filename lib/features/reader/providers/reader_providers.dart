import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlater/app_imports.dart';

/// Represents article content for display (from cache or freshly parsed)
class ArticleContent {
  ArticleContent({
    required this.title,
    required this.content,
    this.imageUrl,
    this.isCached = false,
  });
  final String title;
  final String content;
  final String? imageUrl;
  final bool isCached;
}

/// Provider that checks cache first, then fetches from URL if needed.
/// Uses autoDispose to ensure fresh state when re-entering the screen.
// ignore: specify_nonobvious_property_types
final articleContentProvider = FutureProvider.autoDispose
    .family<ArticleContent, String>((ref, url) async {
      // First, check if article is cached in database
      final storage = ref.read(storageServiceProvider);
      final cachedArticle = await storage.getArticleByUrl(url);

      if (cachedArticle != null && cachedArticle.content != null) {
        // Add to history
        final history = ref.read(historyServiceProvider);
        await history.addToHistory(
          HistoryItem(
            url: url,
            title: cachedArticle.title,
            imageUrl: cachedArticle.imageUrl,
            viewedAt: DateTime.now(),
          ),
        );

        // Return cached content (offline-first)
        return ArticleContent(
          title: cachedArticle.title,
          content: cachedArticle.content!,
          imageUrl: cachedArticle.imageUrl,
          isCached: true,
        );
      }

      // Not cached - fetch from URL
      final parser = ref.read(articleParserServiceProvider);
      final parsed = await parser.parseArticle(url);

      // Add to history
      final history = ref.read(historyServiceProvider);
      await history.addToHistory(
        HistoryItem(
          url: url,
          title: parsed.title,
          imageUrl: parsed.imageUrl,
          viewedAt: DateTime.now(),
        ),
      );

      return ArticleContent(
        title: parsed.title,
        content: parsed.content,
        imageUrl: parsed.imageUrl,
      );
    });
