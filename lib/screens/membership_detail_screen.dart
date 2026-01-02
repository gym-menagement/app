import 'package:flutter/material.dart';
import '../components/gym_button.dart';
import '../components/gym_card.dart';
import '../components/info_row.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../model/gym.dart';
import '../model/health.dart';
import '../utils/formatters.dart';
import 'payment_screen.dart';

/// 이용권 상세 정보 화면
class MembershipDetailScreen extends StatelessWidget {
  final Gym gym;
  final Health health;

  const MembershipDetailScreen({
    super.key,
    required this.gym,
    required this.health,
  });

  void _handlePayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          gym: gym,
          health: health,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = health.discount > 0;
    final finalPrice = hasDiscount ? health.costdiscount : health.cost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('이용권 상세'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헬스장 정보
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.grey200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.fitness_center,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                gym.name,
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (gym.address.isNotEmpty) ...{
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: AppColors.grey600,
                                size: 16,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  gym.address,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.grey600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        },
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 이용권 이름
                        Text(
                          health.name,
                          style: AppTextStyles.h2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // 기간 및 횟수 태그
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    getTermLabel(health.term),
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (health.count > 0) ...{
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.grey100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.event_repeat,
                                      size: 16,
                                      color: AppColors.grey700,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      '${health.count}회',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.grey700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            },
                          ],
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // 이용권 설명
                        if (health.content.isNotEmpty) ...{
                          Text(
                            '이용권 안내',
                            style: AppTextStyles.h4.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: GymCard(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Text(
                                  health.content,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.grey700,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        },

                        // 가격 정보
                        Text(
                          '가격 정보',
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        GymCard(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '정상가',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.grey700,
                                      ),
                                    ),
                                    Text(
                                      formatPrice(health.cost),
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: hasDiscount ? AppColors.grey500 : AppColors.grey900,
                                        decoration: hasDiscount ? TextDecoration.lineThrough : null,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (hasDiscount) ...{
                                  const SizedBox(height: AppSpacing.md),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '할인',
                                            style: AppTextStyles.bodyLarge.copyWith(
                                              color: AppColors.error,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.error,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${health.discount}%',
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '-${formatPrice(health.cost - health.costdiscount)}',
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  const Divider(),
                                  const SizedBox(height: AppSpacing.md),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '최종 결제 금액',
                                        style: AppTextStyles.titleLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        formatPrice(finalPrice),
                                        style: AppTextStyles.h2.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                },
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // 이용 안내
                        Text(
                          '이용 안내',
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        GymCard(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const InfoItem(
                                  text: '이용권은 구매 즉시 활성화됩니다.',
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                InfoItem(
                                  text: '이용 기간은 구매일로부터 ${getTermLabel(health.term)}입니다.',
                                ),
                                if (health.count > 0) ...{
                                  const SizedBox(height: AppSpacing.sm),
                                  InfoItem(
                                    text: '총 ${health.count}회 이용 가능합니다.',
                                  ),
                                },
                                const SizedBox(height: AppSpacing.sm),
                                const InfoItem(
                                  text: '환불 및 양도는 헬스장 정책에 따릅니다.',
                                ),
                              ],
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

          // 결제하기 버튼
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '총 결제 금액',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        formatPrice(finalPrice),
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GymButton(
                    text: '결제하기',
                    onPressed: () => _handlePayment(context),
                    size: GymButtonSize.large,
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
