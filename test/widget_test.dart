import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_article_reader/main.dart';
// Note: We need a ProviderScope for the app to run

void main() {
  testWidgets('App starts and shows LibraryScreen (or empty state)', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    // Ensure we wrap with ProviderScope since main.dart does it but here we pump directly?
    // Actually OfflineArticleReaderApp is ConsumerWidget but main() wraps it.
    // But OfflineArticleReaderApp likely expects a Scope if it used ref inside build,
    // but in main.dart: runApp(ProviderScope(child: OfflineArticleReaderApp()));
    // OfflineArticleReaderApp extends ConsumerWidget so it needs scope to be valid.
    // However, if we pump OfflineArticleReaderApp directly, it needs a parent scope.
    // The main() function wraps it.

    await tester.pumpWidget(
      const ProviderScope(child: OfflineArticleReaderApp()),
    );
    await tester.pumpAndSettle();

    // Verify that we see the Library Screen title (e.g. "Library")
    expect(find.text('Library'), findsOneWidget);

    // Verify FAB exists
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
