import 'package:app/config/http.dart';


class Order {
  int id;
  int user;
  int gym;
  int health;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Order({
    this.id = 0,
    this.user = 0,
    this.gym = 0,
    this.health = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      user: json['user'] as int,
      gym: json['gym'] as int,
      health: json['health'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'gym': gym,
    'health': health,
    'date': date,
  };

  Order clone() {
    return Order.fromJson(toJson());
  }
}

class OrderManager {
  static const baseUrl = '/api/order';

  static Future<List<Order>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Order>.empty(growable: true);
    }

    return result['items'].map<Order>((json) => Order.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Order> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Order();
    }

    return Order.fromJson(result['item']);
  }

  static Future<int> insert(Order item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Order item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Order item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
