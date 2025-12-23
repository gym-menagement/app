import 'package:flutter/foundation.dart';
import '../model/user.dart';

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
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful login
      _currentUser = User(
        id: 1,
        loginid: loginId,
        name: '홍길동',
        email: 'user@example.com',
        tel: '010-1234-5678',
        date: DateTime.now().toString(),
        extra: {
          'rememberMe': rememberMe,
        },
      );
      _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
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
      // TODO: Implement actual signup API
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = user;
      _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
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

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual logout API call
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = null;
      _token = null;
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
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = updatedUser;

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

  /// Check if login ID exists (for duplicate check during signup)
  Future<bool> checkLoginIdExists(String loginId) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock: loginIds starting with 'admin' are taken
      return loginId.toLowerCase().startsWith('admin');
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
      // TODO: Load from secure storage (e.g., flutter_secure_storage)
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock: No saved auth for now
      _isAuthenticated = false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
