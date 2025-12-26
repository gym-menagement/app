import 'package:app/config/http.dart';


enum AttendanceType {
  none(0, ''),
  entry(1, '입장'),
  exit(2, '퇴장'),
;

  const AttendanceType(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static AttendanceType fromCode(int code) {
    return AttendanceType.values.firstWhere((e) => e.code == code, orElse: () => AttendanceType.none);
  }
}

enum AttendanceMethod {
  none(0, ''),
  qr_code(1, 'QR코드'),
  manual(2, '수동'),
  card(3, '카드'),
;

  const AttendanceMethod(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static AttendanceMethod fromCode(int code) {
    return AttendanceMethod.values.firstWhere((e) => e.code == code, orElse: () => AttendanceMethod.none);
  }
}

enum AttendanceStatus {
  none(0, ''),
  normal(1, '정상'),
  late(2, '지각'),
  unauthorized(3, '무단입장'),
;

  const AttendanceStatus(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static AttendanceStatus fromCode(int code) {
    return AttendanceStatus.values.firstWhere((e) => e.code == code, orElse: () => AttendanceStatus.none);
  }
}

class Attendance {
  int id;
  int user;
  int usehealth;
  int gym;
  AttendanceType type;
  AttendanceMethod method;
  String checkintime;
  String checkouttime;
  int duration;
  AttendanceStatus status;
  String note;
  String ip;
  String device;
  int createdby;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Attendance({
    this.id = 0,
    this.user = 0,
    this.usehealth = 0,
    this.gym = 0,
    this.type = AttendanceType.none,
    this.method = AttendanceMethod.none,
    this.checkintime = '',
    this.checkouttime = '',
    this.duration = 0,
    this.status = AttendanceStatus.none,
    this.note = '',
    this.ip = '',
    this.device = '',
    this.createdby = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as int,
      user: json['user'] as int,
      usehealth: json['usehealth'] as int,
      gym: json['gym'] as int,
      type: AttendanceType.fromCode(json['type'] as int),
      method: AttendanceMethod.fromCode(json['method'] as int),
      checkintime: json['checkintime'] as String,
      checkouttime: json['checkouttime'] as String,
      duration: json['duration'] as int,
      status: AttendanceStatus.fromCode(json['status'] as int),
      note: json['note'] as String,
      ip: json['ip'] as String,
      device: json['device'] as String,
      createdby: json['createdby'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'usehealth': usehealth,
    'gym': gym,
    'type': type.code,
    'method': method.code,
    'checkintime': checkintime,
    'checkouttime': checkouttime,
    'duration': duration,
    'status': status.code,
    'note': note,
    'ip': ip,
    'device': device,
    'createdby': createdby,
    'date': date,
  };

  Attendance clone() {
    return Attendance.fromJson(toJson());
  }
}

class AttendanceManager {
  static const baseUrl = '/api/attendance';

  static Future<List<Attendance>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Attendance>.empty(growable: true);
    }

    return result['items'].map<Attendance>((json) => Attendance.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Attendance> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Attendance();
    }

    return Attendance.fromJson(result['item']);
  }

  static Future<int> insert(Attendance item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Attendance item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Attendance item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
