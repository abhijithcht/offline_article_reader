import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
    }
  }

  Future<void> _processArticle() async {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      // Navigate to Reader Screen with the URL as a query parameter or state
      await context.pushNamed('reader', queryParameters: {'url': url});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.inputUrlHint,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p24),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'URL',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              onSubmitted: (_) async => _processArticle(),
            ),
            const SizedBox(height: AppSizes.p16),
            OutlinedButton.icon(
              onPressed: _pasteFromClipboard,
              icon: const Icon(Icons.paste),
              label: const Text(AppStrings.pasteFromClipboard),
            ),
            const SizedBox(height: AppSizes.p24),
            ElevatedButton(
              onPressed: () async => _processArticle(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(AppStrings.cleanArticle),
            ),
          ],
        ),
      ),
    );
  }
}
