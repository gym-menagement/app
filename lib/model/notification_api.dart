import 'package:app/config/http.dart';
import 'package:app/model/notification_history.dart';
import 'package:app/model/notification_setting.dart';

/**
 * 알림 API 클라이언트
 *
 * 자동 생성된 notificationhistory.dart, notificationsetting.dart와 분리하여
 * 커스텀 비즈니스 로직을 관리합니다.
 */
class NotificationApi {
  static const baseUrl = '/api/notification';

  // ==================== 알림 이력 조회 ====================

  /// 사용자가 받은 알림 이력 조회
  static Future<List<NotificationHistory>> getUserHistory(
    int userId, {
    int page = 0,
    int size = 20,
  }) async {
    var result = await Http.get('$baseUrl/history/user/$userId', {
      'page': page,
      'size': size,
    });

    if (result == null || result['success'] != true || result['content'] == null) {
      return [];
    }

    return (result['content'] as List)
        .map((json) => NotificationHistory.fromJson(json))
        .toList();
  }

  /// 체육관 관련 알림 이력 조회
  static Future<List<NotificationHistory>> getGymHistory(
    int gymId, {
    int page = 0,
    int size = 20,
  }) async {
    var result = await Http.get('$baseUrl/history/gym/$gymId', {
      'page': page,
      'size': size,
    });

    if (result == null || result['success'] != true || result['content'] == null) {
      return [];
    }

    return (result['content'] as List)
        .map((json) => NotificationHistory.fromJson(json))
        .toList();
  }

  /// 알림 타입별 이력 조회
  static Future<List<NotificationHistory>> getHistoryByType(
    NotificationType type, {
    int page = 0,
    int size = 20,
  }) async {
    var result = await Http.get('$baseUrl/history/type/${type.code}', {
      'page': page,
      'size': size,
    });

    if (result == null || result['success'] != true || result['content'] == null) {
      return [];
    }

    return (result['content'] as List)
        .map((json) => NotificationHistory.fromJson(json))
        .toList();
  }

  /// 사용자의 특정 타입 알림 이력 조회
  static Future<List<NotificationHistory>> getUserHistoryByType(
    int userId,
    NotificationType type, {
    int page = 0,
    int size = 20,
  }) async {
    var result = await Http.get('$baseUrl/history/user/$userId/type/${type.code}', {
      'page': page,
      'size': size,
    });

    if (result == null || result['success'] != true || result['content'] == null) {
      return [];
    }

    return (result['content'] as List)
        .map((json) => NotificationHistory.fromJson(json))
        .toList();
  }

  /// 특정 알림 상세 조회
  static Future<NotificationHistory?> getHistoryById(int id) async {
    var result = await Http.get('$baseUrl/history/$id');

    if (result == null || result['success'] != true || result['data'] == null) {
      return null;
    }

    return NotificationHistory.fromJson(result['data']);
  }

  // ==================== 알림 설정 ====================

  /// 사용자 알림 설정 조회
  static Future<NotificationSetting?> getUserSettings(int userId) async {
    var result = await Http.get('$baseUrl/settings/user/$userId');

    if (result == null || result['success'] != true) {
      return null;
    }

    if (result['data'] == null) {
      // 설정이 없으면 기본값 반환
      return NotificationSetting(userId: userId);
    }

    return NotificationSetting.fromJson(result['data']);
  }

  /// 사용자 알림 설정 생성
  static Future<bool> createUserSettings(int userId) async {
    var result = await Http.post('$baseUrl/settings/user/$userId', {});
    return result != null && result['success'] == true;
  }

  /// 전체 알림 ON/OFF 토글
  static Future<bool> toggleAllNotifications(int userId, bool enabled) async {
    var result = await Http.patch(
      '$baseUrl/settings/user/$userId/toggle-all?enabled=$enabled',
      {}
    );
    return result != null && result['success'] == true;
  }

  /// 특정 알림 타입 설정
  static Future<bool> updateNotificationType(
    int userId, {
    bool? membershipExpiry,
    bool? membershipNearExpiry,
    bool? attendanceEncourage,
    bool? gymAnnouncement,
    bool? systemNotice,
    bool? paymentConfirm,
    bool? pauseExpiry,
    bool? weeklyGoalAchieved,
    bool? personalRecord,
  }) async {
    var params = <String, String>{};
    if (membershipExpiry != null) params['membershipExpiry'] = membershipExpiry.toString();
    if (membershipNearExpiry != null) params['membershipNearExpiry'] = membershipNearExpiry.toString();
    if (attendanceEncourage != null) params['attendanceEncourage'] = attendanceEncourage.toString();
    if (gymAnnouncement != null) params['gymAnnouncement'] = gymAnnouncement.toString();
    if (systemNotice != null) params['systemNotice'] = systemNotice.toString();
    if (paymentConfirm != null) params['paymentConfirm'] = paymentConfirm.toString();
    if (pauseExpiry != null) params['pauseExpiry'] = pauseExpiry.toString();
    if (weeklyGoalAchieved != null) params['weeklyGoalAchieved'] = weeklyGoalAchieved.toString();
    if (personalRecord != null) params['personalRecord'] = personalRecord.toString();

    var queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    var result = await Http.patch('$baseUrl/settings/user/$userId/type?$queryString', {});
    return result != null && result['success'] == true;
  }

  /// 방해 금지 시간 설정
  static Future<bool> updateQuietHours(
    int userId, {
    required bool enabled,
    String? startTime,
    String? endTime,
  }) async {
    var params = <String, String>{'enabled': enabled.toString()};
    if (enabled && startTime != null) params['startTime'] = startTime;
    if (enabled && endTime != null) params['endTime'] = endTime;

    var queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    var result = await Http.patch('$baseUrl/settings/user/$userId/quiet-hours?$queryString', {});
    return result != null && result['success'] == true;
  }

  /// 알림 설정 삭제
  static Future<bool> deleteUserSettings(int userId) async {
    var result = await Http.delete('$baseUrl/settings/user/$userId', {});
    return result != null && result['success'] == true;
  }

  /// 알림을 보낼지 확인
  static Future<bool> shouldSendNotification(int userId, int type) async {
    var result = await Http.get('$baseUrl/settings/user/$userId/should-send?type=$type');

    if (result == null || result['success'] != true) {
      return true; // 에러 시 기본값으로 허용
    }

    return result['shouldSend'] == true;
  }
}
