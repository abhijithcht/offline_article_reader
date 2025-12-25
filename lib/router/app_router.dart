import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:readlater/app_imports.dart';

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final isOnboardingComplete = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    initialLocation: isOnboardingComplete
        ? AppRoutes.homePath
        : AppRoutes.onboardingPath,
    routes: [
      GoRoute(
        path: AppRoutes.onboardingPath,
        name: AppRoutes.onboardingName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.homeName,
        builder: (context, state) => const LibraryScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.addArticleRelative,
            name: AppRoutes.addArticleName,
            builder: (context, state) => const UrlInputScreen(),
          ),
          GoRoute(
            path: AppRoutes.readerRelative,
            name: AppRoutes.readerName,
            builder: (context, state) {
              final url = state.uri.queryParameters['url'];
              if (url == null) {
                return const Scaffold(
                  body: Center(child: Text('Error: No URL provided')),
                );
              }
              return ReaderScreen(url: url);
            },
          ),
          GoRoute(
            path: AppRoutes.settingsRelative,
            name: AppRoutes.settingsName,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.historyRelative,
            name: AppRoutes.historyName,
            builder: (context, state) => const HistoryScreen(),
          ),
        ],
      ),
    ],
  );
});
