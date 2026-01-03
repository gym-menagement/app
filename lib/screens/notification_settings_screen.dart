import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/gym_card.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../providers/notification_provider.dart';

/// 알림 설정 화면
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = notificationProvider.settings;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 전체 알림 설정
                GymCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.notifications_active,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '전체 알림',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '모든 알림을 받습니다',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: settings.enabled,
                            onChanged: (value) {
                              notificationProvider.toggleNotifications(value);
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 알림 유형별 설정
                Text(
                  '알림 유형',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                GymCard(
                  child: Column(
                    children: [
                      _buildNotificationToggle(
                        context: context,
                        icon: Icons.card_membership,
                        iconColor: AppColors.primary,
                        title: '이용권 만료 알림',
                        description: '이용권 만료 7일, 3일, 1일 전 알림',
                        value: settings.membershipExpiring,
                        enabled: settings.enabled,
                        onChanged: (value) {
                          notificationProvider
                              .toggleMembershipExpiringNotification(value);
                        },
                      ),
                      const Divider(height: 1),
                      _buildNotificationToggle(
                        context: context,
                        icon: Icons.fitness_center,
                        iconColor: AppColors.success,
                        title: '운동 독려 알림',
                        description: '3일 이상 미출석 시 알림',
                        value: settings.workoutReminder,
                        enabled: settings.enabled,
                        onChanged: (value) {
                          notificationProvider
                              .toggleWorkoutReminderNotification(value);
                        },
                      ),
                      const Divider(height: 1),
                      _buildNotificationToggle(
                        context: context,
                        icon: Icons.emoji_events,
                        iconColor: AppColors.warning,
                        title: '목표 달성 알림',
                        description: '주간 운동 목표 달성 시 알림',
                        value: settings.achievement,
                        enabled: settings.enabled,
                        onChanged: (value) {
                          notificationProvider
                              .toggleAchievementNotification(value);
                        },
                      ),
                      const Divider(height: 1),
                      _buildNotificationToggle(
                        context: context,
                        icon: Icons.campaign,
                        iconColor: AppColors.grey600,
                        title: '마케팅 알림',
                        description: '이벤트 및 프로모션 정보',
                        value: settings.marketing,
                        enabled: settings.enabled,
                        onChanged: (value) {
                          notificationProvider
                              .toggleMarketingNotification(value);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // FCM 토큰 정보 (디버그용)
                if (notificationProvider.fcmToken != null) ...[
                  Text(
                    '디바이스 정보',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GymCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FCM 토큰',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          notificationProvider.fcmToken!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey700,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),

                // 안내 문구
                GymCard(
                  color: AppColors.grey100,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.grey600,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '알림 설정은 언제든지 변경할 수 있습니다. 중요한 알림을 놓치지 않도록 이용권 만료 알림은 켜두는 것을 권장합니다.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey700,
                            height: 1.5,
                          ),
                        ),
                      ),
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

  Widget _buildNotificationToggle({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
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
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
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
                    color: enabled ? AppColors.grey900 : AppColors.grey400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: enabled ? AppColors.grey600 : AppColors.grey400,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
