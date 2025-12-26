import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';

/// Gym Design System Divider
/// A horizontal or vertical divider with Gym design language
class GymDivider extends StatelessWidget {
  const GymDivider({
    super.key,
    this.height,
    this.thickness,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
  }) : direction = Axis.horizontal;

  const GymDivider.vertical({
    super.key,
    this.height,
    this.thickness,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
  }) : direction = Axis.vertical;

  final double? height;
  final double? thickness;
  final Color? color;
  final double indent;
  final double endIndent;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final effectiveThickness = thickness ?? AppSpacing.dividerThickness;
    final effectiveColor = color ?? AppColors.divider;

    if (direction == Axis.vertical) {
      return Container(
        width: effectiveThickness,
        height: height,
        margin: EdgeInsets.only(top: indent, bottom: endIndent),
        color: effectiveColor,
      );
    }

    return Container(
      height: effectiveThickness,
      width: height,
      margin: EdgeInsets.only(left: indent, right: endIndent),
      color: effectiveColor,
    );
  }
}

/// Gym Design System Divider with text
class GymDividerWithText extends StatelessWidget {
  const GymDividerWithText({
    super.key,
    required this.text,
    this.color,
    this.textStyle,
    this.thickness,
    this.spacing = AppSpacing.md,
  });

  final String text;
  final Color? color;
  final TextStyle? textStyle;
  final double? thickness;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.divider;
    final effectiveTextStyle = textStyle ??
        const TextStyle(
          fontSize: 13,
          color: AppColors.textTertiary,
        );

    return Row(
      children: [
        Expanded(
          child: GymDivider(
            color: effectiveColor,
            thickness: thickness,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: Text(text, style: effectiveTextStyle),
        ),
        Expanded(
          child: GymDivider(
            color: effectiveColor,
            thickness: thickness,
          ),
        ),
      ],
    );
  }
}
