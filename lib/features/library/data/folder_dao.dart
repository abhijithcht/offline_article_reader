import 'package:offline_article_reader/core/database/database_helper.dart';
import 'package:offline_article_reader/core/database/tables.dart';
import 'package:offline_article_reader/features/library/models/folder.dart';
import 'package:sqflite/sqflite.dart';

class FolderDao {
  FolderDao({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();
  final DatabaseHelper _dbHelper;

  Future<Database> get _db => _dbHelper.database;

  Future<int> insert(Folder folder) async {
    final db = await _db;
    final data = folder.toMap()..remove('id');
    return db.insert(DatabaseConstants.tableFolders, data);
  }

  Future<int> update(Folder folder) async {
    final db = await _db;
    return db.update(
      DatabaseConstants.tableFolders,
      folder.toMap(),
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [folder.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    // Transaction to delete folder and unlink articles
    return db.transaction((txn) async {
      // Unlink articles (move to root)
      await txn.update(
        DatabaseConstants.tableArticles,
        {DatabaseConstants.colFolderId: null},
        where: '${DatabaseConstants.colFolderId} = ?',
        whereArgs: [id],
      );

      // Delete folder name
      return txn.delete(
        DatabaseConstants.tableFolders,
        where: '${DatabaseConstants.colId} = ?',
        whereArgs: [id],
      );
    });
  }

  Future<List<Folder>> getAllFolders() async {
    final db = await _db;
    final maps = await db.query(
      DatabaseConstants.tableFolders,
      orderBy: '${DatabaseConstants.colFolderCreatedAt} DESC',
    );
    return maps.map(Folder.fromMap).toList();
  }

  Future<Folder?> getFolder(int id) async {
    final db = await _db;
    final maps = await db.query(
      DatabaseConstants.tableFolders,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Folder.fromMap(maps.first);
    }
    return null;
  }
}
