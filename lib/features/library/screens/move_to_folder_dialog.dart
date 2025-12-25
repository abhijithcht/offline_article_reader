import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlater/app_imports.dart';
import 'package:readlater/features/library/viewmodels/folders_viewmodel.dart';
import 'package:readlater/features/library/viewmodels/library_viewmodel.dart';

class MoveToFolderDialog extends ConsumerWidget {
  const MoveToFolderDialog({
    required this.articleId,
    this.currentFolderId,
    super.key,
  });
  final int articleId;
  final int? currentFolderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(foldersViewModelProvider);

    return AlertDialog(
      title: const Text('Move to Folder'),
      content: SizedBox(
        width: double.maxFinite,
        child: foldersAsync.when(
          data: (folders) {
            if (folders.isEmpty) {
              return const Text('No folders created yet.');
            }
            return ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: const Icon(Icons.folder_off_outlined),
                  title: const Text('Uncategorized'),
                  selected: currentFolderId == null,
                  onTap: () => _moveArticle(context, ref, null),
                ),
                ...folders.map(
                  (folder) => ListTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: Text(folder.name),
                    selected: folder.id == currentFolderId,
                    onTap: () => _moveArticle(context, ref, folder.id),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Show new folder dialog on top?
            // For simplicity, maybe just close or add a "New Folder" item in list?
            await _showCreateFolderDialog(context, ref);
          },
          child: const Text('New Folder'),
        ),
      ],
    );
  }

  Future<void> _moveArticle(
    BuildContext context,
    WidgetRef ref,
    int? folderId,
  ) async {
    await ref
        .read(libraryViewModelProvider.notifier)
        .moveArticleToFolder(articleId, folderId);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _showCreateFolderDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
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
              if (controller.text.isNotEmpty) {
                await ref
                    .read(foldersViewModelProvider.notifier)
                    .createFolder(controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
