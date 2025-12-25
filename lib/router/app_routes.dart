/// Centralized route constants for the application
///
/// Use `*Name` constants for route names (for goNamed, pushNamed)
/// Use `*Path` constants for route paths (for go, push)
abstract final class AppRoutes {
  // Route Names
  static const String onboardingName = 'onboarding';
  static const String homeName = 'home';
  static const String addArticleName = 'add_article';
  static const String readerName = 'reader';
  static const String settingsName = 'settings';
  static const String historyName = 'history';

  // Route Paths (absolute)
  static const String onboardingPath = '/onboarding';
  static const String homePath = '/';
  static const String addArticlePath = '/add';
  static const String readerPath = '/read';
  static const String settingsPath = '/settings';
  static const String historyPath = '/history';

  // Route Paths (relative - for nested routes)
  static const String addArticleRelative = 'add';
  static const String readerRelative = 'read';
  static const String settingsRelative = 'settings';
  static const String historyRelative = 'history';

  /// Build reader path with URL query parameter
  static String readerWithUrl(String articleUrl) {
    return '$readerPath?url=${Uri.encodeComponent(articleUrl)}';
  }
}
