import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlater/app_imports.dart';
import 'package:riverpod/riverpod.dart';

/// ViewModel for the Library feature.
/// Manages the list of saved articles and related actions.
class LibraryViewModel extends AsyncNotifier<List<Article>> {
  @override
  Future<List<Article>> build() async {
    return _fetchArticles();
  }

  Future<List<Article>> _fetchArticles() async {
    final storage = ref.read(storageServiceProvider);
    return storage.getAllArticles();
  }

  /// Reloads the list of articles.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchArticles);
  }

  /// Validates and returns a URL from the clipboard.
  /// Throws an exception if no valid URL is found.
  Future<String> getUrlFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipboardData?.text?.trim();

    if (text == null || text.isEmpty) {
      throw Exception('No URL in clipboard');
    }

    // Basic URL validation
    if (!text.startsWith('http://') && !text.startsWith('https://')) {
      throw Exception('Clipboard does not contain a valid URL');
    }

    return text;
  }

  /// Delete an article by ID.
  /// [url] is required to invalidate the reader cache if the article is open or cached.
  Future<void> deleteArticle(int id, String url) async {
    final storage = ref.read(storageServiceProvider);
    await storage.deleteArticle(id);

    // Invalidate the specific article provider to ensure ReaderScreen updates its state
    ref.invalidate(articleContentProvider(url));

    // Refresh list
    await refresh();
  }

  /// Moves an article to a folder (or removes it if folderId is null)
  Future<void> moveArticleToFolder(int articleId, int? folderId) async {
    final storage = ref.read(storageServiceProvider);
    await storage.moveArticleToFolder(articleId, folderId);
    await refresh();
  }
}

/// Provider for the LibraryViewModel
final libraryViewModelProvider =
    AsyncNotifierProvider<LibraryViewModel, List<Article>>(
      LibraryViewModel.new,
    );
