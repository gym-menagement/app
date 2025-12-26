import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../config/app_text_styles.dart';

/// Gym Design System Bottom Sheet
/// A bottom sheet component with Gym design language
class GymBottomSheet {
  /// Show a modal bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: height,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXXLarge),
          ),
        ),
        child: Column(
          mainAxisSize: height == null ? MainAxisSize.min : MainAxisSize.max,
          children: [
            // Handle bar
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.h3,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: AppColors.grey600,
                      iconSize: AppSpacing.iconLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show a bottom sheet with a list of options
  static Future<T?> showOptions<T>({
    required BuildContext context,
    String? title,
    required List<GymBottomSheetOption<T>> options,
    bool showCancel = true,
    String cancelText = '취소',
  }) {
    return show<T>(
      context: context,
      title: title,
      child: Column(
        children: [
          ...options.map((option) => _OptionItem<T>(option: option)),
          if (showCancel) ...[
            const SizedBox(height: AppSpacing.sm),
            _OptionItem<T>(
              option: GymBottomSheetOption<T>(
                label: cancelText,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Option item for bottom sheet
class GymBottomSheetOption<T> {
  const GymBottomSheetOption({
    required this.label,
    this.value,
    this.icon,
    this.isDestructive = false,
    this.onTap,
  });

  final String label;
  final T? value;
  final IconData? icon;
  final bool isDestructive;
  final VoidCallback? onTap;
}

class _OptionItem<T> extends StatelessWidget {
  const _OptionItem({required this.option});

  final GymBottomSheetOption<T> option;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (option.value != null) {
          Navigator.of(context).pop(option.value);
        }
        option.onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                size: AppSpacing.iconLarge,
                color: option.isDestructive ? AppColors.error : AppColors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Text(
                option.label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: option.isDestructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
