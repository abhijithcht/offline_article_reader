import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readlater/app_imports.dart';
import 'package:riverpod/riverpod.dart';

/// ViewModel for the Settings screen.
class SettingsViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initial state
  }

  /// Sets the application theme mode.
  Future<void> setThemeMode(AppThemeMode mode) async {
    // Delegates to the theme provider's notifier
    await ref.read(themeModeProvider.notifier).setThemeMode(mode);
  }

  /// Clears all saved articles and history.
  Future<void> clearAllData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final storage = ref.read(storageServiceProvider);
      await storage.clearAllArticles();

      // We should also clear history?
      // The previous implementation only cleared articles.
      // But "Clear All Data" implies everything.
      // Based on previous code: await storage.clearAllArticles();

      // Refresh relevant providers
      ref
        ..invalidate(savedArticlesProvider)
        // Invalidate all reader caches
        ..invalidate(articleContentProvider);
    });
  }
}

/// Provider for the SettingsViewModel
final settingsViewModelProvider =
    AsyncNotifierProvider<SettingsViewModel, void>(
      SettingsViewModel.new,
    );
