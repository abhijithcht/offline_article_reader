import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_article_reader/app_imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable Google Fonts network fetching for offline support
  AppTheme.init();

  // Initialize SharedPreferences before app starts
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: _AppInitializer(prefs: prefs),
    ),
  );
}

/// Initializes providers before building the main app
class _AppInitializer extends ConsumerStatefulWidget {
  const _AppInitializer({required this.prefs});
  final SharedPreferences prefs;

  @override
  ConsumerState<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<_AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Initialize theme notifier with SharedPreferences
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeModeProvider.notifier).init(widget.prefs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const OfflineArticleReaderApp();
  }
}

/// The root widget of the application.
class OfflineArticleReaderApp extends ConsumerWidget {
  const OfflineArticleReaderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: toFlutterThemeMode(themeMode),
      routerConfig: router,
    );
  }
}
