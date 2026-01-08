import 'package:app/config/http.dart';

enum NotificationEnabled {
  enabled(0, '켜짐'),
  disabled(1, '꺼짐');

  const NotificationEnabled(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationEnabled fromCode(int code) {
    return NotificationEnabled.values.firstWhere(
      (e) => e.code == code,
      orElse: () => NotificationEnabled.enabled,
    );
  }

  bool get isEnabled => this == NotificationEnabled.enabled;
}

class NotificationSetting {
  int id;
  int userId;
  NotificationEnabled enabled;
  NotificationEnabled membershipExpiry;
  NotificationEnabled membershipNearExpiry;
  NotificationEnabled attendanceEncourage;
  NotificationEnabled gymAnnouncement;
  NotificationEnabled systemNotice;
  NotificationEnabled paymentConfirm;
  NotificationEnabled pauseExpiry;
  NotificationEnabled weeklyGoalAchieved;
  NotificationEnabled personalRecord;
  NotificationEnabled quietHoursEnabled;
  String? quietHoursStart; // HH:mm 형식
  String? quietHoursEnd; // HH:mm 형식
  String createdDate;
  String updatedDate;
  String date;
  Map<String, dynamic> extra;

  NotificationSetting({
    this.id = 0,
    this.userId = 0,
    this.enabled = NotificationEnabled.enabled,
    this.membershipExpiry = NotificationEnabled.enabled,
    this.membershipNearExpiry = NotificationEnabled.enabled,
    this.attendanceEncourage = NotificationEnabled.enabled,
    this.gymAnnouncement = NotificationEnabled.enabled,
    this.systemNotice = NotificationEnabled.enabled,
    this.paymentConfirm = NotificationEnabled.enabled,
    this.pauseExpiry = NotificationEnabled.enabled,
    this.weeklyGoalAchieved = NotificationEnabled.enabled,
    this.personalRecord = NotificationEnabled.enabled,
    this.quietHoursEnabled = NotificationEnabled.disabled,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.createdDate = '',
    this.updatedDate = '',
    this.date = '',
    this.extra = const {},
  });

  factory NotificationSetting.fromJson(Map<String, dynamic> json) {
    return NotificationSetting(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      enabled: NotificationEnabled.fromCode(json['enabled'] as int? ?? 0),
      membershipExpiry: NotificationEnabled.fromCode(json['membershipExpiry'] as int? ?? 0),
      membershipNearExpiry: NotificationEnabled.fromCode(json['membershipNearExpiry'] as int? ?? 0),
      attendanceEncourage: NotificationEnabled.fromCode(json['attendanceEncourage'] as int? ?? 0),
      gymAnnouncement: NotificationEnabled.fromCode(json['gymAnnouncement'] as int? ?? 0),
      systemNotice: NotificationEnabled.fromCode(json['systemNotice'] as int? ?? 0),
      paymentConfirm: NotificationEnabled.fromCode(json['paymentConfirm'] as int? ?? 0),
      pauseExpiry: NotificationEnabled.fromCode(json['pauseExpiry'] as int? ?? 0),
      weeklyGoalAchieved: NotificationEnabled.fromCode(json['weeklyGoalAchieved'] as int? ?? 0),
      personalRecord: NotificationEnabled.fromCode(json['personalRecord'] as int? ?? 0),
      quietHoursEnabled: NotificationEnabled.fromCode(json['quietHoursEnabled'] as int? ?? 1),
      quietHoursStart: json['quietHoursStart'] as String?,
      quietHoursEnd: json['quietHoursEnd'] as String?,
      createdDate: json['createdDate'] as String? ?? '',
      updatedDate: json['updatedDate'] as String? ?? '',
      date: json['date'] as String? ?? '',
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'enabled': enabled.code,
        'membershipExpiry': membershipExpiry.code,
        'membershipNearExpiry': membershipNearExpiry.code,
        'attendanceEncourage': attendanceEncourage.code,
        'gymAnnouncement': gymAnnouncement.code,
        'systemNotice': systemNotice.code,
        'paymentConfirm': paymentConfirm.code,
        'pauseExpiry': pauseExpiry.code,
        'weeklyGoalAchieved': weeklyGoalAchieved.code,
        'personalRecord': personalRecord.code,
        'quietHoursEnabled': quietHoursEnabled.code,
        'quietHoursStart': quietHoursStart,
        'quietHoursEnd': quietHoursEnd,
        'createdDate': createdDate,
        'updatedDate': updatedDate,
        'date': date,
      };

  NotificationSetting clone() {
    return NotificationSetting.fromJson(toJson());
  }
}

class NotificationSettingManager {
  static const baseUrl = '/api/notification-settings';

  /// 사용자 알림 설정 조회
  static Future<NotificationSetting?> getUserSetting(int userId) async {
    var result = await Http.get('$baseUrl/user/$userId');
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
  static Future<bool> createUserSetting(int userId) async {
    var result = await Http.post('$baseUrl/user/$userId', {});
    return result != null && result['success'] == true;
  }

  /// 전체 알림 ON/OFF 토글
  static Future<bool> toggleAllNotifications(int userId, bool enabled) async {
    var result = await Http.patch('$baseUrl/user/$userId/toggle-all?enabled=$enabled', {});
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
    var result = await Http.patch('$baseUrl/user/$userId/type?$queryString', {});
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
    var result = await Http.patch('$baseUrl/user/$userId/quiet-hours?$queryString', {});
    return result != null && result['success'] == true;
  }

  /// 알림 설정 삭제
  static Future<bool> deleteUserSetting(int userId) async {
    var result = await Http.delete('$baseUrl/user/$userId', {});
    return result != null && result['success'] == true;
  }

  /// 알림을 보낼지 확인
  static Future<bool> shouldSendNotification(int userId, int type) async {
    var result = await Http.get('$baseUrl/user/$userId/should-send?type=$type');
    if (result == null || result['success'] != true) {
      return true; // 에러 시 기본값으로 허용
    }
    return result['shouldSend'] == true;
  }
}
