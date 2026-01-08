import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../config/app_text_styles.dart';
import '../components/gym_components.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.0.0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '설정',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<SettingsProvider, AuthProvider>(
        builder: (context, settingsProvider, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 개인정보 관리 섹션
                _buildSectionTitle('개인정보 관리', Icons.person_outline),
                const SizedBox(height: AppSpacing.md),
                GymCard(
                  elevation: 2,
                  child: Column(
                    children: [
                      _buildMenuRow(
                        context,
                        Icons.edit_outlined,
                        '프로필 수정',
                        '이름, 전화번호, 주소 등 수정',
                        () {
                          Navigator.pushNamed(context, '/edit_profile');
                        },
                      ),
                      const GymDivider(),
                      _buildMenuRow(
                        context,
                        Icons.lock_outline,
                        '비밀번호 변경',
                        '새로운 비밀번호로 변경',
                        () {
                          Navigator.pushNamed(context, '/change_password');
                        },
                      ),
                      const GymDivider(),
                      _buildMenuRow(
                        context,
                        Icons.person_remove_outlined,
                        '회원 탈퇴',
                        '계정 및 모든 데이터 삭제',
                        () {
                          _showDeleteAccountDialog(context, authProvider);
                        },
                        textColor: AppColors.error,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 알림 설정 섹션
                _buildSectionTitle('알림 설정', Icons.notifications_outlined),
                const SizedBox(height: AppSpacing.md),
                GymCard(
                  elevation: 2,
                  child: Column(
                    children: [
                      _buildSwitchRow(
                        Icons.notifications_active_outlined,
                        '푸시 알림',
                        '모든 푸시 알림 수신',
                        settingsProvider.notificationsEnabled,
                        (value) {
                          settingsProvider.setNotificationsEnabled(value);
                        },
                      ),
                      const GymDivider(),
                      _buildMenuRow(
                        context,
                        Icons.tune_outlined,
                        '알림 상세 설정',
                        '알림 유형별 설정',
                        () {
                          Navigator.pushNamed(
                            context,
                            '/notification_settings',
                          );
                        },
                      ),
                      const GymDivider(),
                      _buildSwitchRow(
                        Icons.campaign_outlined,
                        '마케팅 알림',
                        '이벤트 및 프로모션 알림',
                        settingsProvider.marketingNotificationsEnabled,
                        (value) {
                          settingsProvider.setMarketingNotificationsEnabled(
                            value,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 앱 설정 섹션
                _buildSectionTitle('앱 설정', Icons.settings_outlined),
                const SizedBox(height: AppSpacing.md),
                GymCard(
                  elevation: 2,
                  child: Column(
                    children: [
                      _buildMenuRow(
                        context,
                        Icons.palette_outlined,
                        '테마 설정',
                        settingsProvider.theme.label,
                        () {
                          _showThemeDialog(context, settingsProvider);
                        },
                      ),
                      const GymDivider(),
                      _buildMenuRow(
                        context,
                        Icons.language_outlined,
                        '언어 설정',
                        settingsProvider.language.label,
                        () {
                          _showLanguageDialog(context, settingsProvider);
                        },
                      ),
                      const GymDivider(),
                      _buildMenuRow(
                        context,
                        Icons.cleaning_services_outlined,
                        '캐시 삭제',
                        '임시 파일 및 캐시 데이터 삭제',
                        () {
                          _showClearCacheDialog(context, settingsProvider);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 정보 섹션
                _buildSectionTitle('정보', Icons.info_outline),
                const SizedBox(height: AppSpacing.md),
                GymCard(
                  elevation: 2,
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.apps_outlined, '앱 버전', _appVersion),
                      const GymDivider(),
                      _buildMenuRow(
                        context,
                        Icons.description_outlined,
                        '이용약관',
                        '서비스 이용약관 확인',
                        () {
                          // TODO: 이용약관 화면으로 이동
                          GymSnackbar.show(
                            context: context,
                            message: '이용약관 화면 (준비 중)',
                          );
                        },
                      ),
                      const GymDivider(),
                      _buildMenuRow(
                        context,
                        Icons.privacy_tip_outlined,
                        '개인정보 처리방침',
                        '개인정보 보호 정책 확인',
                        () {
                          // TODO: 개인정보 처리방침 화면으로 이동
                          GymSnackbar.show(
                            context: context,
                            message: '개인정보 처리방침 화면 (준비 중)',
                          );
                        },
                      ),
                      const GymDivider(),
                      _buildMenuRow(
                        context,
                        Icons.help_outline,
                        '고객센터',
                        '문의 및 도움말',
                        () {
                          // TODO: 고객센터 화면으로 이동
                          GymSnackbar.show(
                            context: context,
                            message: '고객센터 화면 (준비 중)',
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
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
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMenuRow(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    VoidCallback onTap, {
    Color? textColor,
  }) {
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
                color: textColor ?? AppColors.grey600,
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
                      color: textColor,
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
            Icon(Icons.chevron_right, color: AppColors.grey400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(
    IconData icon,
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
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
            child: Icon(icon, size: 20, color: AppColors.grey600),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
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
            child: Icon(icon, size: 20, color: AppColors.grey600),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('테마 설정'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  AppTheme.values.map((theme) {
                    return RadioListTile<AppTheme>(
                      title: Text(theme.label),
                      value: theme,
                      groupValue: provider.theme,
                      onChanged: (value) {
                        if (value != null) {
                          provider.setTheme(value);
                          Navigator.pop(context);
                        }
                      },
                      activeColor: AppColors.primary,
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
            ],
          ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('언어 설정'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  AppLanguage.values.map((language) {
                    return RadioListTile<AppLanguage>(
                      title: Text(language.label),
                      value: language,
                      groupValue: provider.language,
                      onChanged: (value) {
                        if (value != null) {
                          provider.setLanguage(value);
                          Navigator.pop(context);
                          GymSnackbar.show(
                            context: context,
                            message: '언어가 변경되었습니다. 앱을 재시작하면 적용됩니다.',
                          );
                        }
                      },
                      activeColor: AppColors.primary,
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
            ],
          ),
    );
  }

  void _showClearCacheDialog(
    BuildContext context,
    SettingsProvider provider,
  ) async {
    final confirmed = await GymDialog.showConfirm(
      context: context,
      title: '캐시 삭제',
      message: '임시 파일 및 캐시 데이터를 삭제하시겠습니까?',
      confirmText: '삭제',
      cancelText: '취소',
    );

    if (confirmed == true && context.mounted) {
      showLoadingDialog(context: context, message: '캐시 삭제 중...');

      final success = await provider.clearCache();

      if (context.mounted) {
        Navigator.pop(context); // 로딩 다이얼로그 닫기

        if (success) {
          GymSnackbar.show(
            context: context,
            message: '캐시가 삭제되었습니다',
            type: GymSnackbarType.success,
          );
        } else {
          GymSnackbar.show(
            context: context,
            message: '캐시 삭제에 실패했습니다',
            type: GymSnackbarType.error,
          );
        }
      }
    }
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final confirmed = await GymDialog.showConfirm(
      context: context,
      title: '회원 탈퇴',
      message:
          '정말로 탈퇴하시겠습니까?\n\n모든 데이터가 삭제되며 복구할 수 없습니다.\n이용권, 결제 내역, 운동 기록 등 모든 정보가 삭제됩니다.',
      confirmText: '탈퇴',
      cancelText: '취소',
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      // 한 번 더 확인
      final finalConfirmed = await GymDialog.showConfirm(
        context: context,
        title: '최종 확인',
        message: '정말로 탈퇴하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
        confirmText: '탈퇴',
        cancelText: '취소',
        isDangerous: true,
      );

      if (finalConfirmed == true && context.mounted) {
        showLoadingDialog(context: context, message: '회원 탈퇴 처리 중...');

        // TODO: 회원 탈퇴 API 호출
        await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션

        if (context.mounted) {
          Navigator.pop(context); // 로딩 다이얼로그 닫기

          // 로그아웃 및 로그인 화면으로 이동
          await authProvider.logout();

          if (context.mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);

            GymSnackbar.show(
              context: context,
              message: '회원 탈퇴가 완료되었습니다',
              type: GymSnackbarType.success,
            );
          }
        }
      }
    }
  }
}
