import 'dart:io';

/// 앱 전체 설정 관리 클래스
/// 서버 URL, 플랫폼 정보 등 전역 설정을 관리합니다.
class Config {
  /// API 서버 URL. 뒤에 apiXxx 상수(`/api/...`)가 붙으므로 끝에 슬래시나
  /// `/api` 를 넣지 말 것.
  ///
  /// 운영은 nginx-proxy 가 TLS 를 종료하고 gym_api 컨테이너로 넘긴다.
  /// 예전엔 VPS 공인 IP 로 평문 8004 를 직접 때렸는데, 그 포트는 이제
  /// 호스트에 공개하지 않는다(컨테이너 네트워크 안에서만 열림).
  ///
  /// 로컬 개발 시엔 아래 주석 중 하나로 바꿔 쓰되 커밋하지 말 것.
  /// - Android 에뮬레이터: 10.0.2.2 (호스트의 localhost) — 네트워크 문제 시 WiFi IP
  /// - 실제 Android/iOS 기기: 개발 머신의 WiFi IP
  // static const serverUrl = 'http://10.0.2.2:8004'; // Android 에뮬레이터용
  // static const serverUrl = 'http://10.0.1.62:8004'; // 실제 WiFi IP
  // static const serverUrl = 'http://localhost:8004';
  static const serverUrl = 'https://gymspring.gowoobro.com';

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
