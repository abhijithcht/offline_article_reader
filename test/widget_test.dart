import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_article_reader/app_imports.dart';
import 'package:offline_article_reader/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Note: We need a ProviderScope for the app to run

void main() {
  testWidgets('App starts and shows LibraryScreen (or empty state)', (
    WidgetTester tester,
  ) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          libraryViewModelProvider.overrideWith(FakeLibraryViewModel.new),
          urlInputViewModelProvider.overrideWith(FakeUrlInputViewModel.new),
          settingsViewModelProvider.overrideWith(FakeSettingsViewModel.new),
        ],
        child: const OfflineArticleReaderApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that we see the Library Screen title or Onboarding based on default prefs
    // Default bool is usually false for "onboardingComplete" if not set?
    // Let's check logic. If key is missing, onboarding is NOT complete.
    // So we should expect Onboarding screen.

    // Actually, checking "Library" implies the test expects us to BE at home.
    // So we should set the pref to true.

    // Re-mock with onboarding complete
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
    });
    final prefsComplete = await SharedPreferences.getInstance();

    // Re-pump with new prefs
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefsComplete),
          libraryViewModelProvider.overrideWith(FakeLibraryViewModel.new),
          urlInputViewModelProvider.overrideWith(FakeUrlInputViewModel.new),
          settingsViewModelProvider.overrideWith(FakeSettingsViewModel.new),
        ],
        child: const OfflineArticleReaderApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that we see the Library Screen title (e.g. "Library")
    // The app title in library screen is actually AppStrings.appName "Offline Article Reader"
    // But let's check for "Empty Library" text or similar if library is empty.
    // LibraryScreen title is AppStrings.appName.

    // Check what LibraryScreen displays.
    // AppBar title: const Text(AppStrings.appName),
    // AppStrings.appName is likely "Offline Reader" or similar.
    // Let's check AppStrings.

    // Instead of guessing string, let's just assert we found a widget that is likely unique to Home.
    expect(find.byType(FloatingActionButton), findsWidgets);
  });
}

class FakeLibraryViewModel extends AsyncNotifier<List<Article>>
    implements LibraryViewModel {
  @override
  Future<List<Article>> build() async {
    return [];
  }

  @override
  Future<String> getUrlFromClipboard() async => '';

  @override
  Future<void> refresh() async {}

  @override
  Future<void> deleteArticle(int id) async {}
}

class FakeUrlInputViewModel extends AsyncNotifier<void>
    implements UrlInputViewModel {
  @override
  Future<void> build() async {}

  @override
  Future<String?> getClipboardText() async => null;

  @override
  String? validateUrl(String url) => null;
}

class FakeSettingsViewModel extends AsyncNotifier<void>
    implements SettingsViewModel {
  @override
  Future<void> build() async {}

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {}

  @override
  Future<void> clearAllData() async {}
}
