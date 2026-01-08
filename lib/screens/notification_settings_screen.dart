import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/gym_card.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../model/notification_setting.dart';
import '../model/notification_api.dart';
import '../providers/auth_provider.dart';

/// 알림 설정 화면 (백엔드 API 연동)
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  NotificationSetting? _settings;

  // 방해 금지 시간 설정
  TimeOfDay? _quietStart;
  TimeOfDay? _quietEnd;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
        return;
      }

      final settings = await NotificationApi.getUserSettings(userId);

      setState(() {
        _settings = settings ?? NotificationSetting(userId: userId);

        // 방해 금지 시간 파싱
        if (_settings?.quietHoursStart != null) {
          final parts = _settings!.quietHoursStart!.split(':');
          _quietStart = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        if (_settings?.quietHoursEnd != null) {
          final parts = _settings!.quietHoursEnd!.split(':');
          _quietEnd = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }

        _isLoading = false;
      });

      // 설정이 없으면 생성
      if (settings == null) {
        await NotificationApi.createUserSettings(userId);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정을 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _toggleAll(bool enabled) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;

    final success = await NotificationApi.toggleAllNotifications(userId, enabled);
    if (success) {
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(enabled ? '모든 알림이 켜졌습니다' : '모든 알림이 꺼졌습니다')),
        );
      }
    }
  }

  Future<void> _toggleType({
    bool? membershipExpiry,
    bool? membershipNearExpiry,
    bool? attendanceEncourage,
    bool? gymAnnouncement,
    bool? systemNotice,
    bool? paymentConfirm,
    bool? pauseExpiry,
    bool? weeklyGoalAchieved,
    bool? personalRecord,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;

    final success = await NotificationApi.updateNotificationType(
      userId,
      membershipExpiry: membershipExpiry,
      membershipNearExpiry: membershipNearExpiry,
      attendanceEncourage: attendanceEncourage,
      gymAnnouncement: gymAnnouncement,
      systemNotice: systemNotice,
      paymentConfirm: paymentConfirm,
      pauseExpiry: pauseExpiry,
      weeklyGoalAchieved: weeklyGoalAchieved,
      personalRecord: personalRecord,
    );

    if (success) {
      await _loadSettings();
    }
  }

  Future<void> _updateQuietHours() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId == null || _settings == null) return;

    final enabled = _settings!.quietHoursEnabled.isEnabled;

    if (enabled && (_quietStart == null || _quietEnd == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시작 시간과 종료 시간을 모두 설정해주세요')),
      );
      return;
    }

    final success = await NotificationApi.updateQuietHours(
      userId,
      enabled: enabled,
      startTime: _quietStart != null
        ? '${_quietStart!.hour.toString().padLeft(2, '0')}:${_quietStart!.minute.toString().padLeft(2, '0')}'
        : null,
      endTime: _quietEnd != null
        ? '${_quietEnd!.hour.toString().padLeft(2, '0')}:${_quietEnd!.minute.toString().padLeft(2, '0')}'
        : null,
    );

    if (success && mounted) {
      await _loadSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(enabled ? '방해 금지 시간이 설정되었습니다' : '방해 금지 시간이 해제되었습니다')),
      );
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: (isStart ? _quietStart : _quietEnd) ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        if (isStart) {
          _quietStart = time;
        } else {
          _quietEnd = time;
        }
      });
      await _updateQuietHours();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _settings == null
              ? const Center(child: Text('설정을 불러올 수 없습니다'))
              : RefreshIndicator(
                  onRefresh: _loadSettings,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 전체 알림 ON/OFF
                        GymCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                ),
                                child: const Icon(
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
                                      _settings!.enabled.isEnabled ? '모든 알림을 받습니다' : '모든 알림이 꺼져 있습니다',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.grey600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _settings!.enabled.isEnabled,
                                onChanged: _toggleAll,
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // 알림 타입별 설정
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
                                icon: Icons.card_membership,
                                iconColor: AppColors.error,
                                title: '이용권 만료 알림',
                                description: '이용권이 만료되었을 때',
                                value: _settings!.membershipExpiry.isEnabled,
                                onChanged: (v) => _toggleType(membershipExpiry: v),
                              ),
                              const Divider(height: 1),
                              _buildNotificationToggle(
                                icon: Icons.card_giftcard,
                                iconColor: AppColors.warning,
                                title: '이용권 만료 임박 알림',
                                description: '이용권 만료 7일, 3일, 1일 전',
                                value: _settings!.membershipNearExpiry.isEnabled,
                                onChanged: (v) => _toggleType(membershipNearExpiry: v),
                              ),
                              const Divider(height: 1),
                              _buildNotificationToggle(
                                icon: Icons.fitness_center,
                                iconColor: AppColors.success,
                                title: '출석 독려 알림',
                                description: '3일 이상 미출석 시',
                                value: _settings!.attendanceEncourage.isEnabled,
                                onChanged: (v) => _toggleType(attendanceEncourage: v),
                              ),
                              const Divider(height: 1),
                              _buildNotificationToggle(
                                icon: Icons.campaign,
                                iconColor: AppColors.info,
                                title: '체육관 공지',
                                description: '체육관의 공지사항 및 이벤트',
                                value: _settings!.gymAnnouncement.isEnabled,
                                onChanged: (v) => _toggleType(gymAnnouncement: v),
                              ),
                              const Divider(height: 1),
                              _buildNotificationToggle(
                                icon: Icons.info_outline,
                                iconColor: AppColors.grey600,
                                title: '시스템 공지',
                                description: '앱 업데이트 및 중요 공지',
                                value: _settings!.systemNotice.isEnabled,
                                onChanged: (v) => _toggleType(systemNotice: v),
                              ),
                              const Divider(height: 1),
                              _buildNotificationToggle(
                                icon: Icons.payment,
                                iconColor: AppColors.primary,
                                title: '결제 확인 알림',
                                description: '결제 완료 및 영수증',
                                value: _settings!.paymentConfirm.isEnabled,
                                onChanged: (v) => _toggleType(paymentConfirm: v),
                              ),
                              const Divider(height: 1),
                              _buildNotificationToggle(
                                icon: Icons.pause_circle_outline,
                                iconColor: AppColors.warning,
                                title: '일시정지 만료 알림',
                                description: '일시정지 기간이 종료될 때',
                                value: _settings!.pauseExpiry.isEnabled,
                                onChanged: (v) => _toggleType(pauseExpiry: v),
                              ),
                              const Divider(height: 1),
                              _buildNotificationToggle(
                                icon: Icons.emoji_events,
                                iconColor: AppColors.success,
                                title: '주간 목표 달성 알림',
                                description: '주간 운동 목표를 달성했을 때',
                                value: _settings!.weeklyGoalAchieved.isEnabled,
                                onChanged: (v) => _toggleType(weeklyGoalAchieved: v),
                              ),
                              const Divider(height: 1),
                              _buildNotificationToggle(
                                icon: Icons.military_tech,
                                iconColor: Color(0xFFFFD700),
                                title: '개인 기록 갱신 알림',
                                description: '개인 최고 기록을 경신했을 때',
                                value: _settings!.personalRecord.isEnabled,
                                onChanged: (v) => _toggleType(personalRecord: v),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // 방해 금지 시간
                        Text(
                          '방해 금지 시간',
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        GymCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '방해 금지 모드',
                                          style: AppTextStyles.bodyLarge.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '설정한 시간에는 알림을 받지 않습니다',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.grey600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _settings!.quietHoursEnabled.isEnabled,
                                    onChanged: (v) async {
                                      setState(() {
                                        _settings = NotificationSetting.fromJson({
                                          ..._settings!.toJson(),
                                          'quietHoursEnabled': v ? 0 : 1,
                                        });
                                      });
                                      await _updateQuietHours();
                                    },
                                    activeColor: AppColors.primary,
                                  ),
                                ],
                              ),
                              if (_settings!.quietHoursEnabled.isEnabled) ...[
                                const SizedBox(height: AppSpacing.md),
                                const Divider(),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '시작 시간',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.grey600,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          InkWell(
                                            onTap: () => _selectTime(true),
                                            child: Container(
                                              padding: const EdgeInsets.all(AppSpacing.md),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: AppColors.grey300),
                                                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                              ),
                                              child: Text(
                                                _quietStart != null
                                                    ? _quietStart!.format(context)
                                                    : '시간 선택',
                                                style: AppTextStyles.bodyMedium,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    const Icon(Icons.arrow_forward, size: 16, color: AppColors.grey400),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '종료 시간',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.grey600,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          InkWell(
                                            onTap: () => _selectTime(false),
                                            child: Container(
                                              padding: const EdgeInsets.all(AppSpacing.md),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: AppColors.grey300),
                                                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                              ),
                                              child: Text(
                                                _quietEnd != null
                                                    ? _quietEnd!.format(context)
                                                    : '시간 선택',
                                                style: AppTextStyles.bodyMedium,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // 안내 문구
                        GymCard(
                          color: AppColors.grey100,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
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
                  ),
                ),
    );
  }

  Widget _buildNotificationToggle({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final enabled = _settings!.enabled.isEnabled;

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
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
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
