import 'package:app/config/config.dart';
import 'package:app/config/http.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/user.dart';
import '../model/login.dart';
import '../config/cconfig.dart';
import '../services/notification_service.dart';

/// Authentication state management provider
/// Manages user login/logout state, authentication tokens, and user data
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get error => _error;

  /// Login with credentials
  Future<bool> login(
    String loginId,
    String password, {
    bool rememberMe = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // LoginManager 사용하여 로그인
      final user = await LoginManager.login(loginId, password);

      // 디버그: 로그인 응답 확인
      debugPrint('=== Login Response ===');
      debugPrint('User ID: ${user.id}');
      debugPrint('User Name: ${user.name}');
      debugPrint('User Email: ${user.email}');
      debugPrint('Token exists: ${user.extra['token'] != null}');
      debugPrint('Token: ${user.extra['token']}');
      debugPrint('Extra: ${user.extra}');

      // 로그인 성공 확인 (user.id가 0이 아니면 성공)
      if (user.id != 0 && user.extra['token'] != null) {
        // 사용자 정보 저장
        _currentUser = user;
        _currentUser!.extra['rememberMe'] = rememberMe;

        // 토큰 저장
        _token = user.extra['token'] as String;
        CConfig().token = _token!;

        _isAuthenticated = true;

        // 자동 로그인 정보 저장
        if (rememberMe) {
          await _saveAuthData();
        }

        // FCM 토큰을 서버에 전송
        try {
          final notificationService = NotificationService();
          await notificationService.sendTokenToServer(userId: user.id);
        } catch (e) {
          debugPrint('FCM 토큰 전송 실패: $e');
        }

        _isLoading = false;
        notifyListeners();

        debugPrint('Login successful!');
        return true;
      } else {
        debugPrint('Login failed - user.id: ${user.id}, token: ${user.extra['token']}');
        _error = '로그인에 실패했습니다. 아이디와 비밀번호를 확인해주세요.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _error = '네트워크 오류가 발생했습니다: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Save authentication data to local storage
  Future<void> _saveAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token ?? '');
      if (_currentUser != null) {
        await prefs.setString('user_data', jsonEncode(_currentUser!.toJson()));
      }
    } catch (e) {
      debugPrint('Failed to save auth data: $e');
    }
  }

  /// Clear saved authentication data
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
    } catch (e) {
      debugPrint('Failed to clear auth data: $e');
    }
  }

  /// Social login (Kakao, Naver, Google, Apple)
  Future<bool> socialLogin(
    String provider,
    String accessToken, {
    bool rememberMe = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      User user;

      // 제공자별로 적절한 LoginManager 메서드 호출
      switch (provider.toLowerCase()) {
        case 'kakao':
          user = await LoginManager.kakaoLogin('kakao', accessToken);
          break;
        case 'naver':
          user = await LoginManager.naverLogin('naver', accessToken);
          break;
        case 'google':
          user = await LoginManager.googleLogin('google', accessToken);
          break;
        case 'apple':
          user = await LoginManager.appleLogin('apple', accessToken);
          break;
        default:
          _error = '지원하지 않는 로그인 제공자입니다.';
          _isLoading = false;
          notifyListeners();
          return false;
      }

      // 로그인 성공 확인
      if (user.id != 0 && user.extra['token'] != null) {
        _currentUser = user;
        _currentUser!.extra['rememberMe'] = rememberMe;
        _currentUser!.extra['socialProvider'] = provider;

        _token = user.extra['token'] as String;
        CConfig().token = _token!;

        _isAuthenticated = true;

        // 자동 로그인 정보 저장
        if (rememberMe) {
          await _saveAuthData();
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = '소셜 로그인에 실패했습니다.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '네트워크 오류가 발생했습니다: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up new user
  Future<bool> signup(User user, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // POST /api/user
      final result = await Http.post(Config.apiUser, {
        'loginid': user.loginid,
        'passwd': password,
        'email': user.email,
        'name': user.name,
        'tel': user.tel,
        'address': user.address ?? '',
        'image': user.image ?? '',
        'sex': user.sex ?? 0,
        'birth': user.birth ?? '',
        'type': user.type ?? 0,
        'connectid': user.connectid ?? '',
        'level': user.level ?? 0,
        'role': user.role ?? 3, // MEMBER
        'use': user.use ?? 0,
      });

      if (result != null && result['id'] != null) {
        // 회원가입 성공 후 자동 로그인
        return await login(user.loginid, password);
      } else {
        _error = '회원가입에 실패했습니다.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '네트워크 오류가 발생했습니다: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual logout API call
      await Future.delayed(const Duration(milliseconds: 500));

      // 저장된 로그인 정보 삭제
      await _clearAuthData();

      _currentUser = null;
      _token = null;
      CConfig().token = '';
      _isAuthenticated = false;
      _error = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile(User updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // PUT /api/user/{id}
      final success = await Http.put('${Config.apiUser}/${updatedUser.id}', {
        'loginid': updatedUser.loginid,
        'email': updatedUser.email,
        'name': updatedUser.name,
        'tel': updatedUser.tel,
        'address': updatedUser.address ?? '',
        'image': updatedUser.image ?? '',
        'sex': updatedUser.sex ?? 0,
        'birth': updatedUser.birth ?? '',
        'type': updatedUser.type ?? 0,
        'connectid': updatedUser.connectid ?? '',
        'level': updatedUser.level ?? 0,
        'role': updatedUser.role ?? 3,
        'use': updatedUser.use ?? 0,
      });

      if (success == true) {
        _currentUser = updatedUser;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = '프로필 업데이트에 실패했습니다.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '네트워크 오류가 발생했습니다: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Check if login ID exists (for duplicate check during signup)
  Future<bool> checkLoginIdExists(String loginId) async {
    try {
      // GET /api/user/search/loginid?loginid=xxx
      final result = await Http.get('${Config.apiUser}/search/loginid', {
        'loginid': loginId,
      });

      if (result != null && result is List && result.isNotEmpty) {
        return true; // 이미 존재함
      }
      return false; // 사용 가능
    } catch (e) {
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(
    String loginId,
    String verificationCode,
    String newPassword,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Find user ID by name and phone
  Future<String?> findUserId(
    String name,
    String phone,
    String verificationCode,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
      notifyListeners();

      // Mock: return masked ID
      return 'user***';
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Load saved authentication state (for app startup)
  Future<void> loadSavedAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      final savedUserData = prefs.getString('user_data');

      if (savedToken != null &&
          savedToken.isNotEmpty &&
          savedUserData != null) {
        // 저장된 토큰과 사용자 정보 복원
        _token = savedToken;
        CConfig().token = _token!;

        final userData = jsonDecode(savedUserData) as Map<String, dynamic>;
        _currentUser = User.fromJson(userData);
        _isAuthenticated = true;

        debugPrint('Auto-login successful for user: ${_currentUser?.loginid}');
      } else {
        _isAuthenticated = false;
        debugPrint('No saved auth data found');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load saved auth: $e');
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    }
  }
}
