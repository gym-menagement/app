import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';

enum SocialProvider {
  kakao,
  naver,
  google,
  apple,
}

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.fullWidth = true,
  });

  final SocialProvider provider;
  final VoidCallback onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final config = _getProviderConfig();

    return SizedBox(
      height: AppSpacing.buttonHeightMedium,
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: config.backgroundColor,
          foregroundColor: config.textColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            side: config.borderColor != null
                ? BorderSide(color: config.borderColor!)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (config.icon != null)
              Image.asset(
                config.icon!,
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    _getFallbackIcon(),
                    size: 20,
                    color: config.textColor,
                  );
                },
              )
            else
              Icon(
                _getFallbackIcon(),
                size: 20,
                color: config.textColor,
              ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              config.text,
              style: AppTextStyles.button.copyWith(
                color: config.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({
    Color backgroundColor,
    Color textColor,
    Color? borderColor,
    String text,
    String? icon,
  }) _getProviderConfig() {
    switch (provider) {
      case SocialProvider.kakao:
        return (
          backgroundColor: AppColors.kakao,
          textColor: Colors.black87,
          borderColor: null,
          text: '카카오로 시작하기',
          icon: 'assets/images/kakao_logo.png',
        );
      case SocialProvider.naver:
        return (
          backgroundColor: AppColors.naver,
          textColor: Colors.white,
          borderColor: null,
          text: '네이버로 시작하기',
          icon: 'assets/images/naver_logo.png',
        );
      case SocialProvider.google:
        return (
          backgroundColor: AppColors.google,
          textColor: Colors.black87,
          borderColor: AppColors.grey300,
          text: 'Google로 시작하기',
          icon: 'assets/images/google_logo.png',
        );
      case SocialProvider.apple:
        return (
          backgroundColor: AppColors.apple,
          textColor: Colors.white,
          borderColor: null,
          text: 'Apple로 시작하기',
          icon: 'assets/images/apple_logo.png',
        );
    }
  }

  IconData _getFallbackIcon() {
    switch (provider) {
      case SocialProvider.kakao:
        return Icons.chat_bubble;
      case SocialProvider.naver:
        return Icons.search;
      case SocialProvider.google:
        return Icons.g_mobiledata;
      case SocialProvider.apple:
        return Icons.apple;
    }
  }
}
