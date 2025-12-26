import 'package:app/config/http.dart';


enum IpblockType {
  none(0, ''),
  admin(1, '관리자 접근'),
  normal(2, '일반 접근'),
;

  const IpblockType(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static IpblockType fromCode(int code) {
    return IpblockType.values.firstWhere((e) => e.code == code, orElse: () => IpblockType.none);
  }
}

enum IpblockPolicy {
  none(0, ''),
  grant(1, '허용'),
  deny(2, '거부'),
;

  const IpblockPolicy(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static IpblockPolicy fromCode(int code) {
    return IpblockPolicy.values.firstWhere((e) => e.code == code, orElse: () => IpblockPolicy.none);
  }
}

enum IpblockUse {
  none(0, ''),
  use(1, '사용'),
  notuse(2, '사용안함'),
;

  const IpblockUse(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static IpblockUse fromCode(int code) {
    return IpblockUse.values.firstWhere((e) => e.code == code, orElse: () => IpblockUse.none);
  }
}

class Ipblock {
  int id;
  String address;
  IpblockType type;
  IpblockPolicy policy;
  IpblockUse use;
  int order;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Ipblock({
    this.id = 0,
    this.address = '',
    this.type = IpblockType.none,
    this.policy = IpblockPolicy.none,
    this.use = IpblockUse.none,
    this.order = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Ipblock.fromJson(Map<String, dynamic> json) {
    return Ipblock(
      id: json['id'] as int,
      address: json['address'] as String,
      type: IpblockType.fromCode(json['type'] as int),
      policy: IpblockPolicy.fromCode(json['policy'] as int),
      use: IpblockUse.fromCode(json['use'] as int),
      order: json['order'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'address': address,
    'type': type.code,
    'policy': policy.code,
    'use': use.code,
    'order': order,
    'date': date,
  };

  Ipblock clone() {
    return Ipblock.fromJson(toJson());
  }
}

class IpblockManager {
  static const baseUrl = '/api/ipblock';

  static Future<List<Ipblock>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Ipblock>.empty(growable: true);
    }

    return result['items'].map<Ipblock>((json) => Ipblock.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Ipblock> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Ipblock();
    }

    return Ipblock.fromJson(result['item']);
  }

  static Future<int> insert(Ipblock item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Ipblock item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Ipblock item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
