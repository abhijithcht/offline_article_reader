import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:offline_article_reader/app_imports.dart';

/// Screen displaying reading history.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch the VM state (which already filters based on query in VM)
    final historyAsync = ref.watch(historyViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search history...',
                  border: InputBorder.none,
                ),
                onChanged: (value) async {
                  await ref
                      .read(historyViewModelProvider.notifier)
                      .setSearchQuery(value);
                },
              )
            : const Text('History'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () async {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
              if (!_isSearching) {
                await ref
                    .read(historyViewModelProvider.notifier)
                    .setSearchQuery('');
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_all') {
                unawaited(_showClearAllDialog(context));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep),
                    SizedBox(width: 12),
                    Text('Clear All History'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: historyAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Text(
                    _searchController.text.isEmpty
                        ? 'No browsing history'
                        : 'No results found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  Text(
                    _searchController.text.isEmpty
                        ? 'Articles you read will appear here'
                        : 'Try a different search term',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _HistoryListTile(
                item: item,
                onTap: () => _openArticle(item),
                onSave: () => unawaited(_saveToLibrary(item)),
                onDelete: () => unawaited(_deleteItem(item)),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object err, _) => Center(
          child: Text('Error loading history: $err'),
        ),
      ),
    );
  }

  void _openArticle(HistoryItem item) {
    unawaited(
      context.pushNamed(
        AppRoutes.readerName,
        queryParameters: {'url': item.url},
      ),
    );
  }

  Future<void> _saveToLibrary(HistoryItem item) async {
    try {
      await ref.read(historyViewModelProvider.notifier).saveToLibrary(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: AppSizes.p12),
                Expanded(child: Text('Article saved to library')),
              ],
            ),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => context.go(AppRoutes.homePath),
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteItem(HistoryItem item) async {
    if (item.id != null) {
      await ref.read(historyViewModelProvider.notifier).deleteItem(item.id!);
    }
  }

  Future<void> _showClearAllDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.delete_sweep,
          color: Theme.of(dialogContext).colorScheme.error,
          size: 32,
        ),
        title: const Text('Clear All History?'),
        content: const Text(
          'This will permanently delete your browsing history. '
          'Saved articles will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    await ref.read(historyViewModelProvider.notifier).clearAllHistory();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('History cleared')),
      );
    }
  }
}

class _HistoryListTile extends StatelessWidget {
  const _HistoryListTile({
    required this.item,
    required this.onTap,
    required this.onSave,
    required this.onDelete,
  });

  final HistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = _formatDate(item.viewedAt);

    return Dismissible(
      key: Key('history_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.p16),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: item.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 56,
                    height: 56,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.article,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            : Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          dateStr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'save':
                onSave();
              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'save',
              child: Row(
                children: [
                  Icon(Icons.save_alt),
                  SizedBox(width: 12),
                  Text('Save to Library'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: theme.colorScheme.error),
                  const SizedBox(width: 12),
                  Text(
                    'Delete',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final viewedDate = DateTime(date.year, date.month, date.day);

    if (viewedDate == today) {
      return 'Today at ${DateFormat.jm().format(date)}';
    } else if (viewedDate == yesterday) {
      return 'Yesterday at ${DateFormat.jm().format(date)}';
    } else {
      return DateFormat.yMMMd().add_jm().format(date);
    }
  }
}
