import 'package:common_control/common_control.dart';


class Daytype {
  int id;
  int gym;
  String name;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Daytype({
    this.id = 0,
    this.gym = 0,
    this.name = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Daytype.fromJson(Map<String, dynamic> json) {
    return Daytype(
      id: json['id'] as int,
      gym: json['gym'] as int,
      name: json['name'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gym': gym,
    'name': name,
    'date': date,
  };

  Daytype clone() {
    return Daytype.fromJson(toJson());
  }
}

class DaytypeManager {
  static const baseUrl = '/api/daytype';

  static Future<List<Daytype>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Daytype>.empty(growable: true);
    }

    return result['items'].map<Daytype>((json) => Daytype.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Daytype> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Daytype();
    }

    return Daytype.fromJson(result['item']);
  }

  static Future<int> insert(Daytype item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Daytype item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Daytype item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
