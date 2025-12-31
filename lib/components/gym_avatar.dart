import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';

enum GymAvatarSize { small, medium, large, xlarge }

/// Gym Design System Avatar
/// A circular avatar component for displaying user profile images
class GymAvatar extends StatelessWidget {
  const GymAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = GymAvatarSize.medium,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.showBadge = false,
    this.badgeColor,
  });

  final String? imageUrl;
  final String? name;
  final GymAvatarSize size;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool showBadge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final avatarSize = _getSize();
    final fontSize = _getFontSize();
    final hasValidImage = imageUrl != null && imageUrl!.isNotEmpty;

    Widget avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.grey200,
        shape: BoxShape.circle,
        image: hasValidImage
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: !hasValidImage
          ? Center(
              child: Text(
                _getInitials(),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? AppColors.grey700,
                ),
              ),
            )
          : null,
    );

    if (showBadge) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: avatarSize * 0.3,
              height: avatarSize * 0.3,
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  double _getSize() {
    switch (size) {
      case GymAvatarSize.small:
        return AppSpacing.avatarSmall;
      case GymAvatarSize.large:
        return AppSpacing.avatarLarge;
      case GymAvatarSize.xlarge:
        return AppSpacing.avatarXLarge;
      default:
        return AppSpacing.avatarMedium;
    }
  }

  double _getFontSize() {
    switch (size) {
      case GymAvatarSize.small:
        return 12;
      case GymAvatarSize.large:
        return 20;
      case GymAvatarSize.xlarge:
        return 28;
      default:
        return 16;
    }
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) return '?';

    final words = name!.trim().split(' ');
    if (words.isEmpty) return '?';

    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

/// Avatar group component for displaying multiple avatars
class GymAvatarGroup extends StatelessWidget {
  const GymAvatarGroup({
    super.key,
    required this.avatars,
    this.size = GymAvatarSize.medium,
    this.max = 3,
    this.spacing = -8,
  });

  final List<GymAvatar> avatars;
  final GymAvatarSize size;
  final int max;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final displayAvatars = avatars.take(max).toList();
    final remainingCount = avatars.length - max;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...displayAvatars.asMap().entries.map((entry) {
          return Transform.translate(
            offset: Offset(entry.key * spacing, 0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background,
                  width: 2,
                ),
              ),
              child: entry.value,
            ),
          );
        }),
        if (remainingCount > 0)
          Transform.translate(
            offset: Offset(displayAvatars.length * spacing, 0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background,
                  width: 2,
                ),
              ),
              child: GymAvatar(
                name: '+$remainingCount',
                size: size,
                backgroundColor: AppColors.grey300,
                textColor: AppColors.grey700,
              ),
            ),
          ),
      ],
    );
  }
}
