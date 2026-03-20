import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:readlater/features/history/models/history_item.dart';
import 'package:riverpod/misc.dart';
import 'package:sqflite/sqflite.dart';

/// Provider for HistoryService
final historyServiceProvider = Provider<HistoryService>((ref) {
  return HistoryService();
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
final FutureProviderFamily<List<HistoryItem>, String> historySearchProvider =
    FutureProvider.autoDispose.family<List<HistoryItem>, String>((
      ref,
      query,
    ) async {
      final history = ref.watch(historyServiceProvider);
      if (query.isEmpty) {
        return history.getAllHistory();
      }
      return history.searchHistory(query);
    });

class HistoryService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'history.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT NOT NULL UNIQUE,
            title TEXT NOT NULL,
            imageUrl TEXT,
            viewedAt INTEGER NOT NULL
          )
        ''');
        // Index for faster search
        await db.execute('''
          CREATE INDEX idx_history_title ON history(title)
        ''');
        await db.execute('''
          CREATE INDEX idx_history_viewedAt ON history(viewedAt DESC)
        ''');
      },
    );
  }

  /// Add or update item in history (updates viewedAt if URL exists)
  Future<int> addToHistory(HistoryItem item) async {
    final db = await database;

    // Check if URL already exists
    final existing = await db.query(
      'history',
      where: 'url = ?',
      whereArgs: [item.url],
    );

    if (existing.isNotEmpty) {
      // Update existing entry with new viewedAt time
      return db.update(
        'history',
        {
          'viewedAt': DateTime.now().millisecondsSinceEpoch,
          'title': item.title,
          'imageUrl': item.imageUrl,
        },
        where: 'url = ?',
        whereArgs: [item.url],
      );
    } else {
      // Insert new entry
      final data = item.toMap()..remove('id');
      return db.insert('history', data);
    }
  }

  /// Get all history items ordered by most recent first
  Future<List<HistoryItem>> getAllHistory() async {
    final db = await database;
    final maps = await db.query(
      'history',
      orderBy: 'viewedAt DESC',
    );
    return maps.map<HistoryItem>(HistoryItem.fromMap).toList();
  }

  /// Search history by title
  Future<List<HistoryItem>> searchHistory(String query) async {
    final db = await database;
    final maps = await db.query(
      'history',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'viewedAt DESC',
    );
    return maps.map<HistoryItem>(HistoryItem.fromMap).toList();
  }

  /// Delete a single history item
  Future<int> deleteHistoryItem(int id) async {
    final db = await database;
    return db.delete(
      'history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete history item by URL
  Future<int> deleteHistoryByUrl(String url) async {
    final db = await database;
    return db.delete(
      'history',
      where: 'url = ?',
      whereArgs: [url],
    );
  }

  /// Clear all history
  Future<int> clearAllHistory() async {
    final db = await database;
    return db.delete('history');
  }

  /// Get history item by URL
  Future<HistoryItem?> getHistoryByUrl(String url) async {
    final db = await database;
    final maps = await db.query(
      'history',
      where: 'url = ?',
      whereArgs: [url],
    );
    if (maps.isNotEmpty) {
      return HistoryItem.fromMap(maps.first);
    }
    return null;
  }
}
