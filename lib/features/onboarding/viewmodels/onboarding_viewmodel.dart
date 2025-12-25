import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_article_reader/app_imports.dart';
import 'package:riverpod/riverpod.dart';

/// ViewModel for the Onboarding feature.
class OnboardingViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No state to maintain here ideally, as we check 'onboardingComplete' global state
    // but the VM is for the screen logic.
  }

  Future<void> completeOnboarding() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(onboardingServiceProvider).completeOnboarding();
    });
  }
}

/// Provider for the OnboardingViewModel
final onboardingViewModelProvider =
    AsyncNotifierProvider<OnboardingViewModel, void>(
      OnboardingViewModel.new,
    );
