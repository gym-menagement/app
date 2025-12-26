import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../config/app_text_styles.dart';

enum TossChipSize { small, medium, large }
enum TossChipStyle { filled, outlined, ghost }

/// Toss Design System Chip
/// A compact element for displaying tags, categories, or attributes
class TossChip extends StatelessWidget {
  const TossChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.onDelete,
    this.size = TossChipSize.medium,
    this.style = TossChipStyle.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.selected = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final TossChipSize size;
  final TossChipStyle style;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: _getIconSize(),
            color: colors.foreground,
          ),
          SizedBox(width: size == TossChipSize.small ? AppSpacing.xs : AppSpacing.sm),
        ],
        Text(
          label,
          style: textStyle.copyWith(color: colors.foreground),
        ),
        if (onDelete != null) ...[
          SizedBox(width: size == TossChipSize.small ? AppSpacing.xs : AppSpacing.sm),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close,
              size: _getIconSize(),
              color: colors.foreground,
            ),
          ),
        ],
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: colors.background,
          border: style == TossChipStyle.outlined
              ? Border.all(color: colors.border, width: AppSpacing.borderThin)
              : null,
          borderRadius: BorderRadius.circular(
            size == TossChipSize.large
                ? AppSpacing.radiusMedium
                : AppSpacing.radiusSmall,
          ),
        ),
        child: content,
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case TossChipSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        );
      case TossChipSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        );
      default:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case TossChipSize.small:
        return AppTextStyles.labelSmall;
      case TossChipSize.large:
        return AppTextStyles.labelLarge;
      default:
        return AppTextStyles.labelMedium;
    }
  }

  double _getIconSize() {
    switch (size) {
      case TossChipSize.small:
        return AppSpacing.iconSmall;
      case TossChipSize.large:
        return AppSpacing.iconMedium;
      default:
        return AppSpacing.iconSmall;
    }
  }

  ({Color background, Color foreground, Color border}) _getColors() {
    final effectiveBackgroundColor = backgroundColor;
    final effectiveForegroundColor = foregroundColor;

    if (selected) {
      return (
        background: effectiveBackgroundColor ?? AppColors.primary,
        foreground: effectiveForegroundColor ?? AppColors.onPrimary,
        border: effectiveBackgroundColor ?? AppColors.primary,
      );
    }

    switch (style) {
      case TossChipStyle.outlined:
        return (
          background: Colors.transparent,
          foreground: effectiveForegroundColor ?? AppColors.textPrimary,
          border: AppColors.border,
        );
      case TossChipStyle.ghost:
        return (
          background: Colors.transparent,
          foreground: effectiveForegroundColor ?? AppColors.textPrimary,
          border: Colors.transparent,
        );
      default:
        return (
          background: effectiveBackgroundColor ?? AppColors.grey100,
          foreground: effectiveForegroundColor ?? AppColors.textPrimary,
          border: AppColors.border,
        );
    }
  }
}
