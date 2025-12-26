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
      appBar: AppBar(
        title: const Text('마이페이지'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // 프로필 헤더
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.xxxl,
                  ),
                  child: Column(
                    children: [
                      // 프로필 이미지
                      GymAvatar(
                        name: user.name,
                        imageUrl: user.image,
                        size: GymAvatarSize.xlarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // 이름
                      Text(
                        user.name,
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // 이메일
                      Text(
                        user.email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 사용자 정보 카드
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('기본 정보', style: AppTextStyles.h4),
                      const SizedBox(height: AppSpacing.md),
                      GymCard(
                        child: Column(
                          children: [
                            _buildInfoRow('아이디', user.loginid),
                            const GymDivider(),
                            _buildInfoRow('이름', user.name),
                            const GymDivider(),
                            _buildInfoRow('이메일', user.email),
                            const GymDivider(),
                            _buildInfoRow('전화번호', user.tel),
                            if (user.address != null &&
                                user.address!.isNotEmpty) ...[
                              const GymDivider(),
                              _buildInfoRow('주소', user.address!),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // 계정 정보
                      Text('계정 정보', style: AppTextStyles.h4),
                      const SizedBox(height: AppSpacing.md),
                      GymCard(
                        child: Column(
                          children: [
                            _buildInfoRow(
                              '회원 등급',
                              user.extra['level']?.toString() ?? '일반',
                            ),
                            const GymDivider(),
                            _buildInfoRow('가입일', _formatDate(user.date)),
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
                      ),

                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey900,
              ),
            ),
          ),
        ],
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
