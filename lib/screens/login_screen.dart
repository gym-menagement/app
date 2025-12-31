import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/gym_textfield.dart';
import '../components/gym_button.dart';
import '../components/social_login_button.dart';
import '../components/gym_snackbar.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _idError;
  String? _passwordError;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _idError = null;
      _passwordError = null;
    });

    // Validation
    if (_idController.text.trim().isEmpty) {
      setState(() {
        _idError = '아이디를 입력해주세요';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = '비밀번호를 입력해주세요';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();

      // 로그인 API 호출
      final success = await authProvider.login(
        _idController.text.trim(),
        _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (!mounted) return;

      if (success) {
        // 로그인 성공 - 홈 화면으로 이동
        Navigator.of(context).pushReplacementNamed('/home');

        GymSnackbar.showSuccess(context: context, message: '로그인 성공!');
      } else {
        // 로그인 실패 - 에러 메시지 표시
        setState(() {
          _passwordError = authProvider.error ?? '로그인에 실패했습니다';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _passwordError = '네트워크 오류가 발생했습니다';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSocialLogin(SocialProvider provider) async {
    // TODO: Implement social login
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${provider.name} 로그인 구현 예정')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.massive),

              // Logo/Brand
              const Icon(
                Icons.fitness_center,
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Gym Manager',
                style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Login Form
              GymTextField(
                controller: _idController,
                hintText: '아이디를 입력하세요',
                labelText: '아이디',
                prefixIcon: Icons.person_outline,
                errorText: _idError,
                enabled: !_isLoading,
                textInputAction: TextInputAction.next,
                textAlign: TextAlign.center,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),

              const SizedBox(height: AppSpacing.md),

              GymTextField(
                controller: _passwordController,
                hintText: '비밀번호를 입력하세요',
                labelText: '비밀번호',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                errorText: _passwordError,
                enabled: !_isLoading,
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.center,
                onSubmitted: (_) => _handleLogin(),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Remember Me
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged:
                        _isLoading
                            ? null
                            : (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                    activeColor: AppColors.primary,
                  ),
                  Text('로그인 상태 유지', style: AppTextStyles.bodyMedium),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Login Button
              GymButton(
                text: '로그인',
                onPressed: _handleLogin,
                loading: _isLoading,
                size: GymButtonSize.large,
              ),

              const SizedBox(height: AppSpacing.md),

              // Links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                Navigator.pushNamed(context, '/find_id_pw');
                              },
                      child: Text(
                        '아이디/비밀번호 찾기',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  Container(height: 14, width: 1, color: AppColors.grey300),
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                Navigator.pushNamed(context, '/signup');
                              },
                      child: Text(
                        '회원가입',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      'OR',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Social Login Buttons
              SocialLoginButton(
                provider: SocialProvider.kakao,
                onPressed: () => _handleSocialLogin(SocialProvider.kakao),
              ),

              const SizedBox(height: AppSpacing.sm),

              SocialLoginButton(
                provider: SocialProvider.naver,
                onPressed: () => _handleSocialLogin(SocialProvider.naver),
              ),

              const SizedBox(height: AppSpacing.sm),

              SocialLoginButton(
                provider: SocialProvider.google,
                onPressed: () => _handleSocialLogin(SocialProvider.google),
              ),

              const SizedBox(height: AppSpacing.sm),

              SocialLoginButton(
                provider: SocialProvider.apple,
                onPressed: () => _handleSocialLogin(SocialProvider.apple),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
