import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

/// ViewModel for the URL Input screen.
class UrlInputViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initial state implementation needed
  }

  /// Passthrough to get clipboard content
  Future<String?> getClipboardText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  /// Validate URL
  String? validateUrl(String url) {
    if (url.isEmpty) {
      return 'Please enter a URL';
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'Please enter a valid URL';
    }
    return null;
  }
}

/// Provider for the UrlInputViewModel
final urlInputViewModelProvider =
    AsyncNotifierProvider<UrlInputViewModel, void>(
      UrlInputViewModel.new,
    );
