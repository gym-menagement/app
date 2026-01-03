import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../config/app_text_styles.dart';
import '../components/gym_components.dart';

/// 사용자 프로필 화면
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
          }

          return CustomScrollView(
            slivers: [
              // AppBar with Profile Header
              SliverAppBar(
                expandedHeight: 220,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                stretch: true,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    // AppBar가 축소되었는지 확인
                    final isCollapsed = constraints.maxHeight <= kToolbarHeight + 50;

                    return FlexibleSpaceBar(
                      centerTitle: true,
                      title: AnimatedOpacity(
                        opacity: isCollapsed ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          '마이페이지',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: AppSpacing.xl),
                              // 프로필 이미지
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: GymAvatar(
                                  name: user.name,
                                  imageUrl: user.image,
                                  size: GymAvatarSize.xlarge,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              // 이름
                              Text(
                                user.name,
                                style: AppTextStyles.h2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              // 이메일
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.email,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 콘텐츠
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: AppSpacing.md),

                    // 기본 정보 섹션
                    _buildSectionTitle('기본 정보', Icons.person_outline),
                    const SizedBox(height: AppSpacing.md),
                    GymCard(
                      elevation: 2,
                      child: Column(
                        children: [
                          _buildModernInfoRow(
                            Icons.account_circle_outlined,
                            '아이디',
                            user.loginid,
                          ),
                          const GymDivider(),
                          _buildModernInfoRow(
                            Icons.badge_outlined,
                            '이름',
                            user.name,
                          ),
                          const GymDivider(),
                          _buildModernInfoRow(
                            Icons.email_outlined,
                            '이메일',
                            user.email,
                          ),
                          const GymDivider(),
                          _buildModernInfoRow(
                            Icons.phone_outlined,
                            '전화번호',
                            user.tel,
                          ),
                          if (user.address.isNotEmpty) ...[
                            const GymDivider(),
                            _buildModernInfoRow(
                              Icons.location_on_outlined,
                              '주소',
                              user.address,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 계정 정보 섹션
                    _buildSectionTitle('계정 정보', Icons.settings_outlined),
                    const SizedBox(height: AppSpacing.md),
                    GymCard(
                      elevation: 2,
                      child: Column(
                        children: [
                          _buildModernInfoRow(
                            Icons.verified_user_outlined,
                            '회원 등급',
                            user.extra['level']?.toString() ?? '일반',
                            valueColor: AppColors.primary,
                          ),
                          const GymDivider(),
                          _buildModernInfoRow(
                            Icons.calendar_today_outlined,
                            '가입일',
                            _formatDate(user.date),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 설정 섹션
                    _buildSectionTitle('설정', Icons.tune_outlined),
                    const SizedBox(height: AppSpacing.md),
                    GymCard(
                      elevation: 2,
                      child: Column(
                        children: [
                          _buildMenuRow(
                            context,
                            Icons.notifications_outlined,
                            '알림 설정',
                            '푸시 알림 및 알림 유형 설정',
                            () {
                              Navigator.pushNamed(context, '/notification_settings');
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxxl),

                    // 로그아웃 버튼
                    GymButton(
                      text: '로그아웃',
                      onPressed: () => _handleLogout(context, authProvider),
                      style: GymButtonStyle.outlined,
                      purpose: GymButtonPurpose.error,
                      fullWidth: true,
                      size: GymButtonSize.large,
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildModernInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: valueColor ?? AppColors.grey900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.grey400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _handleLogout(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final confirmed = await GymDialog.showConfirm(
      context: context,
      title: '로그아웃',
      message: '로그아웃 하시겠습니까?',
      confirmText: '로그아웃',
      cancelText: '취소',
    );

    if (confirmed == true && context.mounted) {
      await authProvider.logout();

      if (context.mounted) {
        // 로그인 화면으로 이동 (모든 스택 제거)
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}
