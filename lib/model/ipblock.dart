import 'package:common_control/common_control.dart';
import 'package:dreamcam/models/type.dart';
import 'package:dreamcam/models/policy.dart';
import 'package:dreamcam/models/use.dart';


class Ipblock {
  int id;
  String address;
  Type type;
  Policy policy;
  Use use;
  int order;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Ipblock({
    this.id = 0,
    this.address = '',
    this.type = Type(),
    this.policy = Policy(),
    this.use = Use(),
    this.order = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Ipblock.fromJson(Map<String, dynamic> json) {
    return Ipblock(
      id: json['id'] as int,
      address: json['address'] as String,
      type: Type.fromJson(json['type']),
      policy: Policy.fromJson(json['policy']),
      use: Use.fromJson(json['use']),
      order: json['order'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'address': address,
    'type': type.toJson(),
    'policy': policy.toJson(),
    'use': use.toJson(),
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
