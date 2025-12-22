import 'package:common_control/common_control.dart';


enum PushtokenIsactive {
  none(0, ''),
  inactive(1, '비활성'),
  active(2, '활성'),
;

  const PushtokenIsactive(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static PushtokenIsactive fromCode(int code) {
    return PushtokenIsactive.values.firstWhere((e) => e.code == code, orElse: () => PushtokenIsactive.none);
  }
}

class Pushtoken {
  int id;
  int user;
  String token;
  String devicetype;
  String deviceid;
  String appversion;
  PushtokenIsactive isactive;
  String createddate;
  String updateddate;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Pushtoken({
    this.id = 0,
    this.user = 0,
    this.token = '',
    this.devicetype = '',
    this.deviceid = '',
    this.appversion = '',
    this.isactive = PushtokenIsactive.none,
    this.createddate = '',
    this.updateddate = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Pushtoken.fromJson(Map<String, dynamic> json) {
    return Pushtoken(
      id: json['id'] as int,
      user: json['user'] as int,
      token: json['token'] as String,
      devicetype: json['devicetype'] as String,
      deviceid: json['deviceid'] as String,
      appversion: json['appversion'] as String,
      isactive: PushtokenIsactive.fromCode(json['isactive'] as int),
      createddate: json['createddate'] as String,
      updateddate: json['updateddate'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'token': token,
    'devicetype': devicetype,
    'deviceid': deviceid,
    'appversion': appversion,
    'isactive': isactive.code,
    'createddate': createddate,
    'updateddate': updateddate,
    'date': date,
  };

  Pushtoken clone() {
    return Pushtoken.fromJson(toJson());
  }
}

class PushtokenManager {
  static const baseUrl = '/api/pushtoken';

  static Future<List<Pushtoken>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Pushtoken>.empty(growable: true);
    }

    return result['items'].map<Pushtoken>((json) => Pushtoken.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Pushtoken> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Pushtoken();
    }

    return Pushtoken.fromJson(result['item']);
  }

  static Future<int> insert(Pushtoken item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Pushtoken item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Pushtoken item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
