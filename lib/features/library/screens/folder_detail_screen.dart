import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_article_reader/app_imports.dart';
import 'package:offline_article_reader/features/library/models/folder.dart';
import 'package:offline_article_reader/features/library/screens/move_to_folder_dialog.dart';
import 'package:offline_article_reader/features/library/viewmodels/folders_viewmodel.dart';

class FolderDetailScreen extends ConsumerWidget {
  const FolderDetailScreen({required this.folder, super.key});
  final Folder folder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We filter articles by reading the main library list and filtering by folderId
    final articlesAsync = ref.watch(libraryViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(folder.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _renameFolder(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteFolder(context, ref),
          ),
        ],
      ),
      body: articlesAsync.when(
        data: (articles) {
          final folderArticles = articles
              .where((a) => a.folderId == folder.id)
              .toList();

          if (folderArticles.isEmpty) {
            return const Center(
              child: Text(
                'No articles in this folder.\nUse "Move to Folder" to add articles.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return SafeArea(
            top: false,
            child: ListView.builder(
              itemCount: folderArticles.length,
              itemBuilder: (context, index) {
                final article = folderArticles[index];
                return ListTile(
                  title: Text(article.title),
                  subtitle: Text(
                    article.publishedAt != null
                        ? article.publishedAt.toString()
                        : 'No date',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () async {
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) => MoveToFolderDialog(
                          articleId: article.id!,
                          currentFolderId: folder.id,
                        ),
                      );
                    },
                  ),
                  onTap: () async {
                    // Navigate to reader
                    await context.pushNamed(
                      AppRoutes.readerName,
                      queryParameters: {'url': article.url},
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _renameFolder(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: folder.name);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Folder Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty &&
                  controller.text != folder.name) {
                await ref
                    .read(foldersViewModelProvider.notifier)
                    .renameFolder(folder.id!, controller.text);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  // We might want to pop the screen too if the folder name is critical context,
                  // or rely on a stream update if we had one for single folder.
                  // Since we pass 'Folder' object, the title won't update automatically
                  // unless we refetch or pass ID + provider.
                  // Simpler: pop back.
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFolder(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder?'),
        content: const Text(
          'Articles in this folder will be moved to Uncategorized.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      await ref
          .read(foldersViewModelProvider.notifier)
          .deleteFolder(folder.id!);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
