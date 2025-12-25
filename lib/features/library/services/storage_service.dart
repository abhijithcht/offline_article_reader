import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_article_reader/app_imports.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Provider for observing the list of articles (Reactive - manually triggering refresh or Stream)
// Sqflite doesn't support streams out of the box like Isar/Hive.
// We will return a Future here and use refresh logic or a StreamController if needed.
// For now, simpler FutureProvider or Stream derived from controller.
final FutureProvider<List<Article>> savedArticlesProvider =
    FutureProvider.autoDispose<List<Article>>((
      ref,
    ) async {
      final storage = ref.watch(storageServiceProvider);
      return storage.getAllArticles();
    });

class StorageService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'articles.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE articles(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT NOT NULL,
            title TEXT NOT NULL,
            author TEXT,
            content TEXT,
            imageUrl TEXT,
            description TEXT,
            savedAt INTEGER NOT NULL,
            publishedAt INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        // Handle schema changes
      },
    );
  }

  Future<int> saveArticle(Article article) async {
    final db = await database;

    // Create map without id (id is auto-generated)
    final data = article.toMap()..remove('id');

    // Check if exists
    final existing = await db.query(
      'articles',
      where: 'url = ?',
      whereArgs: [article.url],
    );

    if (existing.isNotEmpty) {
      // Update
      return db.update(
        'articles',
        data,
        where: 'url = ?',
        whereArgs: [article.url],
      );
    } else {
      // Insert
      return db.insert('articles', data);
    }
  }

  Future<int> deleteArticle(int id) async {
    final db = await database;
    return db.delete(
      'articles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Article>> getAllArticles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'articles',
      orderBy: 'savedAt DESC',
    );
    return List.generate(maps.length, (i) {
      return Article.fromMap(maps[i]);
    });
  }

  Future<Article?> getArticle(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'articles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Article.fromMap(maps.first);
    }
    return null;
  }

  /// Get article by URL (for cached reading)
  Future<Article?> getArticleByUrl(String url) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'articles',
      where: 'url = ?',
      whereArgs: [url],
    );
    if (maps.isNotEmpty) {
      return Article.fromMap(maps.first);
    }
    return null;
  }

  /// Delete all articles from the database
  Future<int> clearAllArticles() async {
    final db = await database;
    return db.delete('articles');
  }
}
