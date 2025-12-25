import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:readlater/app_imports.dart';
import 'package:readlater/features/library/screens/folder_detail_screen.dart';
import 'package:readlater/features/library/screens/move_to_folder_dialog.dart';
import 'package:readlater/features/library/viewmodels/folders_viewmodel.dart';

/// Screen that displays the list of saved articles.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _fabKey = GlobalKey<ExpandableFabState>();

  Future<void> _pasteAndOpen() async {
    // Close the FAB menu
    _fabKey.currentState?.toggle();

    try {
      final viewModel = ref.read(libraryViewModelProvider.notifier);
      final url = await viewModel.getUrlFromClipboard();

      // Navigate to reader with clipboard URL
      if (mounted) {
        await context.pushNamed(
          AppRoutes.readerName,
          queryParameters: {'url': url},
        );
        // Refresh library when returning
        await viewModel.refresh();
      }
    } on Exception catch (e) {
      if (mounted) {
        // Strip "Exception: " prefix for cleaner message if possible
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  Future<void> _addArticle() async {
    // Close the FAB menu
    _fabKey.currentState?.toggle();

    await context.push(AppRoutes.addArticlePath);
    if (mounted) {
      unawaited(ref.read(libraryViewModelProvider.notifier).refresh());
    }
  }

  void _showCreateFolderDialog() {
    // Close the FAB menu
    _fabKey.currentState?.toggle();

    final controller = TextEditingController();
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('New Folder'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Folder Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await ref
                      .read(foldersViewModelProvider.notifier)
                      .createFolder(controller.text);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the VM state
    final articlesAsync = ref.watch(libraryViewModelProvider);
    final foldersAsync = ref.watch(foldersViewModelProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.appName),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: () {
                unawaited(
                  ref.read(libraryViewModelProvider.notifier).refresh(),
                );
                ref.invalidate(foldersViewModelProvider);
              },
            ),
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'History',
              onPressed: () => context.push(AppRoutes.historyPath),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () => context.push(AppRoutes.settingsPath),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Articles'),
              Tab(text: 'Folders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Articles
            articlesAsync.when(
              data: (articles) {
                if (articles.isEmpty) {
                  return _EmptyLibraryView(
                    onAddArticle: () => context.push(AppRoutes.addArticlePath),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  itemCount: articles.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSizes.p12),
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return _ArticleCard(article: article);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Error loading articles: $err')),
            ),

            // Tab 2: Folders
            foldersAsync.when(
              data: (folders) {
                if (folders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(height: 16),
                        const Text('No folders yet'),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    return Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      FolderDetailScreen(folder: folder),
                                ),
                              )
                              .ignore();
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                folder.name,
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
        // Expandable FAB using flutter_expandable_fab package
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: ExpandableFab(
          key: _fabKey,
          type: ExpandableFabType.up,
          distance: 70,
          childrenAnimation: ExpandableFabAnimation.none,
          overlayStyle: ExpandableFabOverlayStyle(
            color: theme.colorScheme.scrim.withAlpha(100),
          ),
          openButtonBuilder: RotateFloatingActionButtonBuilder(
            child: const Icon(Icons.add_rounded, size: 24),
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            backgroundColor: theme.colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          closeButtonBuilder: RotateFloatingActionButtonBuilder(
            child: const Icon(Icons.close_rounded, size: 24),
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            backgroundColor: theme.colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          children: [
            // Add Article
            Row(
              children: [
                Text(
                  'Add Article',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                FloatingActionButton.small(
                  heroTag: 'add_article_fab',
                  onPressed: _addArticle,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.article_outlined),
                ),
              ],
            ),
            // Paste URL
            Row(
              children: [
                Text(
                  'Paste URL',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                FloatingActionButton.small(
                  heroTag: 'paste_url_fab',
                  onPressed: _pasteAndOpen,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.content_paste_go_rounded),
                ),
              ],
            ),
            // New Folder
            Row(
              children: [
                Text(
                  'New Folder',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                FloatingActionButton.small(
                  heroTag: 'new_folder_fab',
                  onPressed: _showCreateFolderDialog,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.create_new_folder_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLibraryView extends StatelessWidget {
  const _EmptyLibraryView({required this.onAddArticle});
  final VoidCallback onAddArticle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSizes.p24),
            Text(
              'Your library is empty',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              'Save articles from the web to read them\noffline anytime, anywhere.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p24),
            FilledButton.icon(
              onPressed: onAddArticle,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add your first article'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends ConsumerWidget {
  const _ArticleCard({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateStr = DateFormat.yMMMd().format(article.savedAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await context.pushNamed(
            AppRoutes.readerName,
            queryParameters: {'url': article.url},
          );
          // Refresh library when returning from reader
          final _ = ref.refresh(libraryViewModelProvider);
        },
        onLongPress: () => unawaited(_showOptionsDialog(context, ref)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image with gradient overlay
            if (article.imageUrl != null)
              Stack(
                children: [
                  Image.network(
                    article.imageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  // Gradient for text readability
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 80,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Title on image
                  Positioned(
                    left: AppSizes.p16,
                    right: AppSizes.p16,
                    bottom: AppSizes.p12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              // No image - show text content
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (article.folderId != null) ...[
                          const Spacer(),
                          Icon(
                            Icons.folder_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'In Folder',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOptionsDialog(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Move to Folder'),
              onTap: () async {
                Navigator.pop(context); // Close sheet
                await showDialog<void>(
                  context: context,
                  builder: (context) => MoveToFolderDialog(
                    articleId: article.id!,
                    currentFolderId: article.folderId,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () async {
                Navigator.pop(context); // Close sheet
                await _confirmDelete(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.delete_outline_rounded,
          color: theme.colorScheme.error,
          size: 32,
        ),
        title: const Text(AppStrings.deleteArticle),
        content: Text('Are you sure you want to delete "${article.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      await ref
          .read(libraryViewModelProvider.notifier)
          .deleteArticle(article.id!, article.url);
    }
  }
}
