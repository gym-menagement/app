import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';

/// 정보를 라벨-값 형식으로 표시하는 행 위젯
///
/// 사용 예시:
/// ```dart
/// InfoRow(
///   label: '체육관',
///   value: '강남 헬스클럽',
/// )
///
/// InfoRow(
///   label: '상태',
///   value: '사용중',
///   valueColor: AppColors.primary,
/// )
/// ```
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ??
              AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
        ),
        Text(
          value,
          style: valueStyle ??
              AppTextStyles.bodyMedium.copyWith(
                color: valueColor ?? AppColors.grey900,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

/// 가격 정보를 표시하는 행 위젯
///
/// 사용 예시:
/// ```dart
/// PriceRow(
///   label: '상품 금액',
///   value: '100,000원',
/// )
///
/// PriceRow(
///   label: '할인 금액',
///   value: '-10,000원',
///   color: AppColors.error,
/// )
/// ```
class PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const PriceRow({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color ?? AppColors.grey700,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: color ?? AppColors.grey900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// 정보 항목을 bullet point와 함께 표시하는 위젯
///
/// 사용 예시:
/// ```dart
/// InfoItem(
///   text: '이용권은 구매 즉시 활성화됩니다.',
/// )
/// ```
class InfoItem extends StatelessWidget {
  final String text;
  final Color? bulletColor;
  final TextStyle? textStyle;

  const InfoItem({
    super.key,
    required this.text,
    this.bulletColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: bulletColor ?? AppColors.grey600,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: textStyle ??
                AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey700,
                  height: 1.5,
                ),
          ),
        ),
      ],
    );
  }
}
