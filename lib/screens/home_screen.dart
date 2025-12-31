import 'package:app/screens/membership_screen.dart';
import 'package:flutter/material.dart';
import '../components/gym_bottom_navigation.dart';
import '../config/app_colors.dart';
import 'profile_screen.dart';
import 'gym_search_screen.dart';
import 'workout_screen.dart';

/// Main home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // 마이 페이지를 기본으로 표시

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
      const WorkoutScreen(), // 운동 기록 화면
      const GymSearchScreen(), // 체육관 찾기 화면
      const MembershipScreen(), // 멤버십 화면
      const ProfileScreen(), // 마이 페이지
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
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
