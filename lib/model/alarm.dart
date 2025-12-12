import 'package:common_control/common_control.dart';
import 'package:dreamcam/models/type.dart';
import 'package:dreamcam/models/status.dart';


class Alarm {
  int id;
  String title;
  String content;
  Type type;
  Status status;
  int user;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Alarm({
    this.id = 0,
    this.title = '',
    this.content = '',
    this.type = Type(),
    this.status = Status(),
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
      type: Type.fromJson(json['type']),
      status: Status.fromJson(json['status']),
      user: json['user'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'type': type.toJson(),
    'status': status.toJson(),
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
    if (result == null || result['items'] == null) {
      return List<Alarm>.empty(growable: true);
    }

    return result['items'].map<Alarm>((json) => Alarm.fromJson(json)).toList();
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

    return Alarm.fromJson(result['item']);
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
