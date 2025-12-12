import 'package:common_control/common_control.dart';
import 'package:dreamcam/models/type.dart';
import 'package:dreamcam/models/result.dart';


class Systemlog {
  int id;
  Type type;
  String content;
  Result result;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Systemlog({
    this.id = 0,
    this.type = Type(),
    this.content = '',
    this.result = Result(),
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Systemlog.fromJson(Map<String, dynamic> json) {
    return Systemlog(
      id: json['id'] as int,
      type: Type.fromJson(json['type']),
      content: json['content'] as String,
      result: Result.fromJson(json['result']),
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toJson(),
    'content': content,
    'result': result.toJson(),
    'date': date,
  };

  Systemlog clone() {
    return Systemlog.fromJson(toJson());
  }
}

class SystemlogManager {
  static const baseUrl = '/api/systemlog';

  static Future<List<Systemlog>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Systemlog>.empty(growable: true);
    }

    return result['items'].map<Systemlog>((json) => Systemlog.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Systemlog> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Systemlog();
    }

    return Systemlog.fromJson(result['item']);
  }

  static Future<int> insert(Systemlog item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Systemlog item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Systemlog item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
