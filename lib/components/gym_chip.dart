import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../config/app_text_styles.dart';

enum GymChipSize { small, medium, large }
enum GymChipStyle { filled, outlined, ghost }

/// Gym Design System Chip
/// A compact element for displaying tags, categories, or attributes
class GymChip extends StatelessWidget {
  const GymChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.onDelete,
    this.size = GymChipSize.medium,
    this.style = GymChipStyle.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.selected = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final GymChipSize size;
  final GymChipStyle style;
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
          SizedBox(width: size == GymChipSize.small ? AppSpacing.xs : AppSpacing.sm),
        ],
        Text(
          label,
          style: textStyle.copyWith(color: colors.foreground),
        ),
        if (onDelete != null) ...[
          SizedBox(width: size == GymChipSize.small ? AppSpacing.xs : AppSpacing.sm),
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
          border: style == GymChipStyle.outlined
              ? Border.all(color: colors.border, width: AppSpacing.borderThin)
              : null,
          borderRadius: BorderRadius.circular(
            size == GymChipSize.large
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
      case GymChipSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        );
      case GymChipSize.large:
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
      case GymChipSize.small:
        return AppTextStyles.labelSmall;
      case GymChipSize.large:
        return AppTextStyles.labelLarge;
      default:
        return AppTextStyles.labelMedium;
    }
  }

  double _getIconSize() {
    switch (size) {
      case GymChipSize.small:
        return AppSpacing.iconSmall;
      case GymChipSize.large:
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
      case GymChipStyle.outlined:
        return (
          background: Colors.transparent,
          foreground: effectiveForegroundColor ?? AppColors.textPrimary,
          border: AppColors.border,
        );
      case GymChipStyle.ghost:
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
