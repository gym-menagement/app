import 'package:flutter/material.dart';
import '../components/gym_layout.dart';
import '../components/gym_button.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Mock gym info (normally passed via route arguments)
  final String _gymName = '강남 피트니스';
  final String _gymAddress = '서울 강남구 테헤란로 123';
  final String _gymPhone = '02-1234-5678';

  // Step 1: Plan Selection
  int? _selectedPlanIndex;
  final List<Map<String, dynamic>> _membershipPlans = [
    {
      'name': '1개월 이용권',
      'duration': 30,
      'price': 100000,
      'discountPrice': null,
      'popular': false,
      'features': ['자유 이용', '락커 제공'],
    },
    {
      'name': '3개월 이용권',
      'duration': 90,
      'price': 270000,
      'discountPrice': 250000,
      'popular': true,
      'features': ['자유 이용', '락커 제공', '운동복 무료 세탁'],
    },
    {
      'name': '6개월 이용권',
      'duration': 180,
      'price': 540000,
      'discountPrice': 450000,
      'popular': false,
      'features': ['자유 이용', '락커 제공', '운동복 무료 세탁', 'PT 1회 무료'],
    },
    {
      'name': '12개월 이용권',
      'duration': 365,
      'price': 1080000,
      'discountPrice': 800000,
      'popular': false,
      'features': ['자유 이용', '락커 제공', '운동복 무료 세탁', 'PT 3회 무료', '주차 무료'],
    },
  ];

  // Step 2: Payment Method
  String? _selectedPaymentMethod;
  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'card', 'name': '신용/체크카드', 'icon': Icons.credit_card},
    {'id': 'transfer', 'name': '계좌이체', 'icon': Icons.account_balance},
    {'id': 'kakaopay', 'name': '카카오페이', 'icon': Icons.payment},
    {'id': 'naverpay', 'name': '네이버페이', 'icon': Icons.payment},
    {'id': 'tosspay', 'name': '토스페이', 'icon': Icons.payment},
  ];

  bool _agreeTerms = false;
  bool _agreeRefund = false;

  // Step 3: Payment Result
  String _orderNumber = '';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getFinalPrice() {
    if (_selectedPlanIndex == null) return 0;
    final plan = _membershipPlans[_selectedPlanIndex!];
    return (plan['discountPrice'] ?? plan['price']) as int;
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_selectedPlanIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이용권을 선택해주세요'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_selectedPaymentMethod == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('결제 수단을 선택해주세요'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (!_agreeTerms || !_agreeRefund) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('필수 약관에 동의해주세요'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      _processPayment();
      return;
    }

    setState(() => _currentStep++);
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual payment gateway integration
      await Future.delayed(const Duration(seconds: 2));

      // Generate order number
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _orderNumber = 'ORD${timestamp.toString().substring(7)}';

      if (mounted) {
        setState(() {
          _currentStep = 2;
          _isLoading = false;
        });
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결제 실패: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GymLayout(
      title: '이용권 결제',
      scrollable: false,
      body: Column(
        children: [
          // Progress Indicator
          if (_currentStep < 2) _buildProgressIndicator(),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1PlanSelection(),
                _buildStep2PaymentMethod(),
                _buildStep3Result(),
              ],
            ),
          ),

          // Navigation Buttons
          if (_currentStep < 2) _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          _buildStepIndicator(0, '이용권 선택'),
          _buildStepLine(0),
          _buildStepIndicator(1, '결제 수단'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.primary : AppColors.grey300,
              border: Border.all(
                color: isCurrent ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${step + 1}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isActive ? AppColors.onPrimary : AppColors.grey500,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isActive ? AppColors.primary : AppColors.grey500,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        color: isActive ? AppColors.primary : AppColors.grey300,
      ),
    );
  }

  Widget _buildStep1PlanSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gym Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _gymName,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          _gymAddress,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        _gymPhone,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            '이용권을 선택해주세요',
            style: AppTextStyles.h3,
          ),

          const SizedBox(height: AppSpacing.md),

          // Plan Cards
          ...List.generate(_membershipPlans.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildPlanCard(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = _membershipPlans[index];
    final isSelected = _selectedPlanIndex == index;
    final hasDiscount = plan['discountPrice'] != null;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() => _selectedPlanIndex = index);
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Radio<int>(
                          value: index,
                          groupValue: _selectedPlanIndex,
                          onChanged: (value) {
                            setState(() => _selectedPlanIndex = value);
                          },
                          activeColor: AppColors.primary,
                        ),
                        Text(
                          plan['name'],
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (plan['popular'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSmall,
                        ),
                      ),
                      child: Text(
                        '인기',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Price
              Row(
                children: [
                  if (hasDiscount) ...[
                    Text(
                      '${_formatPrice(plan['price'])}원',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSmall,
                        ),
                      ),
                      child: Text(
                        '${((1 - plan['discountPrice'] / plan['price']) * 100).toInt()}%',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              Text(
                '${_formatPrice(plan['discountPrice'] ?? plan['price'])}원',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Features
              ...((plan['features'] as List).map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        feature,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                );
              })),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2PaymentMethod() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selected Plan Summary
          Card(
            color: AppColors.primaryLight,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '선택한 이용권',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (_selectedPlanIndex != null) ...[
                    Text(
                      _membershipPlans[_selectedPlanIndex!]['name'],
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '결제 금액',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          '${_formatPrice(_getFinalPrice())}원',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            '결제 수단을 선택해주세요',
            style: AppTextStyles.h3,
          ),

          const SizedBox(height: AppSpacing.md),

          // Payment Methods
          ...List.generate(_paymentMethods.length, (index) {
            final method = _paymentMethods[index];
            final isSelected = _selectedPaymentMethod == method['id'];

            return Card(
              elevation: isSelected ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.grey300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() => _selectedPaymentMethod = method['id']);
                },
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: method['id'],
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() => _selectedPaymentMethod = value);
                        },
                        activeColor: AppColors.primary,
                      ),
                      Icon(
                        method['icon'],
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.grey500,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        method['name'],
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.grey900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: AppSpacing.lg),

          const Divider(),

          const SizedBox(height: AppSpacing.md),

          // Terms Agreement
          Text(
            '약관 동의',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          CheckboxListTile(
            value: _agreeTerms,
            onChanged: (value) {
              setState(() => _agreeTerms = value ?? false);
            },
            title: Row(
              children: [
                const Text('결제 약관 동의'),
                Container(
                  margin: const EdgeInsets.only(left: AppSpacing.xs),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '필수',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            secondary: IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                // TODO: Show terms detail
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('결제 약관 내용')),
                );
              },
            ),
          ),

          CheckboxListTile(
            value: _agreeRefund,
            onChanged: (value) {
              setState(() => _agreeRefund = value ?? false);
            },
            title: Row(
              children: [
                const Text('환불 정책 동의'),
                Container(
                  margin: const EdgeInsets.only(left: AppSpacing.xs),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '필수',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            secondary: IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                // TODO: Show refund policy detail
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('환불 정책 내용')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Result() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: AppColors.success,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              '결제가 완료되었습니다',
              style: AppTextStyles.h2,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Receipt
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        '영수증',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),

                    _buildReceiptRow('주문번호', _orderNumber),
                    const SizedBox(height: AppSpacing.sm),
                    _buildReceiptRow('체육관', _gymName),
                    const SizedBox(height: AppSpacing.sm),
                    if (_selectedPlanIndex != null)
                      _buildReceiptRow(
                        '이용권',
                        _membershipPlans[_selectedPlanIndex!]['name'],
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_selectedPaymentMethod != null)
                      _buildReceiptRow(
                        '결제 수단',
                        _paymentMethods.firstWhere(
                          (m) => m['id'] == _selectedPaymentMethod,
                        )['name'],
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildReceiptRow(
                      '결제일시',
                      DateTime.now().toString().substring(0, 16),
                    ),

                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '결제 금액',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_formatPrice(_getFinalPrice())}원',
                          style: AppTextStyles.h3.copyWith(
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

            const SizedBox(height: AppSpacing.xl),

            GymButton(
              text: '이용권 확인하기',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/membership');
              },
              size: GymButtonSize.large,
            ),

            const SizedBox(height: AppSpacing.md),

            GymButton(
              text: '홈으로 가기',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              style: GymButtonStyle.outlined,
              size: GymButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.grey700,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: GymButton(
                text: '이전',
                onPressed: _previousStep,
                style: GymButtonStyle.outlined,
                disabled: _isLoading,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: GymButton(
              text: _currentStep == 1 ? '결제하기' : '다음',
              onPressed: _nextStep,
              loading: _isLoading,
              size: GymButtonSize.large,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
