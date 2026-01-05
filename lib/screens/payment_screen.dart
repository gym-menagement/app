import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/gym_button.dart';
import '../components/gym_card.dart';
import '../components/gym_snackbar.dart';
import '../components/info_row.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../model/gym.dart';
import '../model/health.dart';
import '../model/order.dart';
import '../model/payment.dart' as payment_model;
import '../model/paymentform.dart';
import '../model/usehealth.dart';
import '../providers/auth_provider.dart';
import '../providers/usehealth_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/formatters.dart';

/// 결제 화면
class PaymentScreen extends StatefulWidget {
  final Gym gym;
  final Health health;

  const PaymentScreen({
    super.key,
    required this.gym,
    required this.health,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  String? _selectedPaymentMethod;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card',
      'name': '신용/체크카드',
      'icon': Icons.credit_card,
    },
    {
      'id': 'transfer',
      'name': '계좌이체',
      'icon': Icons.account_balance,
    },
    {
      'id': 'kakao',
      'name': '카카오페이',
      'icon': Icons.chat_bubble,
      'color': AppColors.kakao,
    },
    {
      'id': 'naver',
      'name': '네이버페이',
      'icon': Icons.shopping_bag,
      'color': AppColors.naver,
    },
  ];

  Future<void> _handlePayment() async {
    if (_selectedPaymentMethod == null) {
      GymSnackbar.showError(
        context: context,
        message: '결제 수단을 선택해주세요',
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      final hasDiscount = widget.health.discount > 0;
      final finalPrice =
          hasDiscount ? widget.health.costdiscount : widget.health.cost;

      print('=== 결제 프로세스 시작 ===');
      print('User ID: ${user.id}');
      print('Gym ID: ${widget.gym.id}');
      print('Health ID: ${widget.health.id}');
      print('Final Price: $finalPrice');

      final now = DateTime.now();
      final currentDate = now.toIso8601String();

      // 1. Order 생성
      final order = Order(
        user: user.id,
        gym: widget.gym.id,
        health: widget.health.id,
        date: currentDate,
      );

      print('\n1. Order 생성 요청');
      print('Order Data: ${order.toJson()}');
      final orderId = await OrderManager.insert(order);
      print('Order ID: $orderId');

      // 2. Payment 생성
      final payment = payment_model.Payment(
        gym: widget.gym.id,
        order: orderId,
        user: user.id,
        cost: finalPrice,
        date: currentDate,
        extra: {
          'paymentMethod': _selectedPaymentMethod,
          'healthName': widget.health.name,
        },
      );

      print('\n2. Payment 생성 요청');
      print('Payment Data: ${payment.toJson()}');
      final paymentId = await payment_model.PaymentManager.insert(payment);
      print('Payment ID: $paymentId');

      // 3. Paymentform 생성
      final paymentform = Paymentform(
        gym: widget.gym.id,
        payment: paymentId,
        type: _getPaymentTypeCode(_selectedPaymentMethod!),
        cost: finalPrice,
        date: currentDate,
      );

      print('\n3. Paymentform 생성 요청');
      print('Paymentform Data: ${paymentform.toJson()}');
      final paymentformId = await PaymentformManager.insert(paymentform);
      print('Paymentform ID: $paymentformId');

      // 4. Usehealth 생성 (이용권 활성화)
      // 시작일: 오늘 00:00:00
      final startDay = DateTime(now.year, now.month, now.day).toIso8601String();

      // 종료일: term개월 후 23:59:59
      final endDateTime = now.add(Duration(days: widget.health.term * 30));
      final endDay = DateTime(endDateTime.year, endDateTime.month, endDateTime.day, 23, 59, 59).toIso8601String();

      // QR 코드 생성 (user_gym_health_timestamp 형식)
      final qrcodeValue = 'QR_${user.id}_${widget.gym.id}_${widget.health.id}_${now.millisecondsSinceEpoch}';

      final usehealth = Usehealth(
        order: orderId,
        health: widget.health.id,
        membership: user.id, // 사용자 ID를 membership으로 사용
        user: user.id,
        term: widget.health.term,
        discount: widget.health.discount,
        startday: startDay,
        endday: endDay,
        gym: widget.gym.id,
        status: UsehealthStatus.use,
        totalcount: widget.health.count,
        usedcount: 0,
        remainingcount: widget.health.count,
        qrcode: qrcodeValue,
        lastuseddate: currentDate, // 생성 시점을 마지막 사용일로 설정
        date: currentDate,
      );

      print('\n4. Usehealth 생성 요청');
      print('Usehealth Data: ${usehealth.toJson()}');
      final usehealthId = await UsehealthManager.insert(usehealth);
      print('Usehealth ID: $usehealthId');

      print('\n=== 결제 프로세스 완료 ===');

      if (!mounted) return;

      // UsehealthProvider 새로고침
      final usehealthProvider = context.read<UsehealthProvider>();
      await usehealthProvider.refresh();
      print('Usehealth 데이터 새로고침 완료');

      // 5. 이용권 만료 알림 스케줄링
      try {
        final notificationProvider = context.read<NotificationProvider>();
        final expiryDateTime = DateTime.parse(endDay);

        await notificationProvider.scheduleMembershipExpiryNotifications(
          usehealthId: usehealthId,
          gymName: widget.gym.name,
          expiryDate: expiryDateTime,
        );
        print('이용권 만료 알림 스케줄링 완료 (D-7, D-3, D-1, D-Day)');
      } catch (e) {
        print('알림 스케줄링 실패 (결제는 완료됨): $e');
      }

      if (!mounted) return;

      // 결제 성공
      GymSnackbar.showSuccess(
        context: context,
        message: '결제가 완료되었습니다',
      );

      // 홈 화면으로 이동 (모든 스택 제거)
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
      );
    } catch (e, stackTrace) {
      print('\n=== 결제 오류 발생 ===');
      print('Error: $e');
      print('StackTrace: $stackTrace');

      if (mounted) {
        GymSnackbar.showError(
          context: context,
          message: '결제 처리 중 오류가 발생했습니다: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  int _getPaymentTypeCode(String paymentMethod) {
    // 결제 수단 코드 매핑 (실제 시스템에 맞게 조정 필요)
    switch (paymentMethod) {
      case 'card':
        return 1; // 신용/체크카드
      case 'transfer':
        return 2; // 계좌이체
      case 'kakao':
        return 3; // 카카오페이
      case 'naver':
        return 4; // 네이버페이
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.health.discount > 0;
    final finalPrice =
        hasDiscount ? widget.health.costdiscount : widget.health.cost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('결제'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 주문 정보
                  Text(
                    '주문 정보',
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
                                  widget.gym.name,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Divider(),
                          const SizedBox(height: AppSpacing.md),
                          InfoRow(label: '이용권', value: widget.health.name),
                          const SizedBox(height: AppSpacing.sm),
                          InfoRow(label: '기간', value: getTermLabel(widget.health.term)),
                          if (widget.health.count > 0) ...[
                            const SizedBox(height: AppSpacing.sm),
                            InfoRow(label: '횟수', value: '${widget.health.count}회'),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 결제 수단 선택
                  Text(
                    '결제 수단',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...(_paymentMethods.map((method) {
                    final isSelected = _selectedPaymentMethod == method['id'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _buildPaymentMethodCard(method, isSelected),
                    );
                  })),

                  const SizedBox(height: AppSpacing.xl),

                  // 결제 금액
                  Text(
                    '결제 금액',
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
                          PriceRow(
                            label: '상품 금액',
                            value: formatPrice(widget.health.cost),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(height: AppSpacing.sm),
                            PriceRow(
                              label: '할인 금액 (${widget.health.discount}%)',
                              value: '-${formatPrice(widget.health.cost - widget.health.costdiscount)}',
                              color: AppColors.error,
                            ),
                          ],
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
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),

          // 결제 버튼
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
              child: GymButton(
                text: '${formatPrice(finalPrice)} 결제하기',
                onPressed: _isProcessing ? null : _handlePayment,
                loading: _isProcessing,
                size: GymButtonSize.large,
                fullWidth: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    Map<String, dynamic> method,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: _isProcessing
          ? null
          : () {
              setState(() {
                _selectedPaymentMethod = method['id'] as String;
              });
            },
      child: GymCard(
        elevation: isSelected ? 3 : 1,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (method['color'] as Color?) ?? AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  method['icon'] as IconData,
                  color: (method['color'] as Color?) != null
                      ? Colors.white
                      : AppColors.grey700,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  method['name'] as String,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
