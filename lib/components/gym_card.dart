import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../config/app_text_styles.dart';
import '../model/gym.dart';

/// Gym Design System Card
/// A flexible card component with Gym design language
class GymCard extends StatelessWidget {
  const GymCard({
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

/// Gym Card with a title and optional action
class GymCardWithTitle extends StatelessWidget {
  const GymCardWithTitle({
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
    return GymCard(
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

/// Gym List Card - 체육관 목록에서 사용하는 카드
class GymListCard extends StatelessWidget {
  const GymListCard({
    super.key,
    required this.gym,
    this.isFavorite = false,
    this.distance,
    this.showDistance = false,
    this.onTap,
    this.onFavorite,
  });

  final Gym gym;
  final bool isFavorite;
  final double? distance;
  final bool showDistance;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return GymCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - 이름과 즐겨찾기
          Row(
            children: [
              Expanded(
                child: Text(
                  gym.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onFavorite != null)
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.error : AppColors.grey400,
                  ),
                  onPressed: onFavorite,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // 주소
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.grey500,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  gym.address,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // 전화번호
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 16,
                color: AppColors.grey500,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                gym.tel,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),

          // 편의시설
          if (gym.extra['facilities'] != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: (gym.extra['facilities'] as List)
                  .take(4)
                  .map((facility) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSmall,
                          ),
                        ),
                        child: Text(
                          facility.toString(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontSize: 11,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],

          // 거리 정보
          if (showDistance && distance != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.directions_walk,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${distance!.toStringAsFixed(1)}km',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
