import 'package:app/config/http.dart';


enum AlarmType {
  none(0, ''),
  notice(1, '공지'),
  warning(2, '경고'),
  error(3, '에러'),
  info(4, '정보'),
;

  const AlarmType(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static AlarmType fromCode(int code) {
    return AlarmType.values.firstWhere((e) => e.code == code, orElse: () => AlarmType.none);
  }
}

enum AlarmStatus {
  none(0, ''),
  success(1, '성공'),
  fail(2, '실패'),
  pending(3, '대기'),
;

  const AlarmStatus(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static AlarmStatus fromCode(int code) {
    return AlarmStatus.values.firstWhere((e) => e.code == code, orElse: () => AlarmStatus.none);
  }
}

class Alarm {
  int id;
  String title;
  String content;
  AlarmType type;
  AlarmStatus status;
  int user;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Alarm({
    this.id = 0,
    this.title = '',
    this.content = '',
    this.type = AlarmType.none,
    this.status = AlarmStatus.none,
    this.user = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      type: AlarmType.fromCode(json['type'] as int),
      status: AlarmStatus.fromCode(json['status'] as int),
      user: json['user'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'type': type.code,
    'status': status.code,
    'user': user,
    'date': date,
  };

  Alarm clone() {
    return Alarm.fromJson(toJson());
  }
}

class AlarmManager {
  static const baseUrl = '/api/alarm';

  static Future<List<Alarm>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['content'] == null) {
      return List<Alarm>.empty(growable: true);
    }

    return result['content'].map<Alarm>((json) => Alarm.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Alarm> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Alarm();
    }

    return Alarm.fromJson(result);
  }

  static Future<int> insert(Alarm item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Alarm item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Alarm item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
