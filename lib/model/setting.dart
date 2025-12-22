import 'package:common_control/common_control.dart';


enum SettingType {
  none(0, ''),
  string(1, '문자열'),
  number(2, '숫자'),
  boolean(3, '참거짓'),
;

  const SettingType(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static SettingType fromCode(int code) {
    return SettingType.values.firstWhere((e) => e.code == code, orElse: () => SettingType.none);
  }
}

class Setting {
  int id;
  String category;
  String name;
  String key;
  String value;
  String remark;
  SettingType type;
  String data;
  int order;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Setting({
    this.id = 0,
    this.category = '',
    this.name = '',
    this.key = '',
    this.value = '',
    this.remark = '',
    this.type = SettingType.none,
    this.data = '',
    this.order = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['id'] as int,
      category: json['category'] as String,
      name: json['name'] as String,
      key: json['key'] as String,
      value: json['value'] as String,
      remark: json['remark'] as String,
      type: SettingType.fromCode(json['type'] as int),
      data: json['data'] as String,
      order: json['order'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'name': name,
    'key': key,
    'value': value,
    'remark': remark,
    'type': type.code,
    'data': data,
    'order': order,
    'date': date,
  };

  Setting clone() {
    return Setting.fromJson(toJson());
  }
}

class SettingManager {
  static const baseUrl = '/api/setting';

  static Future<List<Setting>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Setting>.empty(growable: true);
    }

    return result['items'].map<Setting>((json) => Setting.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Setting> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Setting();
    }

    return Setting.fromJson(result['item']);
  }

  static Future<int> insert(Setting item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Setting item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Setting item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
