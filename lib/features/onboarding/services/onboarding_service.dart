import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _onboardingCompleteKey = 'onboarding_complete';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main');
});

/// Provider to check if onboarding is complete
final onboardingCompleteProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(_onboardingCompleteKey) ?? false;
});

/// Service for managing onboarding state
class OnboardingService {
  OnboardingService(this._prefs);
  final SharedPreferences _prefs;

  bool get isOnboardingComplete =>
      _prefs.getBool(_onboardingCompleteKey) ?? false;

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingCompleteKey, true);
  }

  Future<void> resetOnboarding() async {
    await _prefs.remove(_onboardingCompleteKey);
  }
}

/// Provider for OnboardingService
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingService(prefs);
});
