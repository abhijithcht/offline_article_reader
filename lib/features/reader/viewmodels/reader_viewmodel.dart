import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlater/app_imports.dart';
import 'package:riverpod/riverpod.dart';

/// ViewModel for the Reader feature.
class ReaderViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initial state implementation needed for this action-based VM
    // but we can manage the "saving" state here.
  }

  /// Save the current article to the library
  Future<void> saveArticle({
    required String url,
    required String title,
    required String content,
    String? imageUrl,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final articleToSave = Article(
        url: url,
        title: title,
        content: content,
        imageUrl: imageUrl,
        savedAt: DateTime.now(),
      );

      final storage = ref.read(storageServiceProvider);
      await storage.saveArticle(articleToSave);

      // We should also refresh the library list and article provider
      ref
        ..invalidate(libraryViewModelProvider)
        ..invalidate(articleContentProvider(url));
    });
  }
}

/// Provider for the ReaderViewModel
final readerViewModelProvider = AsyncNotifierProvider<ReaderViewModel, void>(
  ReaderViewModel.new,
);
