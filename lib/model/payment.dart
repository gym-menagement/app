import 'package:app/config/http.dart';


class Payment {
  int id;
  int gym;
  int order;
  int user;
  int cost;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Payment({
    this.id = 0,
    this.gym = 0,
    this.order = 0,
    this.user = 0,
    this.cost = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      gym: json['gym'] as int,
      order: json['order'] as int,
      user: json['user'] as int,
      cost: json['cost'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gym': gym,
    'order': order,
    'user': user,
    'cost': cost,
    'date': date,
  };

  Payment clone() {
    return Payment.fromJson(toJson());
  }
}

class PaymentManager {
  static const baseUrl = '/api/payment';

  static Future<List<Payment>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['content'] == null) {
      return List<Payment>.empty(growable: true);
    }

    return result['content'].map<Payment>((json) => Payment.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Payment> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Payment();
    }

    return Payment.fromJson(result);
  }

  static Future<int> insert(Payment item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Payment item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Payment item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
