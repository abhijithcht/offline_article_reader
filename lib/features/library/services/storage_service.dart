import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlater/app_imports.dart';
import 'package:readlater/features/library/data/article_dao.dart';
import 'package:readlater/features/library/data/folder_dao.dart';
import 'package:readlater/features/library/models/folder.dart';

// Provider for ArticleDao
final articleDaoProvider = Provider<ArticleDao>((ref) {
  return ArticleDao();
});

// Provider for FolderDao
final folderDaoProvider = Provider<FolderDao>((ref) {
  return FolderDao();
});

// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  final articleDao = ref.watch(articleDaoProvider);
  final folderDao = ref.watch(folderDaoProvider);
  return StorageService(articleDao, folderDao);
});

// Provider for observing the list of articles
final FutureProvider<List<Article>> savedArticlesProvider =
    FutureProvider.autoDispose<List<Article>>((
      ref,
    ) async {
      final storage = ref.watch(storageServiceProvider);
      return storage.getAllArticles();
    });

class StorageService {
  StorageService(this._articleDao, this._folderDao);
  final ArticleDao _articleDao;
  final FolderDao _folderDao;

  // --- Articles ---

  Future<int> saveArticle(Article article) async {
    return _articleDao.insert(article);
  }

  Future<int> deleteArticle(int id) async {
    return _articleDao.delete(id);
  }

  Future<List<Article>> getAllArticles() async {
    return _articleDao.getAllArticles();
  }

  Future<Article?> getArticle(int id) async {
    return _articleDao.getArticle(id);
  }

  /// Get article by URL (for cached reading)
  Future<Article?> getArticleByUrl(String url) async {
    return _articleDao.getArticleByUrl(url);
  }

  /// Delete all articles from the database
  Future<int> clearAllArticles() async {
    // Delete all articles
    await _articleDao.clearAll();
    // Also delete all folders?
    // Let's iterate delete folders to trigger cascade if needed or manual
    // Actually, FolderDao doesn't have clearAll.
    // Let's leave folders for now unless requested.
    return 0; // Return value not critical for void callers but method returns int
  }

  Future<void> moveArticleToFolder(int articleId, int? folderId) async {
    final article = await _articleDao.getArticle(articleId);
    if (article != null) {
      final updated = article.copyWith(folderId: folderId);
      await _articleDao.update(updated);
    }
  }

  // --- Folders ---

  Future<List<Folder>> getAllFolders() async {
    return _folderDao.getAllFolders();
  }

  Future<int> createFolder(Folder folder) async {
    return _folderDao.insert(folder);
  }

  Future<int> updateFolder(Folder folder) async {
    return _folderDao.update(folder);
  }

  Future<int> deleteFolder(int id) async {
    return _folderDao.delete(id);
  }

  Future<List<Article>> getArticlesByFolder(int? folderId) async {
    return _articleDao.getArticlesByFolder(folderId);
  }
}
