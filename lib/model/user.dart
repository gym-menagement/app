import 'package:common_control/common_control.dart';


enum UserLevel {
  none(0, ''),
  normal(1, '일반회원'),
  manager(2, '트레이너/직원'),
  admin(3, '헬스장관리자'),
  superadmin(4, '플랫폼관리자'),
  rootadmin(5, '최고관리자'),
;

  const UserLevel(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static UserLevel fromCode(int code) {
    return UserLevel.values.firstWhere((e) => e.code == code, orElse: () => UserLevel.none);
  }
}

enum UserUse {
  none(0, ''),
  use(1, '사용'),
  notuse(2, '사용안함'),
;

  const UserUse(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static UserUse fromCode(int code) {
    return UserUse.values.firstWhere((e) => e.code == code, orElse: () => UserUse.none);
  }
}

enum UserType {
  none(0, ''),
  normal(1, '일반'),
  kakao(2, '카카오'),
  naver(3, '네이버'),
  google(4, '구글'),
  apple(5, '애플'),
;

  const UserType(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static UserType fromCode(int code) {
    return UserType.values.firstWhere((e) => e.code == code, orElse: () => UserType.none);
  }
}

enum UserRole {
  none(0, ''),
  member(1, '회원'),
  trainer(2, '트레이너'),
  staff(3, '직원'),
  gym_admin(4, '헬스장관리자'),
  platform_admin(5, '플랫폼관리자'),
;

  const UserRole(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static UserRole fromCode(int code) {
    return UserRole.values.firstWhere((e) => e.code == code, orElse: () => UserRole.none);
  }
}

enum UserSex {
  none(0, ''),
  male(1, '남성'),
  female(2, '여성'),
;

  const UserSex(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static UserSex fromCode(int code) {
    return UserSex.values.firstWhere((e) => e.code == code, orElse: () => UserSex.none);
  }
}

class User {
  int id;
  String loginid;
  String passwd;
  String email;
  String name;
  String tel;
  String address;
  String image;
  UserSex sex;
  String birth;
  UserType type;
  String connectid;
  UserLevel level;
  UserRole role;
  UserUse use;
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
    this.sex = UserSex.none,
    this.birth = '',
    this.type = UserType.none,
    this.connectid = '',
    this.level = UserLevel.none,
    this.role = UserRole.none,
    this.use = UserUse.none,
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
      sex: UserSex.fromCode(json['sex'] as int),
      birth: json['birth'] as String,
      type: UserType.fromCode(json['type'] as int),
      connectid: json['connectid'] as String,
      level: UserLevel.fromCode(json['level'] as int),
      role: UserRole.fromCode(json['role'] as int),
      use: UserUse.fromCode(json['use'] as int),
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
    'sex': sex.code,
    'birth': birth,
    'type': type.code,
    'connectid': connectid,
    'level': level.code,
    'role': role.code,
    'use': use.code,
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
