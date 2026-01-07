import 'dart:io';

/// 앱 전체 설정 관리 클래스
/// 서버 URL, 플랫폼 정보 등 전역 설정을 관리합니다.
class Config {
  /// API 서버 URL
  /// 개발 환경에 맞게 변경하세요.
  ///
  /// 예시:
  /// - 로컬: 'http://localhost:8004'
  /// - 개발: 'http://10.0.1.62:8004'
  /// - 운영: 'https://api.yourdomain.com'
  ///
  /// Note:
  /// - Android 에뮬레이터: 10.0.2.2 (호스트 머신의 localhost) - 네트워크 문제로 10.0.1.62 사용
  /// - 실제 Android/iOS 기기: WiFi IP 주소 (예: 10.0.1.62)
  // static const serverUrl = 'http://10.0.2.2:8004'; // Android 에뮬레이터용
  // static const serverUrl = 'http://10.0.1.62:8004'; // 실제 WiFi IP
  // static const serverUrl = 'http://localhost:8004';
  static const serverUrl = 'http://140.82.12.99:8004';
  // static const serverUrl = 'http://127.0.0.1:8004';

  /// API 엔드포인트 상수
  static const apiAuth = '/api/auth';
  static const apiUser = '/api/user';
  static const apiGym = '/api/gym';
  static const apiMembership = '/api/membership';
  static const apiPayment = '/api/payment';
  static const apiAttendance = '/api/attendance';
  static const apiHealth = '/api/health';
  static const apiNotice = '/api/notice';
  static const apiInquiry = '/api/inquiry';

  /// 현재 플랫폼 확인
  /// Android, iOS, Web 중 하나를 반환
  static String platform() {
    try {
      if (Platform.isAndroid) {
        return 'android';
      } else if (Platform.isIOS) {
        return 'ios';
      }
    } catch (e) {
      return 'web';
    }

    return 'web';
  }

  /// 플랫폼별 체크
  static bool get isAndroid {
    try {
      return Platform.isAndroid;
    } catch (e) {
      return false;
    }
  }

  static bool get isIOS {
    try {
      return Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  static bool get isWeb => platform() == 'web';
}
