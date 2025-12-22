import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';

enum GymButtonSize { small, medium, large }
enum GymButtonStyle { filled, outlined, text }
enum GymButtonPurpose { primary, secondary, success, error, warning }

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
        return 40.0;
      case GymButtonSize.large:
        return 56.0;
      default:
        return AppSpacing.buttonHeight;
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
        return style == GymButtonStyle.filled ? colors.background : Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.grey400;
        }
        return colors.foreground;
      }),
      overlayColor: WidgetStateProperty.all(colors.foreground.withOpacity(0.1)),
      side: WidgetStateProperty.resolveWith((states) {
        if (style == GymButtonStyle.outlined) {
          if (states.contains(WidgetState.disabled)) {
            return const BorderSide(color: AppColors.grey300);
          }
          return BorderSide(color: colors.foreground, width: 1.5);
        }
        return null;
      }),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            size == GymButtonSize.small
                ? AppSpacing.radiusSmall
                : AppSpacing.radiusMedium,
          ),
        ),
      ),
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(
          horizontal: size == GymButtonSize.small
              ? AppSpacing.md
              : AppSpacing.lg,
        ),
      ),
      textStyle: WidgetStateProperty.all(textStyle),
      elevation: WidgetStateProperty.resolveWith((states) {
        if (style == GymButtonStyle.filled && !states.contains(WidgetState.disabled)) {
          return 2.0;
        }
        return 0.0;
      }),
    );
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case GymButtonSize.small:
        return AppTextStyles.labelMedium;
      case GymButtonSize.large:
        return AppTextStyles.titleMedium;
      default:
        return AppTextStyles.button;
    }
  }

  ({Color background, Color foreground}) _getColors() {
    switch (purpose) {
      case GymButtonPurpose.secondary:
        return (
          background: AppColors.secondary,
          foreground: style == GymButtonStyle.filled
              ? AppColors.onSecondary
              : AppColors.secondary,
        );
      case GymButtonPurpose.success:
        return (
          background: AppColors.success,
          foreground: style == GymButtonStyle.filled
              ? AppColors.onSuccess
              : AppColors.success,
        );
      case GymButtonPurpose.error:
        return (
          background: AppColors.error,
          foreground: style == GymButtonStyle.filled
              ? AppColors.onError
              : AppColors.error,
        );
      case GymButtonPurpose.warning:
        return (
          background: AppColors.warning,
          foreground: style == GymButtonStyle.filled
              ? AppColors.onWarning
              : AppColors.warning,
        );
      default:
        return (
          background: AppColors.primary,
          foreground: style == GymButtonStyle.filled
              ? AppColors.onPrimary
              : AppColors.primary,
        );
    }
  }

  Widget _buildContent() {
    if (loading) {
      return SizedBox(
        height: size == GymButtonSize.small ? 16.0 : 20.0,
        width: size == GymButtonSize.small ? 16.0 : 20.0,
        child: CircularProgressIndicator(
          strokeWidth: 2,
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
          Icon(icon, size: size == GymButtonSize.small ? 16.0 : 20.0),
          const SizedBox(width: AppSpacing.sm),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}
