import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  light('light', '라이트 모드'),
  dark('dark', '다크 모드'),
  system('system', '시스템 설정');

  const AppTheme(this.code, this.label);

  final String code;
  final String label;

  @override
  String toString() => label;

  static AppTheme fromCode(String code) {
    return AppTheme.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AppTheme.system,
    );
  }
}

enum AppLanguage {
  korean('ko', '한국어'),
  english('en', 'English');

  const AppLanguage(this.code, this.label);

  final String code;
  final String label;

  @override
  String toString() => label;

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AppLanguage.korean,
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _languageKey = 'app_language';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _marketingNotificationsKey = 'marketing_notifications';

  AppTheme _theme = AppTheme.system;
  AppLanguage _language = AppLanguage.korean;
  bool _notificationsEnabled = true;
  bool _marketingNotificationsEnabled = false;

  AppTheme get theme => _theme;
  AppLanguage get language => _language;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get marketingNotificationsEnabled => _marketingNotificationsEnabled;

  // ThemeMode 반환
  ThemeMode get themeMode {
    switch (_theme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }

  // 설정 로드
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeCode = prefs.getString(_themeKey);
      if (themeCode != null) {
        _theme = AppTheme.fromCode(themeCode);
      }

      final languageCode = prefs.getString(_languageKey);
      if (languageCode != null) {
        _language = AppLanguage.fromCode(languageCode);
      }

      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
      _marketingNotificationsEnabled =
          prefs.getBool(_marketingNotificationsKey) ?? false;

      notifyListeners();
    } catch (e) {
      debugPrint('설정 로드 실패: $e');
    }
  }

  // 테마 변경
  Future<void> setTheme(AppTheme theme) async {
    try {
      _theme = theme;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, theme.code);
    } catch (e) {
      debugPrint('테마 저장 실패: $e');
    }
  }

  // 언어 변경
  Future<void> setLanguage(AppLanguage language) async {
    try {
      _language = language;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);
    } catch (e) {
      debugPrint('언어 저장 실패: $e');
    }
  }

  // 알림 설정 변경
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      _notificationsEnabled = enabled;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);
    } catch (e) {
      debugPrint('알림 설정 저장 실패: $e');
    }
  }

  // 마케팅 알림 설정 변경
  Future<void> setMarketingNotificationsEnabled(bool enabled) async {
    try {
      _marketingNotificationsEnabled = enabled;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_marketingNotificationsKey, enabled);
    } catch (e) {
      debugPrint('마케팅 알림 설정 저장 실패: $e');
    }
  }

  // 캐시 삭제
  Future<bool> clearCache() async {
    try {
      // 여기에 캐시 삭제 로직 추가
      // 예: 이미지 캐시, 임시 파일 등
      await Future.delayed(const Duration(milliseconds: 500)); // 시뮬레이션
      return true;
    } catch (e) {
      debugPrint('캐시 삭제 실패: $e');
      return false;
    }
  }

  // 모든 설정 초기화
  Future<void> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeKey);
      await prefs.remove(_languageKey);
      await prefs.remove(_notificationsEnabledKey);
      await prefs.remove(_marketingNotificationsKey);

      _theme = AppTheme.system;
      _language = AppLanguage.korean;
      _notificationsEnabled = true;
      _marketingNotificationsEnabled = false;

      notifyListeners();
    } catch (e) {
      debugPrint('설정 초기화 실패: $e');
    }
  }
}
