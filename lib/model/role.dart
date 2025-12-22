import 'package:common_control/common_control.dart';


enum RoleRoleid {
  none(0, ''),
  member(1, '회원'),
  trainer(2, '트레이너'),
  staff(3, '직원'),
  gym_admin(4, '헬스장관리자'),
  platform_admin(5, '플랫폼관리자'),
;

  const RoleRoleid(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static RoleRoleid fromCode(int code) {
    return RoleRoleid.values.firstWhere((e) => e.code == code, orElse: () => RoleRoleid.none);
  }
}

class Role {
  int id;
  int gym;
  RoleRoleid roleid;
  String name;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Role({
    this.id = 0,
    this.gym = 0,
    this.roleid = RoleRoleid.none,
    this.name = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int,
      gym: json['gym'] as int,
      roleid: RoleRoleid.fromCode(json['roleid'] as int),
      name: json['name'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gym': gym,
    'roleid': roleid.code,
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
