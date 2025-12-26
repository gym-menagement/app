import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';

/// Toss Design System Card
/// A flexible card component with Toss design language
class TossCard extends StatelessWidget {
  const TossCard({
    super.key,
    this.child,
    this.onTap,
    this.padding,
    this.color,
    this.borderRadius,
    this.border,
    this.elevation = 0,
    this.shadowColor,
    this.margin,
  });

  final Widget? child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final double elevation;
  final Color? shadowColor;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusLarge);
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.lg);

    Widget content = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: color ?? AppColors.background,
        borderRadius: effectiveBorderRadius,
        border: border ?? Border.all(color: AppColors.border, width: AppSpacing.borderThin),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: (shadowColor ?? AppColors.grey900).withOpacity(0.08),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(
        padding: margin!,
        child: content,
      );
    }

    return content;
  }
}

/// Toss Card with a title and optional action
class TossCardWithTitle extends StatelessWidget {
  const TossCardWithTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.child,
    this.onTap,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget? child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return TossCard(
      onTap: onTap,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: AppSpacing.md),
            child!,
          ],
        ],
      ),
    );
  }
}
