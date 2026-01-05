import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../components/gym_button.dart';
import '../components/gym_card.dart';
import '../components/info_row.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../model/usehealth.dart';
import '../providers/usehealth_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/formatters.dart';
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
        // UsehealthProvider에 userId와 context 설정
        usehealthProvider.setUserId(userId);
        usehealthProvider.setContext(context);

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
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => _UsehealthDetailSheet(
          usehealth: usehealth,
          scrollController: scrollController,
        ),
      ),
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
    final statusColor = usehealth.status.color;
    final remainingDays = getRemainingDays(usehealth.endday);

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
                '${formatDate(usehealth.startday)} ~ ${formatDate(usehealth.endday)}',
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
                    value: getProgressRate(usehealth.startday, usehealth.endday),
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
}

// 상세보기 Bottom Sheet
class _UsehealthDetailSheet extends StatelessWidget {
  final Usehealth usehealth;
  final ScrollController scrollController;

  const _UsehealthDetailSheet({
    required this.usehealth,
    required this.scrollController,
  });

  Future<void> _handlePauseToggle(BuildContext context) async {
    final provider = context.read<UsehealthProvider>();
    final newStatus = usehealth.status == UsehealthStatus.use
        ? UsehealthStatus.paused
        : UsehealthStatus.use;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          newStatus == UsehealthStatus.paused ? '이용권 일시정지' : '이용권 재개',
        ),
        content: Text(
          newStatus == UsehealthStatus.paused
              ? '이용권을 일시정지하시겠습니까?\n일시정지 기간에는 이용권을 사용할 수 없습니다.'
              : '이용권을 재개하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              newStatus == UsehealthStatus.paused ? '일시정지' : '재개',
              style: TextStyle(
                color: newStatus == UsehealthStatus.paused
                    ? AppColors.warning
                    : AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final updatedUsehealth = Usehealth(
        id: usehealth.id,
        order: usehealth.order,
        health: usehealth.health,
        membership: usehealth.membership,
        user: usehealth.user,
        term: usehealth.term,
        discount: usehealth.discount,
        startday: usehealth.startday,
        endday: usehealth.endday,
        gym: usehealth.gym,
        status: newStatus,
        totalcount: usehealth.totalcount,
        usedcount: usehealth.usedcount,
        remainingcount: usehealth.remainingcount,
        qrcode: usehealth.qrcode,
        lastuseddate: usehealth.lastuseddate,
        date: usehealth.date,
        extra: usehealth.extra,
      );

      await UsehealthManager.update(updatedUsehealth);
      await provider.refresh();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == UsehealthStatus.paused
                  ? '이용권이 일시정지되었습니다'
                  : '이용권이 재개되었습니다',
            ),
            backgroundColor: newStatus == UsehealthStatus.paused
                ? AppColors.warning
                : AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = usehealth.status.color;

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
        child: Column(
          children: [
            // Handle bar (고정)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // 스크롤 가능한 전체 컨텐츠 영역
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: GestureDetector(
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
                        // QR 코드 컨텐츠
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
                              InfoRow(label: '체육관', value: gymName),
                              const SizedBox(height: AppSpacing.sm),
                              InfoRow(label: '이용권', value: membershipName),
                              const SizedBox(height: AppSpacing.sm),
                              InfoRow(
                                label: '상태',
                                value: usehealth.status.label,
                                valueColor: statusColor,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              InfoRow(label: '시작일', value: formatDate(usehealth.startday)),
                              const SizedBox(height: AppSpacing.sm),
                              InfoRow(label: '종료일', value: formatDate(usehealth.endday)),
                              const SizedBox(height: AppSpacing.sm),
                              InfoRow(
                                label: '남은 기간',
                                value: '${getRemainingDays(usehealth.endday)}일',
                                valueColor: AppColors.primary,
                              ),
                              if (usehealth.totalcount > 0) ...[
                                const SizedBox(height: AppSpacing.sm),
                                InfoRow(
                                  label: '사용 횟수',
                                  value: '${usehealth.usedcount} / ${usehealth.totalcount}회',
                                  valueColor: AppColors.primary,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                InfoRow(
                                  label: '남은 횟수',
                                  value: '${usehealth.remainingcount}회',
                                  valueColor: AppColors.success,
                                ),
                              ],
                              if (usehealth.lastuseddate.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                InfoRow(
                                  label: '최근 사용일',
                                  value: formatDate(usehealth.lastuseddate),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // 일시정지/재개 버튼 (상태가 사용중 또는 일시정지인 경우에만 표시)
                        if (usehealth.status == UsehealthStatus.use ||
                            usehealth.status == UsehealthStatus.paused)
                          GymButton(
                            text: usehealth.status == UsehealthStatus.use
                                ? '이용권 일시정지'
                                : '이용권 재개',
                            onPressed: () => _handlePauseToggle(context),
                            style: usehealth.status == UsehealthStatus.use
                                ? GymButtonStyle.outlined
                                : GymButtonStyle.filled,
                            purpose: usehealth.status == UsehealthStatus.use
                                ? GymButtonPurpose.warning
                                : GymButtonPurpose.primary,
                            size: GymButtonSize.large,
                            fullWidth: true,
                          ),

                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
