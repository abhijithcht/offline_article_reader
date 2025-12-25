import 'package:flutter/material.dart';

/// Model representing a single onboarding page
class OnboardingPage {
  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
}
