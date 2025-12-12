import 'package:common_control/common_control.dart';


class Membership {
  int id;
  int user;
  int gym;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Membership({
    this.id = 0,
    this.user = 0,
    this.gym = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: json['id'] as int,
      user: json['user'] as int,
      gym: json['gym'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'gym': gym,
    'date': date,
  };

  Membership clone() {
    return Membership.fromJson(toJson());
  }
}

class MembershipManager {
  static const baseUrl = '/api/membership';

  static Future<List<Membership>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Membership>.empty(growable: true);
    }

    return result['items'].map<Membership>((json) => Membership.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Membership> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Membership();
    }

    return Membership.fromJson(result['item']);
  }

  static Future<int> insert(Membership item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Membership item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Membership item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
