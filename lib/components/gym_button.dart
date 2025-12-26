import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';

enum GymButtonSize { small, medium, large }
enum GymButtonStyle { filled, outlined, text, ghost }
enum GymButtonPurpose { primary, secondary, success, error, warning, neutral }

/// Toss Design System Button
/// A highly customizable button component with Gym design language
class GymButton extends StatelessWidget {
  const GymButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = GymButtonSize.medium,
    this.style = GymButtonStyle.filled,
    this.purpose = GymButtonPurpose.primary,
    this.icon,
    this.loading = false,
    this.disabled = false,
    this.fullWidth = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final GymButtonSize size;
  final GymButtonStyle style;
  final GymButtonPurpose purpose;
  final IconData? icon;
  final bool loading;
  final bool disabled;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = _getHeight();
    final buttonStyle = _getButtonStyle();

    Widget button;

    if (style == GymButtonStyle.filled) {
      button = ElevatedButton(
        onPressed: _getOnPressed(),
        style: buttonStyle,
        child: _buildContent(),
      );
    } else if (style == GymButtonStyle.outlined) {
      button = OutlinedButton(
        onPressed: _getOnPressed(),
        style: buttonStyle,
        child: _buildContent(),
      );
    } else if (style == GymButtonStyle.ghost) {
      button = TextButton(
        onPressed: _getOnPressed(),
        style: buttonStyle,
        child: _buildContent(),
      );
    } else {
      button = TextButton(
        onPressed: _getOnPressed(),
        style: buttonStyle,
        child: _buildContent(),
      );
    }

    return SizedBox(
      height: buttonHeight,
      width: fullWidth ? double.infinity : null,
      child: button,
    );
  }

  VoidCallback? _getOnPressed() {
    if (disabled || loading) return null;
    return onPressed;
  }

  double _getHeight() {
    switch (size) {
      case GymButtonSize.small:
        return AppSpacing.buttonHeightSmall;
      case GymButtonSize.large:
        return AppSpacing.buttonHeightLarge;
      default:
        return AppSpacing.buttonHeightMedium;
    }
  }

  ButtonStyle _getButtonStyle() {
    final colors = _getColors();
    final textStyle = _getTextStyle();

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return style == GymButtonStyle.filled
              ? AppColors.grey200
              : Colors.transparent;
        }
        if (states.contains(WidgetState.pressed) && style == GymButtonStyle.filled) {
          return colors.pressed;
        }
        if (style == GymButtonStyle.ghost) {
          return AppColors.grey100;
        }
        return style == GymButtonStyle.filled ? colors.background : Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.textDisabled;
        }
        return colors.foreground;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (style == GymButtonStyle.filled) {
          return Colors.white.withOpacity(0.1);
        }
        return colors.foreground.withOpacity(0.08);
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (style == GymButtonStyle.outlined) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: AppColors.border, width: AppSpacing.borderThin);
          }
          return BorderSide(
            color: colors.background,
            width: AppSpacing.borderThin,
          );
        }
        return null;
      }),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            size == GymButtonSize.small
                ? AppSpacing.radiusMedium
                : AppSpacing.radiusLarge,
          ),
        ),
      ),
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(
          horizontal: size == GymButtonSize.small
              ? AppSpacing.lg
              : AppSpacing.xxl,
        ),
      ),
      textStyle: WidgetStateProperty.all(textStyle),
      elevation: WidgetStateProperty.all(AppSpacing.elevationNone),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case GymButtonSize.small:
        return AppTextStyles.buttonSmall;
      case GymButtonSize.large:
        return AppTextStyles.buttonLarge;
      default:
        return AppTextStyles.buttonMedium;
    }
  }

  ({Color background, Color foreground, Color pressed}) _getColors() {
    switch (purpose) {
      case GymButtonPurpose.neutral:
        return (
          background: AppColors.grey800,
          foreground: style == GymButtonStyle.filled
              ? AppColors.textInverse
              : AppColors.grey800,
          pressed: AppColors.grey900,
        );
      case GymButtonPurpose.success:
        return (
          background: AppColors.success,
          foreground: style == GymButtonStyle.filled
              ? AppColors.onSuccess
              : AppColors.success,
          pressed: AppColors.success,
        );
      case GymButtonPurpose.error:
        return (
          background: AppColors.error,
          foreground: style == GymButtonStyle.filled
              ? AppColors.onError
              : AppColors.error,
          pressed: AppColors.error,
        );
      case GymButtonPurpose.warning:
        return (
          background: AppColors.warning,
          foreground: style == GymButtonStyle.filled
              ? AppColors.onWarning
              : AppColors.warning,
          pressed: AppColors.warning,
        );
      case GymButtonPurpose.secondary:
        return (
          background: AppColors.grey100,
          foreground: AppColors.grey700,
          pressed: AppColors.grey200,
        );
      default:
        return (
          background: AppColors.primary,
          foreground: style == GymButtonStyle.filled
              ? AppColors.onPrimary
              : AppColors.primary,
          pressed: AppColors.primaryPressed,
        );
    }
  }

  Widget _buildContent() {
    if (loading) {
      return SizedBox(
        height: size == GymButtonSize.small ? 18.0 : 22.0,
        width: size == GymButtonSize.small ? 18.0 : 22.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            style == GymButtonStyle.filled
                ? _getColors().foreground
                : _getColors().background,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: size == GymButtonSize.small
                ? AppSpacing.iconSmall
                : AppSpacing.iconMedium,
          ),
          SizedBox(width: size == GymButtonSize.small ? AppSpacing.xs : AppSpacing.sm),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}
