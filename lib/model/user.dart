import 'package:common_control/common_control.dart';
import 'package:dreamcam/models/sex.dart';
import 'package:dreamcam/models/type.dart';
import 'package:dreamcam/models/level.dart';
import 'package:dreamcam/models/role.dart';
import 'package:dreamcam/models/use.dart';


class User {
  int id;
  String loginid;
  String passwd;
  String email;
  String name;
  String tel;
  String address;
  String image;
  Sex sex;
  String birth;
  Type type;
  String connectid;
  Level level;
  Role role;
  Use use;
  String logindate;
  String lastchangepasswddate;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  User({
    this.id = 0,
    this.loginid = '',
    this.passwd = '',
    this.email = '',
    this.name = '',
    this.tel = '',
    this.address = '',
    this.image = '',
    this.sex = Sex(),
    this.birth = '',
    this.type = Type(),
    this.connectid = '',
    this.level = Level(),
    this.role = Role(),
    this.use = Use(),
    this.logindate = '',
    this.lastchangepasswddate = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      loginid: json['loginid'] as String,
      passwd: json['passwd'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      tel: json['tel'] as String,
      address: json['address'] as String,
      image: json['image'] as String,
      sex: Sex.fromJson(json['sex']),
      birth: json['birth'] as String,
      type: Type.fromJson(json['type']),
      connectid: json['connectid'] as String,
      level: Level.fromJson(json['level']),
      role: Role.fromJson(json['role']),
      use: Use.fromJson(json['use']),
      logindate: json['logindate'] as String,
      lastchangepasswddate: json['lastchangepasswddate'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'loginid': loginid,
    'passwd': passwd,
    'email': email,
    'name': name,
    'tel': tel,
    'address': address,
    'image': image,
    'sex': sex.toJson(),
    'birth': birth,
    'type': type.toJson(),
    'connectid': connectid,
    'level': level.toJson(),
    'role': role.toJson(),
    'use': use.toJson(),
    'logindate': logindate,
    'lastchangepasswddate': lastchangepasswddate,
    'date': date,
  };

  User clone() {
    return User.fromJson(toJson());
  }
}

class UserManager {
  static const baseUrl = '/api/user';

  static Future<List<User>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<User>.empty(growable: true);
    }

    return result['items'].map<User>((json) => User.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<User> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return User();
    }

    return User.fromJson(result['item']);
  }

  static Future<int> insert(User item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(User item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(User item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
