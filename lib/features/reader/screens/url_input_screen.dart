import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_article_reader/app_imports.dart';

class UrlInputScreen extends ConsumerStatefulWidget {
  const UrlInputScreen({super.key});

  @override
  ConsumerState<UrlInputScreen> createState() => _UrlInputScreenState();
}

class _UrlInputScreenState extends ConsumerState<UrlInputScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final text = await ref
        .read(urlInputViewModelProvider.notifier)
        .getClipboardText();
    if (text != null) {
      _urlController.text = text;
    }
  }

  Future<void> _processArticle() async {
    final url = _urlController.text.trim();
    final viewModel = ref.read(urlInputViewModelProvider.notifier);

    final error = viewModel.validateUrl(url);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.pushNamed(
        AppRoutes.readerName,
        queryParameters: {'url': url},
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Article'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.p32),

              // Icon
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(bottom: AppSizes.p24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.link_rounded,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),

              // Title
              Text(
                'Add New Article',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.p8),

              // Subtitle
              Text(
                'Paste a URL to save the article for offline reading',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.p32),

              // URL Input
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Article URL',
                  hintText: 'https://example.com/article',
                  prefixIcon: const Icon(Icons.link_rounded),
                  suffixIcon: _urlController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _urlController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.go,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) async => _processArticle(),
              ),

              const SizedBox(height: AppSizes.p16),

              // Paste from Clipboard
              OutlinedButton.icon(
                onPressed: _pasteFromClipboard,
                icon: const Icon(Icons.content_paste_rounded),
                label: const Text(AppStrings.pasteFromClipboard),
              ),

              const SizedBox(height: AppSizes.p24),

              // Process Button
              FilledButton(
                onPressed: _isLoading ? null : () async => _processArticle(),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Load Article'),
              ),

              const SizedBox(height: AppSizes.p32),

              // Tips
              Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tip',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      'Copy a link from your browser and tap "Paste from Clipboard" for quick access.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
