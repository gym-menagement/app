import 'dart:io';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';

/// Toss-style bottom navigation item
class GymBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Widget? badge;

  const GymBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
  });
}

/// Toss-style bottom navigation bar
/// Adapts to platform-specific design (iOS/Android)
class GymBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final List<GymBottomNavItem> items;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const GymBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    // iOS uses a different style with haptic feedback
    final isIOS = Platform.isIOS;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.grey200,
            width: isIOS ? 0.5 : 1.0,
          ),
        ),
        boxShadow: isIOS
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _buildNavItem(
                context,
                items[index],
                index == currentIndex,
                index,
                isIOS,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    GymBottomNavItem item,
    bool isSelected,
    int index,
    bool isIOS,
  ) {
    final color = isSelected
        ? (selectedColor ?? AppColors.primary)
        : (unselectedColor ?? AppColors.grey500);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          splashColor: isIOS ? Colors.transparent : AppColors.primary.withOpacity(0.1),
          highlightColor: isIOS ? Colors.transparent : AppColors.primary.withOpacity(0.05),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: isIOS ? AppSpacing.xs : AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isSelected && item.activeIcon != null ? item.activeIcon : item.icon,
                        key: ValueKey(isSelected),
                        color: color,
                        size: isIOS ? 26 : 24,
                      ),
                    ),
                    if (item.badge != null)
                      Positioned(
                        right: -8,
                        top: -4,
                        child: item.badge!,
                      ),
                  ],
                ),
                SizedBox(height: isIOS ? 2 : 4),
                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isIOS ? 10 : 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                    height: 1.2,
                  ),
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge for bottom navigation item
class GymNavBadge extends StatelessWidget {
  final String? count;
  final bool showDot;
  final Color? backgroundColor;
  final Color? textColor;

  const GymNavBadge({
    super.key,
    this.count,
    this.showDot = false,
    this.backgroundColor,
    this.textColor,
  });

  const GymNavBadge.dot({
    super.key,
    this.backgroundColor,
  })  : count = null,
        showDot = true,
        textColor = null;

  const GymNavBadge.count({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
  }) : showDot = false;

  @override
  Widget build(BuildContext context) {
    if (showDot) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.error,
          shape: BoxShape.circle,
        ),
      );
    }

    if (count == null || count!.isEmpty || count == '0') {
      return const SizedBox.shrink();
    }

    final displayCount = int.tryParse(count!) ?? 0;
    final displayText = displayCount > 99 ? '99+' : count!;

    return Container(
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.error,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor ?? Colors.white,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Example usage in a screen
class GymBottomNavigationExample extends StatefulWidget {
  const GymBottomNavigationExample({super.key});

  @override
  State<GymBottomNavigationExample> createState() => _GymBottomNavigationExampleState();
}

class _GymBottomNavigationExampleState extends State<GymBottomNavigationExample> {
  int _currentIndex = 0;

  final List<GymBottomNavItem> _navItems = [
    const GymBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: '홈',
    ),
    const GymBottomNavItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: '찾기',
    ),
    GymBottomNavItem(
      icon: Icons.card_membership_outlined,
      activeIcon: Icons.card_membership,
      label: '멤버십',
      badge: GymNavBadge.dot(),
    ),
    GymBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: '마이',
      badge: GymNavBadge.count(count: '3'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bottom Navigation Example'),
      ),
      body: Center(
        child: Text(
          'Current Index: $_currentIndex',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: GymBottomNavigation(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
