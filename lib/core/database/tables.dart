/// Constants for database tables and columns
class DatabaseConstants {
  static const String databaseName = 'app_database.db';
  static const int databaseVersion = 2;

  // Articles Table
  static const String tableArticles = 'articles';
  static const String colId = 'id';
  static const String colUrl = 'url';
  static const String colTitle = 'title';
  static const String colAuthor = 'author';
  static const String colContent = 'content';
  static const String colImageUrl = 'imageUrl';
  static const String colDescription = 'description';
  static const String colSavedAt = 'savedAt';
  static const String colPublishedAt = 'publishedAt';
  static const String colFolderId = 'folderId';

  // Folders Table
  static const String tableFolders = 'folders';
  static const String colFolderName = 'name';
  static const String colFolderCreatedAt = 'createdAt';

  // History Table
  static const String tableHistory = 'history';
  // reuse colId, colUrl, colTitle, colImageUrl
  static const String colViewedAt = 'viewedAt';
}
