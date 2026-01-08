import 'package:app/config/http.dart';
import 'package:app/model/user.dart';
import 'package:app/model/gym.dart';

enum NotificationType {
  general(0, '일반 알림'),
  membershipExpiry(1, '이용권 만료'),
  membershipNearExpiry(2, '이용권 만료 임박'),
  attendanceEncourage(3, '출석 독려'),
  gymAnnouncement(4, '체육관 공지'),
  systemNotice(5, '시스템 공지'),
  paymentConfirm(6, '결제 확인'),
  pauseExpiry(7, '일시정지 만료'),
  weeklyGoalAchieved(8, '주간 목표 달성'),
  personalRecord(9, '개인 기록 갱신'),
  test(10, '테스트');

  const NotificationType(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationType fromCode(int code) {
    return NotificationType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => NotificationType.general,
    );
  }
}

enum SendStatus {
  pending(0, '대기'),
  success(1, '성공'),
  failed(2, '실패');

  const SendStatus(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static SendStatus fromCode(int code) {
    return SendStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => SendStatus.pending,
    );
  }
}

class NotificationHistory {
  int id;
  int? senderId;
  int receiverId;
  int? gymId;
  NotificationType type;
  String title;
  String body;
  String data;
  SendStatus status;
  String? errorMessage;
  String sentDate;
  String date;
  Map<String, dynamic> extra;

  // 확장 정보
  User? sender;
  User? receiver;
  Gym? gym;

  NotificationHistory({
    this.id = 0,
    this.senderId,
    this.receiverId = 0,
    this.gymId,
    this.type = NotificationType.general,
    this.title = '',
    this.body = '',
    this.data = '',
    this.status = SendStatus.pending,
    this.errorMessage,
    this.sentDate = '',
    this.date = '',
    this.extra = const {},
    this.sender,
    this.receiver,
    this.gym,
  });

  factory NotificationHistory.fromJson(Map<String, dynamic> json) {
    final extra = json['extra'] as Map<String, dynamic>? ?? {};

    return NotificationHistory(
      id: json['id'] as int? ?? 0,
      senderId: json['senderId'] as int?,
      receiverId: json['receiverId'] as int? ?? 0,
      gymId: json['gymId'] as int?,
      type: NotificationType.fromCode(json['type'] as int? ?? 0),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: json['data'] as String? ?? '',
      status: SendStatus.fromCode(json['status'] as int? ?? 0),
      errorMessage: json['errorMessage'] as String?,
      sentDate: json['sentDate'] as String? ?? '',
      date: json['date'] as String? ?? '',
      extra: extra,
      sender: extra['sender'] != null ? User.fromJson(extra['sender']) : null,
      receiver: extra['receiver'] != null ? User.fromJson(extra['receiver']) : null,
      gym: extra['gym'] != null ? Gym.fromJson(extra['gym']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'gymId': gymId,
        'type': type.code,
        'title': title,
        'body': body,
        'data': data,
        'status': status.code,
        'errorMessage': errorMessage,
        'sentDate': sentDate,
        'date': date,
      };

  NotificationHistory clone() {
    return NotificationHistory.fromJson(toJson());
  }
}

class NotificationHistoryManager {
  static const baseUrl = '/api/notification-history';

  /// 사용자가 받은 알림 이력 조회
  static Future<List<NotificationHistory>> getUserHistory(
    int userId, {
    int page = 0,
    int size = 20,
  }) async {
    var result = await Http.get('$baseUrl/user/$userId', {'page': page, 'size': size});
    if (result == null || result['success'] != true || result['content'] == null) {
      return [];
    }

    return (result['content'] as List).map((json) => NotificationHistory.fromJson(json)).toList();
  }

  /// 체육관 관련 알림 이력 조회
  static Future<List<NotificationHistory>> getGymHistory(
    int gymId, {
    int page = 0,
    int size = 20,
  }) async {
    var result = await Http.get('$baseUrl/gym/$gymId', {'page': page, 'size': size});
    if (result == null || result['success'] != true || result['content'] == null) {
      return [];
    }

    return (result['content'] as List).map((json) => NotificationHistory.fromJson(json)).toList();
  }

  /// 알림 타입별 이력 조회
  static Future<List<NotificationHistory>> getHistoryByType(
    NotificationType type, {
    int page = 0,
    int size = 20,
  }) async {
    var result = await Http.get('$baseUrl/type/${type.code}', {'page': page, 'size': size});
    if (result == null || result['success'] != true || result['content'] == null) {
      return [];
    }

    return (result['content'] as List).map((json) => NotificationHistory.fromJson(json)).toList();
  }

  /// 사용자의 특정 타입 알림 이력 조회
  static Future<List<NotificationHistory>> getUserHistoryByType(
    int userId,
    NotificationType type, {
    int page = 0,
    int size = 20,
  }) async {
    var result = await Http.get('$baseUrl/user/$userId/type/${type.code}', {'page': page, 'size': size});
    if (result == null || result['success'] != true || result['content'] == null) {
      return [];
    }

    return (result['content'] as List).map((json) => NotificationHistory.fromJson(json)).toList();
  }

  /// 기간별 알림 이력 조회
  static Future<List<NotificationHistory>> getHistoryByDateRange(
    String startDate,
    String endDate, {
    int page = 0,
    int size = 20,
  }) async {
    var result = await Http.get('$baseUrl/date-range', {
      'startDate': startDate,
      'endDate': endDate,
      'page': page,
      'size': size,
    });
    if (result == null || result['success'] != true || result['content'] == null) {
      return [];
    }

    return (result['content'] as List).map((json) => NotificationHistory.fromJson(json)).toList();
  }

  /// 전송 상태별 이력 조회
  static Future<List<NotificationHistory>> getHistoryByStatus(
    SendStatus status, {
    int page = 0,
    int size = 20,
  }) async {
    var result = await Http.get('$baseUrl/status/${status.code}', {'page': page, 'size': size});
    if (result == null || result['success'] != true || result['content'] == null) {
      return [];
    }

    return (result['content'] as List).map((json) => NotificationHistory.fromJson(json)).toList();
  }

  /// 특정 알림 상세 조회
  static Future<NotificationHistory?> getById(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['success'] != true || result['data'] == null) {
      return null;
    }

    return NotificationHistory.fromJson(result['data']);
  }
}
