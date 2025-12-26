import 'package:flutter/material.dart';
import '../components/gym_bottom_navigation.dart';
import '../config/app_colors.dart';
import 'profile_screen.dart';
import 'gym_search_screen.dart';

/// Main home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 3; // 마이 페이지를 기본으로 표시

  // 네비게이션 아이템들
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
    const GymBottomNavItem(
      icon: Icons.card_membership_outlined,
      activeIcon: Icons.card_membership,
      label: '멤버십',
    ),
    const GymBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: '마이',
    ),
  ];

  // 각 탭에 해당하는 화면들
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildPlaceholderScreen('홈', Icons.home),
      const GymSearchScreen(), // 체육관 찾기 화면
      _buildPlaceholderScreen('멤버십', Icons.card_membership),
      const ProfileScreen(), // 마이 페이지
    ];
  }

  Widget _buildPlaceholderScreen(String title, IconData icon) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(
              '$title 화면',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '준비 중입니다',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
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
