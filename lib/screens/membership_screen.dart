import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../components/gym_layout.dart';
import '../components/gym_button.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../model/membership.dart';
import '../model/gym.dart';

enum MembershipStatus {
  active,
  paused,
  expired,
  cancelled,
}

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  bool _isLoading = true;
  Membership? _activeMembership;
  Gym? _gym;
  List<Membership> _membershipHistory = [];
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadMembershipData();
  }

  Future<void> _loadMembershipData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - active membership (all extended fields in extra)
      final mockActiveMembership = Membership(
        id: 1,
        user: 1,
        gym: 1,
        date: DateTime.now().toString(),
        extra: {
          'plan': '6개월 이용권',
          'startDate': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          'endDate': DateTime.now().add(const Duration(days: 150)).toIso8601String(),
          'price': 480000,
          'status': 'active',
          'features': ['무제한 이용', 'PT 5회', '락커 제공', '운동복 제공'],
          'totalVisits': 45,
          'pauseAvailable': true,
        },
      );

      // Mock gym data
      final mockGym = Gym(
        id: 1,
        name: '강남 피트니스',
        address: '서울 강남구 테헤란로 123',
        tel: '02-1234-5678',
        user: 1,
        date: DateTime.now().toString(),
        extra: {},
      );

      // Mock membership history
      final mockHistory = [
        Membership(
          id: 2,
          user: 1,
          gym: 1,
          date: DateTime.now().subtract(const Duration(days: 210)).toString(),
          extra: {
            'plan': '3개월 이용권',
            'startDate': DateTime.now().subtract(const Duration(days: 210)).toIso8601String(),
            'endDate': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
            'price': 270000,
            'status': 'expired',
          },
        ),
      ];

      // Mock statistics
      final mockStats = {
        'totalVisitsThisMonth': 12,
        'averageVisitsPerWeek': 3.5,
        'currentStreak': 5,
        'longestStreak': 14,
      };

      if (mounted) {
        setState(() {
          _activeMembership = mockActiveMembership;
          _gym = mockGym;
          _membershipHistory = mockHistory;
          _stats = mockStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 로드 실패: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  DateTime _getStartDate(Membership membership) {
    final startDateStr = membership.extra['startDate'] as String?;
    return startDateStr != null ? DateTime.parse(startDateStr) : DateTime.now();
  }

  DateTime _getEndDate(Membership membership) {
    final endDateStr = membership.extra['endDate'] as String?;
    return endDateStr != null ? DateTime.parse(endDateStr) : DateTime.now();
  }

  String _getPlan(Membership membership) {
    return membership.extra['plan'] as String? ?? '';
  }

  MembershipStatus _getStatus(Membership membership) {
    final statusStr = membership.extra['status'] as String? ?? 'active';
    return MembershipStatus.values.firstWhere(
      (e) => e.toString() == 'MembershipStatus.$statusStr',
      orElse: () => MembershipStatus.active,
    );
  }

  int _getRemainingDays() {
    if (_activeMembership == null) return 0;
    return _getEndDate(_activeMembership!).difference(DateTime.now()).inDays;
  }

  Color _getStatusColor() {
    final remainingDays = _getRemainingDays();
    if (remainingDays <= 0) return AppColors.grey500;
    if (remainingDays <= 7) return AppColors.warning;
    return AppColors.primary;
  }

  String _getQRData() {
    if (_activeMembership == null || _gym == null) return '';

    final data = {
      'membershipId': _activeMembership!.id,
      'userId': _activeMembership!.user,
      'gymId': _gym!.id,
      'validUntil': _getEndDate(_activeMembership!).toIso8601String(),
      'signature': 'mock_signature_${_activeMembership!.id}',
    };

    return jsonEncode(data);
  }

  void _showQRCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '체육관 입장 QR',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _gym?.name ?? '',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.grey700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: QrImageView(
                  data: _getQRData(),
                  version: QrVersions.auto,
                  size: 250.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '출입 시 이 QR코드를 스캔해주세요',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              GymButton(
                text: '닫기',
                onPressed: () => Navigator.pop(context),
                style: GymButtonStyle.outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleExtendMembership() {
    if (_gym == null) return;

    Navigator.pushNamed(
      context,
      '/payment',
      arguments: _gym,
    ).then((_) => _loadMembershipData());
  }

  void _handlePauseMembership() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이용권 일시정지'),
        content: const Text(
          '이용권을 일시정지하시겠습니까?\n정지 기간만큼 이용 기간이 연장됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement pause API
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('일시정지 신청이 완료되었습니다')),
              );
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GymLayout(
      title: '내 이용권',
      scrollable: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activeMembership == null
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 120,
              color: AppColors.grey400,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '활성 이용권이 없습니다',
              style: AppTextStyles.h3.copyWith(color: AppColors.grey700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '체육관을 검색하고\n이용권을 구매해보세요',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            GymButton(
              text: '체육관 검색하기',
              onPressed: () => Navigator.pushNamed(context, '/gym_search'),
              size: GymButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildActiveMembershipCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildUsageProgress(),
          const SizedBox(height: AppSpacing.lg),
          _buildActionButtons(),
          const SizedBox(height: AppSpacing.xl),
          _buildStatistics(),
          const SizedBox(height: AppSpacing.xl),
          _buildHistorySection(),
        ],
      ),
    );
  }

  Widget _buildActiveMembershipCard() {
    final remainingDays = _getRemainingDays();
    final statusColor = _getStatusColor();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor,
            statusColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showQRCodeDialog,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _gym?.name ?? '',
                            style: AppTextStyles.h3.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _getPlan(_activeMembership!),
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSmall),
                      ),
                      child: Text(
                        '이용중',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateInfo(
                        '시작일',
                        _formatDate(_getStartDate(_activeMembership!)),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withOpacity(0.3),
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                    ),
                    Expanded(
                      child: _buildDateInfo(
                        '종료일',
                        _formatDate(_getEndDate(_activeMembership!)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '남은 기간',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$remainingDays일',
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'QR 코드 보기',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildUsageProgress() {
    final totalDays = _getEndDate(_activeMembership!)
        .difference(_getStartDate(_activeMembership!))
        .inDays;
    final usedDays =
        DateTime.now().difference(_getStartDate(_activeMembership!)).inDays;
    final progress = (usedDays / totalDays).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '이용 진행률',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$usedDays일 사용 / $totalDays일',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final pauseAvailable =
        _activeMembership?.extra['pauseAvailable'] as bool? ?? false;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GymButton(
            text: '연장하기',
            onPressed: _handleExtendMembership,
            size: GymButtonSize.large,
          ),
        ),
        if (pauseAvailable) ...[
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: GymButton(
              text: '일시정지',
              onPressed: _handlePauseMembership,
              style: GymButtonStyle.outlined,
              size: GymButtonSize.large,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이용 통계',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.calendar_month,
                  label: '이번 달 방문',
                  value: '${_stats?['totalVisitsThisMonth'] ?? 0}회',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  label: '주평균 방문',
                  value: '${_stats?['averageVisitsPerWeek'] ?? 0}회',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  label: '현재 연속 방문',
                  value: '${_stats?['currentStreak'] ?? 0}일',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.emoji_events,
                  label: '최장 연속 방문',
                  value: '${_stats?['longestStreak'] ?? 0}일',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_membershipHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이용권 내역',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._membershipHistory.map((membership) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildHistoryCard(membership),
          );
        }),
      ],
    );
  }

  Widget _buildHistoryCard(Membership membership) {
    final status = _getStatus(membership);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _gym?.name ?? '',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(status),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Text(
                  _getStatusLabel(status),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _getStatusTextColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _getPlan(membership),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${_formatDate(_getStartDate(membership))} ~ ${_formatDate(_getEndDate(membership))}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _getStatusLabel(MembershipStatus status) {
    switch (status) {
      case MembershipStatus.active:
        return '이용중';
      case MembershipStatus.paused:
        return '일시정지';
      case MembershipStatus.expired:
        return '만료';
      case MembershipStatus.cancelled:
        return '취소됨';
    }
  }

  Color _getStatusBackgroundColor(MembershipStatus status) {
    switch (status) {
      case MembershipStatus.active:
        return AppColors.primaryLight;
      case MembershipStatus.paused:
        return AppColors.warningLight;
      case MembershipStatus.expired:
        return AppColors.grey200;
      case MembershipStatus.cancelled:
        return AppColors.errorLight;
    }
  }

  Color _getStatusTextColor(MembershipStatus status) {
    switch (status) {
      case MembershipStatus.active:
        return AppColors.primary;
      case MembershipStatus.paused:
        return AppColors.warning;
      case MembershipStatus.expired:
        return AppColors.grey600;
      case MembershipStatus.cancelled:
        return AppColors.error;
    }
  }
}
