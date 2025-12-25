import 'package:offline_article_reader/core/database/tables.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DatabaseConstants.databaseName);

    return openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: (db, version) async {
        await _createArticlesTable(db);
        await _createHistoryTable(db);
        await _createFoldersTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migration to version 2
          await _createFoldersTable(db);
          // Add folderId to articles table
          await db.execute(
            'ALTER TABLE ${DatabaseConstants.tableArticles} ADD COLUMN ${DatabaseConstants.colFolderId} INTEGER',
          );
        }
      },
    );
  }

  Future<void> _createArticlesTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableArticles}(
        ${DatabaseConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colUrl} TEXT NOT NULL,
        ${DatabaseConstants.colTitle} TEXT NOT NULL,
        ${DatabaseConstants.colAuthor} TEXT,
        ${DatabaseConstants.colContent} TEXT,
        ${DatabaseConstants.colImageUrl} TEXT,
        ${DatabaseConstants.colDescription} TEXT,
        ${DatabaseConstants.colSavedAt} INTEGER NOT NULL,
        ${DatabaseConstants.colPublishedAt} INTEGER
      )
    ''');
  }

  Future<void> _createHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableHistory}(
        ${DatabaseConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colUrl} TEXT NOT NULL UNIQUE,
        ${DatabaseConstants.colTitle} TEXT NOT NULL,
        ${DatabaseConstants.colImageUrl} TEXT,
        ${DatabaseConstants.colViewedAt} INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_history_title ON ${DatabaseConstants.tableHistory}(${DatabaseConstants.colTitle})
    ''');

    await db.execute('''
      CREATE INDEX idx_history_viewedAt ON ${DatabaseConstants.tableHistory}(${DatabaseConstants.colViewedAt} DESC)
    ''');
  }

  Future<void> _createFoldersTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableFolders}(
        ${DatabaseConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colFolderName} TEXT NOT NULL,
        ${DatabaseConstants.colFolderCreatedAt} INTEGER NOT NULL
      )
    ''');
  }
}
