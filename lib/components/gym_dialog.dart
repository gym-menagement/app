import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../config/app_text_styles.dart';
import 'gym_button.dart';

/// Gym Design System Dialog
/// A modal dialog component with Gym design language
class GymDialog {
  /// Show a simple alert dialog
  static Future<bool?> showAlert({
    required BuildContext context,
    String? title,
    required String message,
    String confirmText = '확인',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title,
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  if (cancelText != null) ...[
                    Expanded(
                      child: GymButton(
                        text: cancelText,
                        style: GymButtonStyle.outlined,
                        purpose: GymButtonPurpose.neutral,
                        onPressed: () {
                          Navigator.of(context).pop(false);
                          onCancel?.call();
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: GymButton(
                      text: confirmText,
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        onConfirm?.call();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show a confirmation dialog
  static Future<bool?> showConfirm({
    required BuildContext context,
    String? title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title,
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: GymButton(
                      text: cancelText,
                      style: GymButtonStyle.outlined,
                      purpose: GymButtonPurpose.neutral,
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        onCancel?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GymButton(
                      text: confirmText,
                      purpose: isDangerous ? GymButtonPurpose.error : GymButtonPurpose.primary,
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        onConfirm?.call();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show a custom dialog with custom content
  static Future<T?> showCustom<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
        ),
        child: child,
      ),
    );
  }
}

/// Show a success message dialog
Future<void> showSuccessDialog({
  required BuildContext context,
  String title = '성공',
  required String message,
  String buttonText = '확인',
}) {
  return GymDialog.showAlert(
    context: context,
    title: title,
    message: message,
    confirmText: buttonText,
  );
}

/// Show an error message dialog
Future<void> showErrorDialog({
  required BuildContext context,
  String title = '오류',
  required String message,
  String buttonText = '확인',
}) {
  return GymDialog.showAlert(
    context: context,
    title: title,
    message: message,
    confirmText: buttonText,
  );
}
