import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../components/gym_card.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../model/usehealth.dart';
import '../providers/usehealth_provider.dart';
import '../providers/auth_provider.dart';
import 'membership_screen_fullscreen_qr.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  bool _isActiveExpanded = true;
  bool _isPausedExpanded = true;
  bool _isExpiredExpanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final usehealthProvider = context.read<UsehealthProvider>();

      // AuthProvider에서 userId 가져오기
      final userId = authProvider.currentUser?.id;

      if (userId != null) {
        // UsehealthProvider에 userId 설정
        usehealthProvider.setUserId(userId);

        if (usehealthProvider.usehealths.isEmpty) {
          usehealthProvider.loadUsehealths();
        }
      }
    });
  }

  void _showUsehealthDetail(Usehealth usehealth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UsehealthDetailSheet(usehealth: usehealth),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 이용권'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<UsehealthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: AppColors.grey400),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '오류가 발생했습니다',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    provider.errorMessage ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (provider.usehealths.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // 사용중인 이용권 섹션
                if (provider.activeUsehealths.isNotEmpty)
                  _buildCollapsibleSection(
                    title: '사용중인 이용권',
                    count: provider.activeUsehealths.length,
                    isExpanded: _isActiveExpanded,
                    onToggle: () {
                      setState(() {
                        _isActiveExpanded = !_isActiveExpanded;
                      });
                    },
                    children: provider.activeUsehealths,
                    color: AppColors.primary,
                  ),

                // 일시정지된 이용권 섹션
                if (provider.pausedUsehealths.isNotEmpty)
                  _buildCollapsibleSection(
                    title: '일시정지된 이용권',
                    count: provider.pausedUsehealths.length,
                    isExpanded: _isPausedExpanded,
                    onToggle: () {
                      setState(() {
                        _isPausedExpanded = !_isPausedExpanded;
                      });
                    },
                    children: provider.pausedUsehealths,
                    color: AppColors.warning,
                  ),

                // 만료된 이용권 섹션
                if (provider.expiredUsehealths.isNotEmpty)
                  _buildCollapsibleSection(
                    title: '만료된 이용권',
                    count: provider.expiredUsehealths.length,
                    isExpanded: _isExpiredExpanded,
                    onToggle: () {
                      setState(() {
                        _isExpiredExpanded = !_isExpiredExpanded;
                      });
                    },
                    children: provider.expiredUsehealths,
                    color: AppColors.grey500,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 80,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '이용권이 없습니다',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.grey700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '체육관을 검색하고 이용권을 구매해보세요',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required int count,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Usehealth> children,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GymCard(
          onTap: onToggle,
          padding: const EdgeInsets.all(AppSpacing.md),
          elevation: 1,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSmall,
                        ),
                      ),
                      child: Text(
                        '$count',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppColors.grey600,
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: AppSpacing.md),
          ...children.map((usehealth) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildUsehealthCard(usehealth),
            );
          }),
        ],
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildUsehealthCard(Usehealth usehealth) {
    final statusColor = _getStatusColor(usehealth.status);
    final remainingDays = _getRemainingDays(usehealth);

    // extra에서 gym, health 정보 추출
    String gymName = '체육관';
    String membershipName = '이용권';

    if (usehealth.extra['gym'] != null && usehealth.extra['gym'] is Map) {
      final gymData = usehealth.extra['gym'] as Map<String, dynamic>;
      gymName = gymData['name'] as String? ?? '체육관';
    }

    if (usehealth.extra['health'] != null && usehealth.extra['health'] is Map) {
      final healthData = usehealth.extra['health'] as Map<String, dynamic>;
      membershipName = healthData['name'] as String? ?? '이용권';
    }

    return GymCard(
      onTap: () => _showUsehealthDetail(usehealth),
      padding: const EdgeInsets.all(AppSpacing.md),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gymName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      membershipName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey600,
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Text(
                  usehealth.status.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 기간 정보
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.grey500,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${_formatDate(usehealth.startday)} ~ ${_formatDate(usehealth.endday)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // 진행률
          if (usehealth.status == UsehealthStatus.use) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '남은 기간',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    Text(
                      '$remainingDays일',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  child: LinearProgressIndicator(
                    value: _getProgressValue(usehealth),
                    backgroundColor: AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ],

          // 횟수권인 경우
          if (usehealth.totalcount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '사용 횟수',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                Text(
                  '${usehealth.usedcount} / ${usehealth.totalcount}회',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(UsehealthStatus status) {
    switch (status) {
      case UsehealthStatus.use:
        return AppColors.primary;
      case UsehealthStatus.paused:
        return AppColors.warning;
      case UsehealthStatus.expired:
        return AppColors.grey500;
      case UsehealthStatus.terminated:
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  int _getRemainingDays(Usehealth usehealth) {
    try {
      final endDate = DateTime.parse(usehealth.endday);
      return endDate.difference(DateTime.now()).inDays;
    } catch (e) {
      return 0;
    }
  }

  double _getProgressValue(Usehealth usehealth) {
    try {
      final startDate = DateTime.parse(usehealth.startday);
      final endDate = DateTime.parse(usehealth.endday);
      final total = endDate.difference(startDate).inDays;
      final used = DateTime.now().difference(startDate).inDays;
      return (used / total).clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}

// 상세보기 Bottom Sheet
class _UsehealthDetailSheet extends StatelessWidget {
  final Usehealth usehealth;

  const _UsehealthDetailSheet({required this.usehealth});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(usehealth.status);

    // extra에서 gym, health 정보 추출
    String gymName = '체육관';
    String membershipName = '이용권';

    if (usehealth.extra['gym'] != null && usehealth.extra['gym'] is Map) {
      final gymData = usehealth.extra['gym'] as Map<String, dynamic>;
      gymName = gymData['name'] as String? ?? '체육관';
    }

    if (usehealth.extra['health'] != null && usehealth.extra['health'] is Map) {
      final healthData = usehealth.extra['health'] as Map<String, dynamic>;
      membershipName = healthData['name'] as String? ?? '이용권';
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLarge),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // QR 코드
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FullScreenQRCode(
                        qrData: usehealth.qrcode.isEmpty
                            ? 'usehealth_${usehealth.id}'
                            : usehealth.qrcode,
                        gymName: gymName,
                      ),
                      fullscreenDialog: true,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    border: Border.all(color: AppColors.grey300, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '체육관 입장 QR',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSmall,
                          ),
                        ),
                        child: QrImageView(
                          data: usehealth.qrcode.isEmpty
                              ? 'usehealth_${usehealth.id}'
                              : usehealth.qrcode,
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '출입 시 이 QR코드를 스캔해주세요',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.fullscreen,
                            size: 16,
                            color: AppColors.grey500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 이용권 정보
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이용권 정보',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoRow('체육관', gymName),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInfoRow('이용권', membershipName),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInfoRow(
                      '상태',
                      usehealth.status.label,
                      valueColor: statusColor,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInfoRow('시작일', _formatDate(usehealth.startday)),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInfoRow('종료일', _formatDate(usehealth.endday)),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInfoRow(
                      '남은 기간',
                      '${_getRemainingDays(usehealth)}일',
                      valueColor: AppColors.primary,
                    ),
                    if (usehealth.totalcount > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(
                        '사용 횟수',
                        '${usehealth.usedcount} / ${usehealth.totalcount}회',
                        valueColor: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(
                        '남은 횟수',
                        '${usehealth.remainingcount}회',
                        valueColor: AppColors.success,
                      ),
                    ],
                    if (usehealth.lastuseddate.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(
                        '최근 사용일',
                        _formatDate(usehealth.lastuseddate),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 닫기 버튼
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusMedium,
                    ),
                  ),
                ),
                child: Text(
                  '닫기',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor ?? AppColors.grey900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(UsehealthStatus status) {
    switch (status) {
      case UsehealthStatus.use:
        return AppColors.primary;
      case UsehealthStatus.paused:
        return AppColors.warning;
      case UsehealthStatus.expired:
        return AppColors.grey500;
      case UsehealthStatus.terminated:
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  int _getRemainingDays(Usehealth usehealth) {
    try {
      final endDate = DateTime.parse(usehealth.endday);
      return endDate.difference(DateTime.now()).inDays;
    } catch (e) {
      return 0;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
