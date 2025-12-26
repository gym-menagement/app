import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../config/app_text_styles.dart';

enum GymSnackbarType { success, error, warning, info }

/// Gym Design System Snackbar
/// Toast-style notifications with Gym design language
class GymSnackbar {
  /// Show a snackbar message
  static void show({
    required BuildContext context,
    required String message,
    GymSnackbarType type = GymSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    bool showCloseButton = false,
  }) {
    final colors = _getColors(type);
    final icon = _getIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: colors.iconColor, size: AppSpacing.iconMedium),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textColor,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: AppSpacing.md),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onAction();
                },
                style: TextButton.styleFrom(
                  foregroundColor: colors.actionColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                ),
                child: Text(actionLabel),
              ),
            ],
            if (showCloseButton) ...[
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: Icon(Icons.close, size: AppSpacing.iconMedium),
                color: colors.iconColor,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
        backgroundColor: colors.backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),
    );
  }

  /// Show a success snackbar
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: GymSnackbarType.success,
      duration: duration,
    );
  }

  /// Show an error snackbar
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: GymSnackbarType.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show a warning snackbar
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: GymSnackbarType.warning,
      duration: duration,
    );
  }

  /// Show an info snackbar
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: GymSnackbarType.info,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static ({
    Color backgroundColor,
    Color textColor,
    Color iconColor,
    Color actionColor,
  }) _getColors(GymSnackbarType type) {
    switch (type) {
      case GymSnackbarType.success:
        return (
          backgroundColor: AppColors.success,
          textColor: AppColors.onSuccess,
          iconColor: AppColors.onSuccess,
          actionColor: AppColors.onSuccess,
        );
      case GymSnackbarType.error:
        return (
          backgroundColor: AppColors.error,
          textColor: AppColors.onError,
          iconColor: AppColors.onError,
          actionColor: AppColors.onError,
        );
      case GymSnackbarType.warning:
        return (
          backgroundColor: AppColors.warning,
          textColor: AppColors.onWarning,
          iconColor: AppColors.onWarning,
          actionColor: AppColors.onWarning,
        );
      case GymSnackbarType.info:
        return (
          backgroundColor: AppColors.grey800,
          textColor: AppColors.textInverse,
          iconColor: AppColors.textInverse,
          actionColor: AppColors.primary,
        );
    }
  }

  static IconData _getIcon(GymSnackbarType type) {
    switch (type) {
      case GymSnackbarType.success:
        return Icons.check_circle_outline;
      case GymSnackbarType.error:
        return Icons.error_outline;
      case GymSnackbarType.warning:
        return Icons.warning_amber_outlined;
      case GymSnackbarType.info:
        return Icons.info_outline;
    }
  }
}
