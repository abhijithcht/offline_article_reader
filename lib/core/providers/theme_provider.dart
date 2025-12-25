import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode options
enum AppThemeMode {
  system,
  light,
  dark,
}

/// SharedPreferences key for theme
const _themeKey = 'app_theme_mode';

/// Notifier to manage theme mode state
class ThemeModeNotifier extends Notifier<AppThemeMode> {
  late SharedPreferences _prefs;

  @override
  AppThemeMode build() {
    // This will be called when the provider is first read
    // For now return system, actual prefs will be set via init
    return AppThemeMode.system;
  }

  void init(SharedPreferences prefs) {
    _prefs = prefs;
    final value = _prefs.getString(_themeKey);
    state = switch (value) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system,
    };
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    await _prefs.setString(_themeKey, mode.name);
  }

  /// Cycle through theme modes: system -> light -> dark -> system
  Future<void> cycleTheme() async {
    final nextMode = switch (state) {
      AppThemeMode.system => AppThemeMode.light,
      AppThemeMode.light => AppThemeMode.dark,
      AppThemeMode.dark => AppThemeMode.system,
    };
    await setThemeMode(nextMode);
  }
}

/// Provider for theme mode state
final themeModeProvider = NotifierProvider<ThemeModeNotifier, AppThemeMode>(
  ThemeModeNotifier.new,
);

/// Convert AppThemeMode to Flutter ThemeMode
ThemeMode toFlutterThemeMode(AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}

/// Get icon for current theme mode
IconData getThemeModeIcon(AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.system => Icons.brightness_auto,
    AppThemeMode.light => Icons.light_mode,
    AppThemeMode.dark => Icons.dark_mode,
  };
}

/// Get label for current theme mode
String getThemeModeLabel(AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.system => 'System',
    AppThemeMode.light => 'Light',
    AppThemeMode.dark => 'Dark',
  };
}
