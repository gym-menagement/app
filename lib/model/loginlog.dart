import 'package:app/config/http.dart';


class Loginlog {
  int id;
  String ip;
  int ipvalue;
  int user;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Loginlog({
    this.id = 0,
    this.ip = '',
    this.ipvalue = 0,
    this.user = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Loginlog.fromJson(Map<String, dynamic> json) {
    return Loginlog(
      id: json['id'] as int,
      ip: json['ip'] as String,
      ipvalue: json['ipvalue'] as int,
      user: json['user'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ip': ip,
    'ipvalue': ipvalue,
    'user': user,
    'date': date,
  };

  Loginlog clone() {
    return Loginlog.fromJson(toJson());
  }
}

class LoginlogManager {
  static const baseUrl = '/api/loginlog';

  static Future<List<Loginlog>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['content'] == null) {
      return List<Loginlog>.empty(growable: true);
    }

    return result['content'].map<Loginlog>((json) => Loginlog.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Loginlog> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Loginlog();
    }

    return Loginlog.fromJson(result);
  }

  static Future<int> insert(Loginlog item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Loginlog item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Loginlog item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
