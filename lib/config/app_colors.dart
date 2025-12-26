import 'package:flutter/material.dart';

/// Toss Design System Colors
/// Based on Toss's clean and modern design language
class AppColors {
  // Primary Colors - Toss Blue
  static const primary = Color(0xFF3182F6);  // Toss Blue
  static const primaryPressed = Color(0xFF1B64DA);  // Darker blue for pressed state
  static const primaryLight = Color(0xFFEBF4FF);  // Light blue background
  static const onPrimary = Color(0xFFFFFFFF);

  // Grayscale - Toss Grayscale System
  static const grey50 = Color(0xFFF9FAFB);
  static const grey100 = Color(0xFFF2F4F6);
  static const grey200 = Color(0xFFE5E8EB);
  static const grey300 = Color(0xFFD1D6DB);
  static const grey400 = Color(0xFFB0B8C1);
  static const grey500 = Color(0xFF8B95A1);
  static const grey600 = Color(0xFF6B7684);
  static const grey700 = Color(0xFF4E5968);
  static const grey800 = Color(0xFF333D4B);
  static const grey900 = Color(0xFF191F28);

  // Text Colors
  static const textPrimary = grey900;
  static const textSecondary = grey700;
  static const textTertiary = grey500;
  static const textDisabled = grey400;
  static const textInverse = Color(0xFFFFFFFF);

  // Background Colors
  static const background = Color(0xFFFFFFFF);
  static const backgroundElevated = Color(0xFFFFFFFF);
  static const backgroundDimmed = grey50;
  static const surface = grey100;
  static const onBackground = grey900;
  static const onSurface = grey900;

  // Status Colors
  static const success = Color(0xFF0BC27C);  // Toss green
  static const successLight = Color(0xFFE8FAF4);
  static const onSuccess = Color(0xFFFFFFFF);

  static const error = Color(0xFFF04452);  // Toss red
  static const errorLight = Color(0xFFFFF0F1);
  static const onError = Color(0xFFFFFFFF);

  static const warning = Color(0xFFF89A24);  // Toss orange
  static const warningLight = Color(0xFFFFF5E6);
  static const onWarning = Color(0xFF000000);

  static const info = Color(0xFF3182F6);  // Same as primary
  static const infoLight = Color(0xFFEBF4FF);
  static const onInfo = Color(0xFFFFFFFF);

  // Social Login Colors
  static const kakao = Color(0xFFFEE500);
  static const kakaoLabel = Color(0xFF000000);
  static const naver = Color(0xFF03C75A);
  static const naverLabel = Color(0xFFFFFFFF);
  static const google = Color(0xFFFFFFFF);
  static const googleLabel = Color(0xFF000000);
  static const apple = Color(0xFF000000);
  static const appleLabel = Color(0xFFFFFFFF);

  // Border Colors
  static const border = grey300;
  static const borderLight = grey200;
  static const borderStrong = grey500;

  // Overlay Colors
  static const overlay = Color(0x80000000);  // 50% black
  static const overlayLight = Color(0x1A000000);  // 10% black

  // Membership Status Colors
  static const membershipActive = success;
  static const membershipExpiringSoon = warning;
  static const membershipExpired = grey500;
  static const membershipPaused = info;

  // Divider
  static const divider = grey200;
}
