import 'package:common_control/common_control.dart';


enum SystemlogType {
  none(0, ''),
  login(1, '로그인'),
  crawling(2, '크롤링'),
;

  const SystemlogType(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static SystemlogType fromCode(int code) {
    return SystemlogType.values.firstWhere((e) => e.code == code, orElse: () => SystemlogType.none);
  }
}

enum SystemlogResult {
  none(0, ''),
  success(1, '성공'),
  fail(2, '실패'),
;

  const SystemlogResult(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static SystemlogResult fromCode(int code) {
    return SystemlogResult.values.firstWhere((e) => e.code == code, orElse: () => SystemlogResult.none);
  }
}

class Systemlog {
  int id;
  SystemlogType type;
  String content;
  SystemlogResult result;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Systemlog({
    this.id = 0,
    this.type = SystemlogType.none,
    this.content = '',
    this.result = SystemlogResult.none,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Systemlog.fromJson(Map<String, dynamic> json) {
    return Systemlog(
      id: json['id'] as int,
      type: SystemlogType.fromCode(json['type'] as int),
      content: json['content'] as String,
      result: SystemlogResult.fromCode(json['result'] as int),
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.code,
    'content': content,
    'result': result.code,
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
