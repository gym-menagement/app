import 'package:app/config/http.dart';


class Stop {
  int id;
  int usehealth;
  String startday;
  String endday;
  int count;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Stop({
    this.id = 0,
    this.usehealth = 0,
    this.startday = '',
    this.endday = '',
    this.count = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'] as int,
      usehealth: json['usehealth'] as int,
      startday: json['startday'] as String,
      endday: json['endday'] as String,
      count: json['count'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usehealth': usehealth,
    'startday': startday,
    'endday': endday,
    'count': count,
    'date': date,
  };

  Stop clone() {
    return Stop.fromJson(toJson());
  }
}

class StopManager {
  static const baseUrl = '/api/stop';

  static Future<List<Stop>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Stop>.empty(growable: true);
    }

    return result['items'].map<Stop>((json) => Stop.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Stop> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Stop();
    }

    return Stop.fromJson(result['item']);
  }

  static Future<int> insert(Stop item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Stop item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Stop item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
