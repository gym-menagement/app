import 'package:app/config/http.dart';


enum UsehealthStatus {
  none(0, ''),
  terminated(1, '종료'),
  use(2, '사용중'),
  paused(3, '일시정지'),
  expired(4, '만료'),
;

  const UsehealthStatus(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static UsehealthStatus fromCode(int code) {
    return UsehealthStatus.values.firstWhere((e) => e.code == code, orElse: () => UsehealthStatus.none);
  }
}

class Usehealth {
  int id;
  int order;
  int health;
  int membership;
  int user;
  int term;
  int discount;
  String startday;
  String endday;
  int gym;
  UsehealthStatus status;
  int totalcount;
  int usedcount;
  int remainingcount;
  String qrcode;
  String lastuseddate;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Usehealth({
    this.id = 0,
    this.order = 0,
    this.health = 0,
    this.membership = 0,
    this.user = 0,
    this.term = 0,
    this.discount = 0,
    this.startday = '',
    this.endday = '',
    this.gym = 0,
    this.status = UsehealthStatus.none,
    this.totalcount = 0,
    this.usedcount = 0,
    this.remainingcount = 0,
    this.qrcode = '',
    this.lastuseddate = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Usehealth.fromJson(Map<String, dynamic> json) {
    return Usehealth(
      id: json['id'] as int,
      order: json['order'] as int,
      health: json['health'] as int,
      membership: json['membership'] as int,
      user: json['user'] as int,
      term: json['term'] as int,
      discount: json['discount'] as int,
      startday: json['startday'] as String,
      endday: json['endday'] as String,
      gym: json['gym'] as int,
      status: UsehealthStatus.fromCode(json['status'] as int),
      totalcount: json['totalcount'] as int,
      usedcount: json['usedcount'] as int,
      remainingcount: json['remainingcount'] as int,
      qrcode: json['qrcode'] as String,
      lastuseddate: json['lastuseddate'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order': order,
    'health': health,
    'membership': membership,
    'user': user,
    'term': term,
    'discount': discount,
    'startday': startday,
    'endday': endday,
    'gym': gym,
    'status': status.code,
    'totalcount': totalcount,
    'usedcount': usedcount,
    'remainingcount': remainingcount,
    'qrcode': qrcode,
    'lastuseddate': lastuseddate,
    'date': date,
  };

  Usehealth clone() {
    return Usehealth.fromJson(toJson());
  }
}

class UsehealthManager {
  static const baseUrl = '/api/usehealth';

  static Future<List<Usehealth>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Usehealth>.empty(growable: true);
    }

    return result['items'].map<Usehealth>((json) => Usehealth.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Usehealth> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Usehealth();
    }

    return Usehealth.fromJson(result['item']);
  }

  static Future<int> insert(Usehealth item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Usehealth item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Usehealth item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
