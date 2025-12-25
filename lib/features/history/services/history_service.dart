import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_article_reader/features/history/data/history_dao.dart';
import 'package:offline_article_reader/features/history/models/history_item.dart';

/// Provider for HistoryDao
final historyDaoProvider = Provider<HistoryDao>((ref) {
  return HistoryDao();
});

/// Provider for HistoryService
final historyServiceProvider = Provider<HistoryService>((ref) {
  final historyDao = ref.watch(historyDaoProvider);
  return HistoryService(historyDao);
});

/// Provider for observing history list
final FutureProvider<List<HistoryItem>> historyProvider =
    FutureProvider.autoDispose<List<HistoryItem>>((
      ref,
    ) async {
      final history = ref.watch(historyServiceProvider);
      return history.getAllHistory();
    });

/// Provider for searching history
/// The type 'AutoDisposeFutureProviderFamily' is not exported by riverpod/flutter_riverpod
/// so we cannot explicitly type this variable.
// ignore: specify_nonobvious_property_types
final historySearchProvider = FutureProvider.autoDispose
    .family<List<HistoryItem>, String>((ref, query) async {
      final history = ref.watch(historyServiceProvider);
      if (query.isEmpty) {
        return history.getAllHistory();
      }
      return history.searchHistory(query);
    });

class HistoryService {
  HistoryService(this._historyDao);
  final HistoryDao _historyDao;

  /// Add or update item in history (updates viewedAt if URL exists)
  Future<int> addToHistory(HistoryItem item) async {
    return _historyDao.insertOrUpdate(item);
  }

  /// Get all history items ordered by most recent first
  Future<List<HistoryItem>> getAllHistory() async {
    return _historyDao.getAllHistory();
  }

  /// Search history by title
  Future<List<HistoryItem>> searchHistory(String query) async {
    return _historyDao.searchHistory(query);
  }

  /// Delete a single history item
  Future<int> deleteHistoryItem(int id) async {
    return _historyDao.delete(id);
  }

  /// Delete history item by URL
  Future<int> deleteHistoryByUrl(String url) async {
    return _historyDao.deleteByUrl(url);
  }

  /// Clear all history
  Future<int> clearAllHistory() async {
    return _historyDao.clearAll();
  }

  /// Get history item by URL
  Future<HistoryItem?> getHistoryByUrl(String url) async {
    return _historyDao.getHistoryByUrl(url);
  }
}
