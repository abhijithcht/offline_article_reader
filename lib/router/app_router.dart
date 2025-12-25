import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_article_reader/app_imports.dart';

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const LibraryScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'add_article',
            builder: (context, state) => const UrlInputScreen(),
          ),
          GoRoute(
            path: 'read',
            name: 'reader',
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
        ],
      ),
    ],
  );
});
