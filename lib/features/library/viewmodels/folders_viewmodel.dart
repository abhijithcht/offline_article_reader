import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlater/app_imports.dart';
import 'package:readlater/features/library/models/folder.dart';

class FoldersViewModel extends AsyncNotifier<List<Folder>> {
  @override
  Future<List<Folder>> build() async {
    return _fetchFolders();
  }

  Future<List<Folder>> _fetchFolders() async {
    final storage = ref.read(storageServiceProvider);
    return storage.getAllFolders();
  }

  Future<void> createFolder(String name) async {
    final storage = ref.read(storageServiceProvider);
    final folder = Folder(
      name: name,
      createdAt: DateTime.now(),
    );
    await storage.createFolder(folder);
    state = await AsyncValue.guard(_fetchFolders);
  }

  Future<void> renameFolder(int id, String newName) async {
    final storage = ref.read(storageServiceProvider);
    final currentList = state.value;
    final folder = currentList?.firstWhere((Folder f) => f.id == id);

    if (folder != null) {
      final updated = folder.copyWith(name: newName);
      await storage.updateFolder(updated);
      state = await AsyncValue.guard(_fetchFolders);
    }
  }

  Future<void> deleteFolder(int id) async {
    final storage = ref.read(storageServiceProvider);
    await storage.deleteFolder(id);
    state = await AsyncValue.guard(_fetchFolders);
    // Also refresh library to update uncategorized articles if needed
    ref.invalidate(libraryViewModelProvider);
  }
}

final foldersViewModelProvider =
    AsyncNotifierProvider<FoldersViewModel, List<Folder>>(FoldersViewModel.new);
