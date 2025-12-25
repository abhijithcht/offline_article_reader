import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:offline_article_reader/app_imports.dart';

// Explicit type removed to avoid internal import errors. Inference handled by usage casts.
final FutureProviderFamily<ParsedArticle, String> articleFutureProvider =
    FutureProvider.family<ParsedArticle, String>((ref, url) async {
      final parser = ref.read(articleParserServiceProvider);
      return parser.parseArticle(url);
    });

class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({required this.url, super.key});
  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Explicitly casting the watch result to fix dynamic inference
    final articleAsync = ref.watch(articleFutureProvider(url));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reader'),
        actions: [
          // Only show save button if article is loaded
          if (articleAsync.value != null)
            IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: () async {
                // Cast value to ParsedArticle
                final article = articleAsync.value!;

                final articleToSave = Article(
                  url: url,
                  title: article.title,
                  content: article.content,
                  imageUrl: article.imageUrl,
                  savedAt: DateTime.now(),
                );

                final storage = ref.read(storageServiceProvider);
                await storage.saveArticle(articleToSave);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Article saved!')),
                  );
                }
              },
            ),
        ],
      ),
      body: articleAsync.when(
        data: (Object? data) {
          // Accept generalized type and cast
          if (data is! ParsedArticle) return const SizedBox.shrink();
          final article = data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                    child: Image.network(
                      article.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(height: AppSizes.p16),
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                const Divider(),
                const SizedBox(height: AppSizes.p16),
                HtmlWidget(
                  article.content,
                  textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    fontSize: AppSizes.fontBody,
                  ),
                  onTapUrl: (url) async {
                    return true;
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            Center(child: Text('Error: $error')),
      ),
    );
  }
}
