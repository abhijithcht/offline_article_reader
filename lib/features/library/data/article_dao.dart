import 'package:readlater/core/database/database_helper.dart';
import 'package:readlater/core/database/tables.dart';
import 'package:readlater/features/library/models/article.dart';
import 'package:sqflite/sqflite.dart';

class ArticleDao {
  ArticleDao({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();
  final DatabaseHelper _dbHelper;

  Future<Database> get _db => _dbHelper.database;

  Future<int> insert(Article article) async {
    final db = await _db;
    final data = article.toMap()..remove('id');

    final existing = await db.query(
      DatabaseConstants.tableArticles,
      where: '${DatabaseConstants.colUrl} = ?',
      whereArgs: [article.url],
    );

    if (existing.isNotEmpty) {
      return db.update(
        DatabaseConstants.tableArticles,
        data,
        where: '${DatabaseConstants.colUrl} = ?',
        whereArgs: [article.url],
      );
    } else {
      return db.insert(DatabaseConstants.tableArticles, data);
    }
  }

  Future<int> update(Article article) async {
    final db = await _db;
    return db.update(
      DatabaseConstants.tableArticles,
      article.toMap(),
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [article.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete(
      DatabaseConstants.tableArticles,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Article>> getAllArticles() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableArticles,
      orderBy: '${DatabaseConstants.colSavedAt} DESC',
    );
    return List.generate(maps.length, (i) {
      return Article.fromMap(maps[i]);
    });
  }

  Future<List<Article>> getArticlesByFolder(int? folderId) async {
    final db = await _db;
    final whereClause = folderId == null
        ? '${DatabaseConstants.colFolderId} IS NULL'
        : '${DatabaseConstants.colFolderId} = ?';
    final whereArgs = folderId == null ? null : [folderId];

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableArticles,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: '${DatabaseConstants.colSavedAt} DESC',
    );
    return List.generate(maps.length, (i) {
      return Article.fromMap(maps[i]);
    });
  }

  Future<Article?> getArticle(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableArticles,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Article.fromMap(maps.first);
    }
    return null;
  }

  Future<Article?> getArticleByUrl(String url) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableArticles,
      where: '${DatabaseConstants.colUrl} = ?',
      whereArgs: [url],
    );
    if (maps.isNotEmpty) {
      return Article.fromMap(maps.first);
    }
    return null;
  }

  Future<int> clearAll() async {
    final db = await _db;
    return db.delete(DatabaseConstants.tableArticles);
  }
}
