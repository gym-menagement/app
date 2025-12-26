import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Toss Design System Typography
/// Clean, readable typography inspired by Toss's design language
class AppTextStyles {
  // Display - For hero sections and large headings
  static const displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const displayMedium = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const displaySmall = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  // Headings - For section titles
  static const h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  // Title - For card titles and labels
  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  // Body - For main content
  static const bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  // Labels - For input labels and small text
  static const labelLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textTertiary,
  );

  // Button - For buttons
  static const buttonLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
  );

  static const buttonMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
  );

  static const buttonSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
  );

  // Legacy button style for backward compatibility
  static const button = buttonMedium;

  // Caption - For hints and helper text
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textTertiary,
  );

  // Link
  static const link = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  // Status messages
  static const error = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.error,
  );

  static const success = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.success,
  );

  static const warning = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.warning,
  );
}
