import 'dart:async';
import 'package:flutter/material.dart';
import '../components/gym_layout.dart';
import '../components/gym_textfield.dart';
import '../components/gym_button.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../utils/validators.dart';

class FindIdPwScreen extends StatefulWidget {
  const FindIdPwScreen({super.key});

  @override
  State<FindIdPwScreen> createState() => _FindIdPwScreenState();
}

class _FindIdPwScreenState extends State<FindIdPwScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GymLayout(
      title: '계정 찾기',
      scrollable: false,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey500,
              labelStyle: AppTextStyles.titleMedium,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: '아이디 찾기'),
                Tab(text: '비밀번호 찾기'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                FindIdTab(),
                FindPasswordTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Find ID Tab
class FindIdTab extends StatefulWidget {
  const FindIdTab({super.key});

  @override
  State<FindIdTab> createState() => _FindIdTabState();
}

class _FindIdTabState extends State<FindIdTab> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  String? _nameError;
  String? _phoneError;
  String? _verificationCodeError;

  bool _isLoading = false;
  bool _codeSent = false;
  bool _foundId = false;
  String? _foundLoginId;

  Timer? _timer;
  int _remainingSeconds = 180; // 3 minutes

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 180;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            _codeSent = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('인증 시간이 만료되었습니다. 다시 시도해주세요.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _sendVerificationCode() async {
    setState(() {
      _nameError = null;
      _phoneError = null;
    });

    final nameError = Validators.validateName(_nameController.text);
    if (nameError != null) {
      setState(() => _nameError = nameError);
      return;
    }

    final phoneError = Validators.validatePhone(_phoneController.text);
    if (phoneError != null) {
      setState(() => _phoneError = phoneError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _codeSent = true;
          _isLoading = false;
        });
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인증번호가 발송되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('인증번호 발송 실패: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _findId() async {
    setState(() => _verificationCodeError = null);

    if (_verificationCodeController.text.trim().isEmpty) {
      setState(() => _verificationCodeError = '인증번호를 입력해주세요');
      return;
    }

    if (_verificationCodeController.text.trim().length != 6) {
      setState(() => _verificationCodeError = '인증번호는 6자리입니다');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Simulate found ID
      if (mounted) {
        setState(() {
          _foundId = true;
          _foundLoginId = 'user***'; // Masked login ID
          _isLoading = false;
        });
        _timer?.cancel();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _verificationCodeError = '인증번호가 올바르지 않습니다';
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _nameController.clear();
      _phoneController.clear();
      _verificationCodeController.clear();
      _nameError = null;
      _phoneError = null;
      _verificationCodeError = null;
      _codeSent = false;
      _foundId = false;
      _foundLoginId = null;
      _remainingSeconds = 180;
    });
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_foundId) {
      return _buildFoundIdResult();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),

          Icon(
            Icons.person_search,
            size: 80,
            color: AppColors.primary.withOpacity(0.7),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            '아이디를 찾기 위해\n본인 정보를 입력해주세요',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xl),

          GymTextField(
            controller: _nameController,
            labelText: '이름',
            hintText: '이름을 입력하세요',
            prefixIcon: Icons.person_outline,
            errorText: _nameError,
            enabled: !_isLoading && !_codeSent,
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GymTextField(
                  controller: _phoneController,
                  labelText: '전화번호',
                  hintText: '01012345678',
                  prefixIcon: Icons.phone_outlined,
                  type: GymTextFieldType.phone,
                  errorText: _phoneError,
                  enabled: !_isLoading && !_codeSent,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                margin: const EdgeInsets.only(top: 24),
                child: GymButton(
                  text: _codeSent ? '재전송' : '인증번호 발송',
                  onPressed: _sendVerificationCode,
                  size: GymButtonSize.medium,
                  style: GymButtonStyle.outlined,
                  fullWidth: false,
                  loading: _isLoading,
                ),
              ),
            ],
          ),

          if (_codeSent) ...[
            const SizedBox(height: AppSpacing.md),
            GymTextField(
              controller: _verificationCodeController,
              labelText: '인증번호',
              hintText: '6자리 인증번호',
              prefixIcon: Icons.security,
              type: GymTextFieldType.number,
              errorText: _verificationCodeError,
              enabled: !_isLoading,
              maxLength: 6,
              suffixIcon: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  _formatTime(_remainingSeconds),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: _remainingSeconds < 60
                        ? AppColors.error
                        : AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            GymButton(
              text: '아이디 찾기',
              onPressed: _findId,
              loading: _isLoading,
              size: GymButtonSize.large,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFoundIdResult() {
    return Center(
      child: Padding(
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
              '아이디를 찾았습니다',
              style: AppTextStyles.h2,
            ),

            const SizedBox(height: AppSpacing.lg),

            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Column(
                children: [
                  Text(
                    '귀하의 아이디는',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _foundLoginId ?? '',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '입니다',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            GymButton(
              text: '로그인하러 가기',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              size: GymButtonSize.large,
            ),

            const SizedBox(height: AppSpacing.md),

            GymButton(
              text: '다시 찾기',
              onPressed: _reset,
              style: GymButtonStyle.outlined,
              size: GymButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }
}

// Find Password Tab
class FindPasswordTab extends StatefulWidget {
  const FindPasswordTab({super.key});

  @override
  State<FindPasswordTab> createState() => _FindPasswordTabState();
}

class _FindPasswordTabState extends State<FindPasswordTab> {
  final _loginIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _loginIdError;
  String? _nameError;
  String? _emailError;
  String? _verificationCodeError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  bool _isLoading = false;
  bool _codeSent = false;
  bool _codeVerified = false;
  bool _passwordReset = false;

  Timer? _timer;
  int _remainingSeconds = 180;

  @override
  void dispose() {
    _loginIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _verificationCodeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 180;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            _codeSent = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('인증 시간이 만료되었습니다. 다시 시도해주세요.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _sendVerificationCode() async {
    setState(() {
      _loginIdError = null;
      _nameError = null;
      _emailError = null;
    });

    final loginIdError = Validators.validateLoginId(_loginIdController.text);
    if (loginIdError != null) {
      setState(() => _loginIdError = loginIdError);
      return;
    }

    final nameError = Validators.validateName(_nameController.text);
    if (nameError != null) {
      setState(() => _nameError = nameError);
      return;
    }

    final emailError = Validators.validateEmail(_emailController.text);
    if (emailError != null) {
      setState(() => _emailError = emailError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _codeSent = true;
          _isLoading = false;
        });
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인증번호가 이메일로 발송되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('인증번호 발송 실패: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _verifyCode() async {
    setState(() => _verificationCodeError = null);

    if (_verificationCodeController.text.trim().isEmpty) {
      setState(() => _verificationCodeError = '인증번호를 입력해주세요');
      return;
    }

    if (_verificationCodeController.text.trim().length != 6) {
      setState(() => _verificationCodeError = '인증번호는 6자리입니다');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _codeVerified = true;
          _isLoading = false;
        });
        _timer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인증이 완료되었습니다. 새 비밀번호를 설정해주세요.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _verificationCodeError = '인증번호가 올바르지 않습니다';
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    final passwordError = Validators.validatePassword(_newPasswordController.text);
    if (passwordError != null) {
      setState(() => _newPasswordError = passwordError);
      return;
    }

    final confirmError = Validators.validatePasswordConfirm(
      _confirmPasswordController.text,
      _newPasswordController.text,
    );
    if (confirmError != null) {
      setState(() => _confirmPasswordError = confirmError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _passwordReset = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호 재설정 실패: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _reset() {
    setState(() {
      _loginIdController.clear();
      _nameController.clear();
      _emailController.clear();
      _verificationCodeController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _loginIdError = null;
      _nameError = null;
      _emailError = null;
      _verificationCodeError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
      _codeSent = false;
      _codeVerified = false;
      _passwordReset = false;
      _remainingSeconds = 180;
    });
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_passwordReset) {
      return _buildPasswordResetResult();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),

          Icon(
            Icons.lock_reset,
            size: 80,
            color: AppColors.primary.withOpacity(0.7),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            _codeVerified
                ? '새 비밀번호를\n설정해주세요'
                : '비밀번호를 재설정하기 위해\n본인 정보를 입력해주세요',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xl),

          if (!_codeVerified) ...[
            GymTextField(
              controller: _loginIdController,
              labelText: '아이디',
              hintText: '아이디를 입력하세요',
              prefixIcon: Icons.person_outline,
              errorText: _loginIdError,
              enabled: !_isLoading && !_codeSent,
            ),

            const SizedBox(height: AppSpacing.md),

            GymTextField(
              controller: _nameController,
              labelText: '이름',
              hintText: '이름을 입력하세요',
              prefixIcon: Icons.person_outline,
              errorText: _nameError,
              enabled: !_isLoading && !_codeSent,
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GymTextField(
                    controller: _emailController,
                    labelText: '이메일',
                    hintText: 'example@email.com',
                    prefixIcon: Icons.email_outlined,
                    type: GymTextFieldType.email,
                    errorText: _emailError,
                    enabled: !_isLoading && !_codeSent,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  child: GymButton(
                    text: _codeSent ? '재전송' : '인증번호 발송',
                    onPressed: _sendVerificationCode,
                    size: GymButtonSize.medium,
                    style: GymButtonStyle.outlined,
                    fullWidth: false,
                    loading: _isLoading,
                  ),
                ),
              ],
            ),

            if (_codeSent) ...[
              const SizedBox(height: AppSpacing.md),
              GymTextField(
                controller: _verificationCodeController,
                labelText: '인증번호',
                hintText: '6자리 인증번호',
                prefixIcon: Icons.security,
                type: GymTextFieldType.number,
                errorText: _verificationCodeError,
                enabled: !_isLoading,
                maxLength: 6,
                suffixIcon: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    _formatTime(_remainingSeconds),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: _remainingSeconds < 60
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              GymButton(
                text: '인증번호 확인',
                onPressed: _verifyCode,
                loading: _isLoading,
                size: GymButtonSize.large,
              ),
            ],
          ] else ...[
            GymTextField(
              controller: _newPasswordController,
              labelText: '새 비밀번호',
              hintText: '8자 이상, 영문자와 숫자 포함',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              type: GymTextFieldType.password,
              errorText: _newPasswordError,
              enabled: !_isLoading,
            ),

            const SizedBox(height: AppSpacing.md),

            GymTextField(
              controller: _confirmPasswordController,
              labelText: '새 비밀번호 확인',
              hintText: '비밀번호를 다시 입력하세요',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              type: GymTextFieldType.password,
              errorText: _confirmPasswordError,
              enabled: !_isLoading,
            ),

            const SizedBox(height: AppSpacing.xl),

            GymButton(
              text: '비밀번호 재설정',
              onPressed: _resetPassword,
              loading: _isLoading,
              size: GymButtonSize.large,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordResetResult() {
    return Center(
      child: Padding(
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
              '비밀번호 재설정 완료',
              style: AppTextStyles.h2,
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              '비밀번호가 성공적으로 재설정되었습니다.\n새 비밀번호로 로그인해주세요.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey700,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            GymButton(
              text: '로그인하러 가기',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              size: GymButtonSize.large,
            ),

            const SizedBox(height: AppSpacing.md),

            GymButton(
              text: '다시 재설정하기',
              onPressed: _reset,
              style: GymButtonStyle.outlined,
              size: GymButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }
}
