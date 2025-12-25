import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:readlater/core/constants/app_sizes.dart';
import 'package:readlater/core/constants/app_strings.dart';
import 'package:readlater/features/onboarding/models/onboarding_page.dart';
import 'package:readlater/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:readlater/router/app_routes.dart';

/// Screen displayed to new users to introduce app features.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: AppStrings.onboardingWelcomeTitle,
      description: AppStrings.onboardingWelcomeDesc,
      icon: Icons.auto_stories_rounded,
    ),
    OnboardingPage(
      title: AppStrings.onboardingSaveTitle,
      description: AppStrings.onboardingSaveDesc,
      icon: Icons.bookmark_add_rounded,
    ),
    OnboardingPage(
      title: AppStrings.onboardingReadTitle,
      description: AppStrings.onboardingReadDesc,
      icon: Icons.offline_bolt_rounded,
    ),
    OnboardingPage(
      title: AppStrings.onboardingCustomizeTitle,
      description: AppStrings.onboardingCustomizeDesc,
      icon: Icons.tune_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    // Fix inference issue by casting or explicit type
    await ref.read(onboardingViewModelProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(AppRoutes.homePath);
    }
  }

  Future<void> _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(AppStrings.onboardingSkip),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPageView(page: page, pageIndex: index);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.p24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.all(AppSizes.p24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _nextPage,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                  ),
                  child: Text(
                    isLastPage
                        ? AppStrings.onboardingGetStarted
                        : AppStrings.onboardingNext,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({
    required this.page,
    required this.pageIndex,
  });

  final OnboardingPage page;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animation
          Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  page.icon,
                  size: 56,
                  color: page.iconColor ?? theme.colorScheme.primary,
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

          const SizedBox(height: AppSizes.p48),

          // Title
          Text(
                page.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(
                begin: 0.2,
                end: 0,
              ),

          const SizedBox(height: AppSizes.p16),

          // Description
          Text(
                page.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideY(
                begin: 0.2,
                end: 0,
              ),
        ],
      ),
    );
  }
}
