import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/user.dart';
import '../config/http.dart';
import '../config/config.dart';
import '../config/cconfig.dart';

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
  Future<bool> login(String loginId, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // POST /api/auth/login
      final result = await Http.post('${Config.apiAuth}/login', {
        'loginid': loginId,
        'passwd': password,
      });

      if (result != null && result['token'] != null) {
        // 토큰 저장
        _token = result['token'];
        CConfig().token = _token!;

        // 사용자 정보 파싱
        if (result['user'] != null) {
          _currentUser = User.fromJson(result['user']);
          _currentUser!.extra['rememberMe'] = rememberMe;
        }

        _isAuthenticated = true;

        // 자동 로그인 정보 저장
        if (rememberMe) {
          await _saveAuthData();
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = '로그인에 실패했습니다. 아이디와 비밀번호를 확인해주세요.';
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
  Future<bool> socialLogin(String provider) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual social login API
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = User(
        id: 1,
        loginid: '${provider}_user',
        name: '${provider.toUpperCase()} User',
        email: 'user@$provider.com',
        tel: '010-0000-0000',
        date: DateTime.now().toString(),
        extra: {
          'socialProvider': provider,
        },
      );
      _token = 'mock_social_token_${DateTime.now().millisecondsSinceEpoch}';
      _isAuthenticated = true;

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
      final result = await Http.get('${Config.apiUser}/search/loginid', {'loginid': loginId});

      if (result != null && result is List && result.isNotEmpty) {
        return true; // 이미 존재함
      }
      return false; // 사용 가능
    } catch (e) {
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(String loginId, String verificationCode, String newPassword) async {
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
  Future<String?> findUserId(String name, String phone, String verificationCode) async {
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

      if (savedToken != null && savedToken.isNotEmpty && savedUserData != null) {
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
