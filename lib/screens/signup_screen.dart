import 'package:flutter/material.dart';
import '../components/gym_layout.dart';
import '../components/gym_textfield.dart';
import '../components/gym_button.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../utils/validators.dart';
import '../model/user.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Account Information
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _emailController = TextEditingController();

  String? _loginIdError;
  String? _passwordError;
  String? _passwordConfirmError;
  String? _emailError;
  bool _loginIdChecked = false;
  bool _loginIdAvailable = false;

  // Step 2: Personal Information
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthController = TextEditingController();
  final _addressController = TextEditingController();

  String? _nameError;
  String? _phoneError;
  String? _birthError;
  UserSex _selectedGender = UserSex.male;

  // Step 3: Terms Agreement
  bool _agreeAll = false;
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _agreeMarketing = false;

  @override
  void dispose() {
    _pageController.dispose();
    _loginIdController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _birthController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginIdAvailable() async {
    final error = Validators.validateLoginId(_loginIdController.text);
    if (error != null) {
      setState(() {
        _loginIdError = error;
        _loginIdChecked = false;
        _loginIdAvailable = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Simulate: Assume available for now
      if (mounted) {
        setState(() {
          _loginIdChecked = true;
          _loginIdAvailable = true;
          _loginIdError = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('사용 가능한 아이디입니다'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loginIdChecked = true;
          _loginIdAvailable = false;
          _loginIdError = '이미 사용중인 아이디입니다';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateStep1() {
    setState(() {
      _loginIdError = null;
      _passwordError = null;
      _passwordConfirmError = null;
      _emailError = null;
    });

    bool isValid = true;

    if (!_loginIdChecked || !_loginIdAvailable) {
      setState(() => _loginIdError = '아이디 중복 확인이 필요합니다');
      isValid = false;
    }

    final passwordError = Validators.validatePassword(_passwordController.text);
    if (passwordError != null) {
      setState(() => _passwordError = passwordError);
      isValid = false;
    }

    final passwordConfirmError = Validators.validatePasswordConfirm(
      _passwordConfirmController.text,
      _passwordController.text,
    );
    if (passwordConfirmError != null) {
      setState(() => _passwordConfirmError = passwordConfirmError);
      isValid = false;
    }

    final emailError = Validators.validateEmail(_emailController.text);
    if (emailError != null) {
      setState(() => _emailError = emailError);
      isValid = false;
    }

    return isValid;
  }

  bool _validateStep2() {
    setState(() {
      _nameError = null;
      _phoneError = null;
      _birthError = null;
    });

    bool isValid = true;

    final nameError = Validators.validateName(_nameController.text);
    if (nameError != null) {
      setState(() => _nameError = nameError);
      isValid = false;
    }

    final phoneError = Validators.validatePhone(_phoneController.text);
    if (phoneError != null) {
      setState(() => _phoneError = phoneError);
      isValid = false;
    }

    final birthError = Validators.validateBirthDate(_birthController.text);
    if (birthError != null) {
      setState(() => _birthError = birthError);
      isValid = false;
    }

    return isValid;
  }

  void _nextStep() {
    bool canProceed = false;

    if (_currentStep == 0) {
      canProceed = _validateStep1();
    } else if (_currentStep == 1) {
      canProceed = _validateStep2();
    }

    if (canProceed) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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

  Future<void> _submitSignup() async {
    if (!_agreeTerms || !_agreePrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('필수 약관에 동의해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual signup API call
      final user = User(
        loginid: _loginIdController.text.trim(),
        passwd: _passwordController.text,
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        tel: _phoneController.text.trim(),
        birth: _birthController.text.trim(),
        sex: _selectedGender,
        address: _addressController.text.trim(),
        type: UserType.normal,
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('회원가입 완료'),
            content: const Text('회원가입이 완료되었습니다.\n로그인 페이지로 이동합니다.'),
            actions: [
              GymButton(
                text: '확인',
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GymLayout(
      title: '회원가입',
      scrollable: false,
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          _buildStepIndicator(0, '계정 정보'),
          _buildStepLine(0),
          _buildStepIndicator(1, '개인 정보'),
          _buildStepLine(1),
          _buildStepIndicator(2, '약관 동의'),
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

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '계정 정보를 입력해주세요',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Login ID with duplicate check
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GymTextField(
                  controller: _loginIdController,
                  labelText: '아이디',
                  hintText: '4-20자의 영문자와 숫자',
                  prefixIcon: Icons.person_outline,
                  errorText: _loginIdError,
                  enabled: !_isLoading,
                  onChanged: (_) {
                    setState(() {
                      _loginIdChecked = false;
                      _loginIdAvailable = false;
                      _loginIdError = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                margin: const EdgeInsets.only(top: 24),
                child: GymButton(
                  text: '중복확인',
                  onPressed: _checkLoginIdAvailable,
                  size: GymButtonSize.medium,
                  style: GymButtonStyle.outlined,
                  fullWidth: false,
                  loading: _isLoading,
                ),
              ),
            ],
          ),

          if (_loginIdChecked && _loginIdAvailable)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                '✓ 사용 가능한 아이디입니다',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.md),

          GymTextField(
            controller: _passwordController,
            labelText: '비밀번호',
            hintText: '8자 이상, 영문자와 숫자 포함',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            errorText: _passwordError,
            enabled: !_isLoading,
            type: GymTextFieldType.password,
          ),

          const SizedBox(height: AppSpacing.md),

          GymTextField(
            controller: _passwordConfirmController,
            labelText: '비밀번호 확인',
            hintText: '비밀번호를 다시 입력하세요',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            errorText: _passwordConfirmError,
            enabled: !_isLoading,
            type: GymTextFieldType.password,
          ),

          const SizedBox(height: AppSpacing.md),

          GymTextField(
            controller: _emailController,
            labelText: '이메일',
            hintText: 'example@email.com',
            prefixIcon: Icons.email_outlined,
            errorText: _emailError,
            enabled: !_isLoading,
            type: GymTextFieldType.email,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '개인 정보를 입력해주세요',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.lg),

          GymTextField(
            controller: _nameController,
            labelText: '이름',
            hintText: '이름을 입력하세요',
            prefixIcon: Icons.person_outline,
            errorText: _nameError,
            enabled: !_isLoading,
          ),

          const SizedBox(height: AppSpacing.md),

          GymTextField(
            controller: _phoneController,
            labelText: '전화번호',
            hintText: '01012345678',
            prefixIcon: Icons.phone_outlined,
            errorText: _phoneError,
            enabled: !_isLoading,
            type: GymTextFieldType.phone,
          ),

          const SizedBox(height: AppSpacing.md),

          GymTextField(
            controller: _birthController,
            labelText: '생년월일',
            hintText: 'YYYYMMDD (예: 19900101)',
            prefixIcon: Icons.calendar_today_outlined,
            errorText: _birthError,
            enabled: !_isLoading,
            type: GymTextFieldType.number,
            maxLength: 8,
          ),

          const SizedBox(height: AppSpacing.md),

          // Gender Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '성별',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: GymButton(
                      text: '남성',
                      onPressed: _isLoading ? null : () {
                        setState(() => _selectedGender = UserSex.male);
                      },
                      style: _selectedGender == UserSex.male
                          ? GymButtonStyle.filled
                          : GymButtonStyle.outlined,
                      purpose: GymButtonPurpose.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GymButton(
                      text: '여성',
                      onPressed: _isLoading ? null : () {
                        setState(() => _selectedGender = UserSex.female);
                      },
                      style: _selectedGender == UserSex.female
                          ? GymButtonStyle.filled
                          : GymButtonStyle.outlined,
                      purpose: GymButtonPurpose.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          GymTextField(
            controller: _addressController,
            labelText: '주소 (선택사항)',
            hintText: '주소를 입력하세요',
            prefixIcon: Icons.home_outlined,
            enabled: !_isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '약관에 동의해주세요',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Agree All
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: CheckboxListTile(
              value: _agreeAll,
              onChanged: _isLoading ? null : (value) {
                setState(() {
                  _agreeAll = value ?? false;
                  _agreeTerms = _agreeAll;
                  _agreePrivacy = _agreeAll;
                  _agreeMarketing = _agreeAll;
                });
              },
              title: Text(
                '전체 동의',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Individual agreements
          _buildAgreementItem(
            '이용약관 동의 (필수)',
            _agreeTerms,
            (value) {
              setState(() {
                _agreeTerms = value ?? false;
                _updateAgreeAll();
              });
            },
            required: true,
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildAgreementItem(
            '개인정보 처리방침 동의 (필수)',
            _agreePrivacy,
            (value) {
              setState(() {
                _agreePrivacy = value ?? false;
                _updateAgreeAll();
              });
            },
            required: true,
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildAgreementItem(
            '마케팅 정보 수신 동의 (선택)',
            _agreeMarketing,
            (value) {
              setState(() {
                _agreeMarketing = value ?? false;
                _updateAgreeAll();
              });
            },
            required: false,
          ),

          const SizedBox(height: AppSpacing.xl),

          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: Text(
              '필수 약관에 동의하지 않으면 회원가입을 진행할 수 없습니다.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementItem(
    String title,
    bool value,
    Function(bool?) onChanged, {
    required bool required,
  }) {
    return Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            value: value,
            onChanged: _isLoading ? null : onChanged,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                if (required)
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
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.grey500),
          onPressed: () {
            // TODO: Show agreement detail
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title 내용 보기')),
            );
          },
        ),
      ],
    );
  }

  void _updateAgreeAll() {
    setState(() {
      _agreeAll = _agreeTerms && _agreePrivacy && _agreeMarketing;
    });
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
              text: _currentStep == 2 ? '회원가입 완료' : '다음',
              onPressed: _currentStep == 2 ? _submitSignup : _nextStep,
              loading: _isLoading,
              size: GymButtonSize.large,
            ),
          ),
        ],
      ),
    );
  }
}
