import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlater/app_imports.dart';
import 'package:riverpod/riverpod.dart';

/// ViewModel for the History feature.
/// Manages history items and search state.
class HistoryViewModel extends AsyncNotifier<List<HistoryItem>> {
  @override
  Future<List<HistoryItem>> build() async {
    return _fetchHistory();
  }

  String _searchQuery = '';

  Future<List<HistoryItem>> _fetchHistory() async {
    final historyService = ref.read(historyServiceProvider);
    if (_searchQuery.isEmpty) {
      return historyService.getAllHistory();
    } else {
      return historyService.searchHistory(_searchQuery);
    }
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchHistory);
  }

  Future<void> deleteItem(int id) async {
    final historyService = ref.read(historyServiceProvider);
    await historyService.deleteHistoryItem(id);
    await refresh();
  }

  Future<void> clearAllHistory() async {
    final historyService = ref.read(historyServiceProvider);
    await historyService.clearAllHistory();
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchHistory);
  }

  /// Helper to parse and save to library from history
  Future<void> saveToLibrary(HistoryItem item) async {
    // This logic mimics what was in the UI.
    // Ideally, we move parsing logic to a service if not already there.
    // articleParserServiceProvider is available.
    final parser = ref.read(articleParserServiceProvider);
    final parsed = await parser.parseArticle(item.url);

    final article = Article(
      url: item.url,
      title: parsed.title,
      content: parsed.content,
      imageUrl: parsed.imageUrl,
      savedAt: DateTime.now(),
    );

    final storage = ref.read(storageServiceProvider);
    await storage.saveArticle(article);

    // Refresh library
    ref.invalidate(libraryViewModelProvider);
  }
}

final historyViewModelProvider =
    AsyncNotifierProvider<HistoryViewModel, List<HistoryItem>>(
      HistoryViewModel.new,
    );
