import 'package:common_control/common_control.dart';
import 'package:dreamcam/models/roleid.dart';


class Role {
  int id;
  int gym;
  Roleid roleid;
  String name;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Role({
    this.id = 0,
    this.gym = 0,
    this.roleid = Roleid(),
    this.name = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int,
      gym: json['gym'] as int,
      roleid: Roleid.fromJson(json['roleid']),
      name: json['name'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gym': gym,
    'roleid': roleid.toJson(),
    'name': name,
    'date': date,
  };

  Role clone() {
    return Role.fromJson(toJson());
  }
}

class RoleManager {
  static const baseUrl = '/api/role';

  static Future<List<Role>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Role>.empty(growable: true);
    }

    return result['items'].map<Role>((json) => Role.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Role> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Role();
    }

    return Role.fromJson(result['item']);
  }

  static Future<int> insert(Role item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Role item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Role item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
