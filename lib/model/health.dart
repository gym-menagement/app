import 'package:common_control/common_control.dart';


class Health {
  int id;
  int category;
  int term;
  String name;
  int count;
  int cost;
  int discount;
  int costdiscount;
  String content;
  int gym;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Health({
    this.id = 0,
    this.category = 0,
    this.term = 0,
    this.name = '',
    this.count = 0,
    this.cost = 0,
    this.discount = 0,
    this.costdiscount = 0,
    this.content = '',
    this.gym = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Health.fromJson(Map<String, dynamic> json) {
    return Health(
      id: json['id'] as int,
      category: json['category'] as int,
      term: json['term'] as int,
      name: json['name'] as String,
      count: json['count'] as int,
      cost: json['cost'] as int,
      discount: json['discount'] as int,
      costdiscount: json['costdiscount'] as int,
      content: json['content'] as String,
      gym: json['gym'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'term': term,
    'name': name,
    'count': count,
    'cost': cost,
    'discount': discount,
    'costdiscount': costdiscount,
    'content': content,
    'gym': gym,
    'date': date,
  };

  Health clone() {
    return Health.fromJson(toJson());
  }
}

class HealthManager {
  static const baseUrl = '/api/health';

  static Future<List<Health>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Health>.empty(growable: true);
    }

    return result['items'].map<Health>((json) => Health.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Health> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Health();
    }

    return Health.fromJson(result['item']);
  }

  static Future<int> insert(Health item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Health item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Health item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
