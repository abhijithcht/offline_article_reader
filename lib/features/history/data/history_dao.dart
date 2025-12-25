import 'package:readlater/core/database/database_helper.dart';
import 'package:readlater/core/database/tables.dart';
import 'package:readlater/features/history/models/history_item.dart';
import 'package:sqflite/sqflite.dart';

class HistoryDao {
  HistoryDao({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();
  final DatabaseHelper _dbHelper;

  Future<Database> get _db => _dbHelper.database;

  Future<int> insertOrUpdate(HistoryItem item) async {
    final db = await _db;

    final existing = await db.query(
      DatabaseConstants.tableHistory,
      where: '${DatabaseConstants.colUrl} = ?',
      whereArgs: [item.url],
    );

    if (existing.isNotEmpty) {
      return db.update(
        DatabaseConstants.tableHistory,
        {
          DatabaseConstants.colViewedAt: DateTime.now().millisecondsSinceEpoch,
          DatabaseConstants.colTitle: item.title,
          DatabaseConstants.colImageUrl: item.imageUrl,
        },
        where: '${DatabaseConstants.colUrl} = ?',
        whereArgs: [item.url],
      );
    } else {
      final data = item.toMap()..remove('id');
      return db.insert(DatabaseConstants.tableHistory, data);
    }
  }

  Future<List<HistoryItem>> getAllHistory() async {
    final db = await _db;
    final maps = await db.query(
      DatabaseConstants.tableHistory,
      orderBy: '${DatabaseConstants.colViewedAt} DESC',
    );
    return maps.map(HistoryItem.fromMap).toList();
  }

  Future<List<HistoryItem>> searchHistory(String query) async {
    final db = await _db;
    final maps = await db.query(
      DatabaseConstants.tableHistory,
      where: '${DatabaseConstants.colTitle} LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: '${DatabaseConstants.colViewedAt} DESC',
    );
    return maps.map(HistoryItem.fromMap).toList();
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete(
      DatabaseConstants.tableHistory,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteByUrl(String url) async {
    final db = await _db;
    return db.delete(
      DatabaseConstants.tableHistory,
      where: '${DatabaseConstants.colUrl} = ?',
      whereArgs: [url],
    );
  }

  Future<int> clearAll() async {
    final db = await _db;
    return db.delete(DatabaseConstants.tableHistory);
  }

  Future<HistoryItem?> getHistoryByUrl(String url) async {
    final db = await _db;
    final maps = await db.query(
      DatabaseConstants.tableHistory,
      where: '${DatabaseConstants.colUrl} = ?',
      whereArgs: [url],
    );
    if (maps.isNotEmpty) {
      return HistoryItem.fromMap(maps.first);
    }
    return null;
  }
}
