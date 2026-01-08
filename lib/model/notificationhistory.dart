import 'package:app/config/http.dart';


enum NotificationhistoryType {
  none(0, ''),
  general(1, '일반'),
  membership_expiry(2, '이용권만료'),
  membership_near_expiry(3, '이용권임박'),
  attendance_encourage(4, '출석독려'),
  gym_announcement(5, '체육관공지'),
  system_notice(6, '시스템공지'),
  payment_confirm(7, '결제확인'),
  pause_expiry(8, '일시정지만료'),
  weekly_goal_achieved(9, '주간목표달성'),
  personal_record(10, '개인기록갱신'),
;

  const NotificationhistoryType(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationhistoryType fromCode(int code) {
    return NotificationhistoryType.values.firstWhere((e) => e.code == code, orElse: () => NotificationhistoryType.none);
  }
}

enum NotificationhistoryStatus {
  none(0, ''),
  pending(1, '대기중'),
  success(2, '성공'),
  failed(3, '실패'),
;

  const NotificationhistoryStatus(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationhistoryStatus fromCode(int code) {
    return NotificationhistoryStatus.values.firstWhere((e) => e.code == code, orElse: () => NotificationhistoryStatus.none);
  }
}

class Notificationhistory {
  int id;
  int sender;
  int receiver;
  int gym;
  NotificationhistoryType type;
  String title;
  String body;
  String data;
  NotificationhistoryStatus status;
  String errormessage;
  String sentdate;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Notificationhistory({
    this.id = 0,
    this.sender = 0,
    this.receiver = 0,
    this.gym = 0,
    this.type = NotificationhistoryType.none,
    this.title = '',
    this.body = '',
    this.data = '',
    this.status = NotificationhistoryStatus.none,
    this.errormessage = '',
    this.sentdate = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Notificationhistory.fromJson(Map<String, dynamic> json) {
    return Notificationhistory(
      id: json['id'] as int,
      sender: json['sender'] as int,
      receiver: json['receiver'] as int,
      gym: json['gym'] as int,
      type: NotificationhistoryType.fromCode(json['type'] as int),
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as String,
      status: NotificationhistoryStatus.fromCode(json['status'] as int),
      errormessage: json['errormessage'] as String,
      sentdate: json['sentdate'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender': sender,
    'receiver': receiver,
    'gym': gym,
    'type': type.code,
    'title': title,
    'body': body,
    'data': data,
    'status': status.code,
    'errormessage': errormessage,
    'sentdate': sentdate,
    'date': date,
  };

  Notificationhistory clone() {
    return Notificationhistory.fromJson(toJson());
  }
}

class NotificationhistoryManager {
  static const baseUrl = '/api/notificationhistory';

  static Future<List<Notificationhistory>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['content'] == null) {
      return List<Notificationhistory>.empty(growable: true);
    }

    return result['content'].map<Notificationhistory>((json) => Notificationhistory.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Notificationhistory> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Notificationhistory();
    }

    return Notificationhistory.fromJson(result);
  }

  static Future<int> insert(Notificationhistory item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Notificationhistory item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Notificationhistory item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
